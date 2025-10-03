/* Copyright (C) 2023 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
package github.koukobin.ermis.server.main.java.server.netty_handlers;

import java.io.IOException;
import java.util.Map.Entry;
import java.util.concurrent.CompletableFuture;

import javax.mail.MessagingException;

import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.Verification;
import github.koukobin.ermis.common.entry.Verification.Action;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.results.GeneralResult;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.EmailerService;
import github.koukobin.ermis.server.main.java.util.SecureRandomNumberGenerator;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author Ilias Koukovinis
 * 
 */
public abstract non-sealed class VerificationHandler extends EntryHandler {

	private static final int ATTEMPTS = 3;
	private static final int GENERATED_VERIFICATION_CODE_LENGTH = 5;

	// Initialize like this in order for theRunAsync to work properly
	private static final CompletableFuture<?> pendingEmailsQueue = CompletableFuture.runAsync(() -> {});

	private int attemptsRemaining;
	private final int generatedVerificationCode;

	private final String emailAddress;

	{
		attemptsRemaining = ATTEMPTS;
		generatedVerificationCode = SecureRandomNumberGenerator.generateRandomNumber(GENERATED_VERIFICATION_CODE_LENGTH);
	}

	protected VerificationHandler(ClientInfo clientInfo, String email) {
		super(clientInfo);
		this.emailAddress = email;
	}

	@Override
	public void handlerAdded(ChannelHandlerContext ctx) {
		sendVerificationCode();
	}

	private void sendVerificationCode() {
		String codeString = Integer.toString(generatedVerificationCode);

		pendingEmailsQueue.thenRunAsync(() -> {
			try {
				EmailerService.sendEmailWithHTML("Security Alert", createEmailMessage(codeString), emailAddress);
			} catch (MessagingException me) {
				getLogger().error("Failed to send email", me);
			}
		});
	}

	@Override
	public void executeEntryAction(ChannelHandlerContext ctx, ByteBuf msg) {
		Action action = Action.fromId(msg.readInt());

		switch (action) {
		case RESEND_CODE -> sendVerificationCode();
		}
	}

	@Override
	public void channelRead1(ChannelHandlerContext ctx, ByteBuf msg) throws IOException {
		attemptsRemaining--;

		int clientCodeGuess = msg.readInt();
		getLogger().debug("Client guessed: {}", clientCodeGuess);

		Verification.Result verificationStatusCode;
		GeneralResult entryResult = null;

		boolean isGuessCorrect = (generatedVerificationCode == clientCodeGuess);
		boolean areAttemptsExhausted = (attemptsRemaining == 0);

		if (isGuessCorrect) {
			entryResult = executeWhenVerificationSuccessful();
			verificationStatusCode = Verification.Result.SUCCESFULLY_VERIFIED;
		} else if (areAttemptsExhausted) {
			verificationStatusCode = Verification.Result.RUN_OUT_OF_ATTEMPTS;
		} else {
			verificationStatusCode = Verification.Result.WRONG_CODE;
		}

		if (verificationStatusCode == Verification.Result.RUN_OUT_OF_ATTEMPTS) {
			registrationFailed(ctx);
			return;
		}

		ByteBuf payload = ctx.alloc().ioBuffer();
		payload.writeInt(ServerMessageType.ENTRY.id);
		payload.writeInt(verificationStatusCode.getID());

		if (entryResult != null) {
			payload.writeInt(entryResult.getIDable().getID());
			for (Entry<AddedInfo, String> addedInfo : entryResult.getAddedInfo().entrySet()) {
				AddedInfo key = addedInfo.getKey();
				byte[] valueBytes = addedInfo.getValue().getBytes();

				payload.writeInt(key.id);
				payload.writeInt(valueBytes.length);
				payload.writeBytes(valueBytes);
			}
		}

		ctx.channel().writeAndFlush(payload);

		if (isGuessCorrect) {
			if (!entryResult.isSuccessful()) {
				registrationFailed(ctx);
				return;
			}

			login(ctx, clientInfo);
		}

	}

	public abstract String createEmailMessage(String generatedVerificationCode);
	public abstract GeneralResult executeWhenVerificationSuccessful() throws IOException;
}
