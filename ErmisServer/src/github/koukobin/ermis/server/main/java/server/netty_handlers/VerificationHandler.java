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
import github.koukobin.ermis.common.entry.Verification.Action;
import github.koukobin.ermis.common.entry.Verification.Result;
import github.koukobin.ermis.common.results.EntryResult;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.util.EmailerService;
import github.koukobin.ermis.server.main.java.util.RandomNumberGenerator;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author Ilias Koukovinis
 * 
 */
abstract non-sealed class VerificationHandler extends EntryHandler {

	private static final int ATTEMPTS = 3;
	private static final int GENERATED_VERIFICATION_CODE_LENGTH = 5;

	// Initialize like this in order for theRunAsync to work properly
	private static final CompletableFuture<?> pendingEmailsQueue = CompletableFuture.runAsync(() -> {});

	private int attemptsRemaining;
	private final int generatedVerificationCode;

	private final String emailAddress;

	{
		attemptsRemaining = ATTEMPTS;
		generatedVerificationCode = RandomNumberGenerator.generateRandomNumber(GENERATED_VERIFICATION_CODE_LENGTH);
	}
	
	VerificationHandler(ClientInfo clientInfo, String email) {
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
				EmailerService.sendEmailWithHTML("Security Alert", createEmailMessage(emailAddress, codeString), emailAddress);
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
		
		EntryResult entryResult = new EntryResult(Result.WRONG_CODE.resultHolder);
		attemptsRemaining--;

		boolean isVerificationComplete = false;

		int clientGuessForVerificationCode = msg.readInt();
		getLogger().debug("Client guessed: {}", clientGuessForVerificationCode);

		if (generatedVerificationCode == clientGuessForVerificationCode) {
			entryResult = executeWhenVerificationSuccessful();
			isVerificationComplete = true;
		} else if (attemptsRemaining == 0) {
			entryResult = new EntryResult(Result.RUN_OUT_OF_ATTEMPTS.resultHolder);
			isVerificationComplete = true;
		}
		
		byte[] resultMessageBytes = entryResult.getResultMessage().getBytes();
		
		ByteBuf payload = ctx.alloc().ioBuffer();
		payload.writeBoolean(isVerificationComplete);
		payload.writeBoolean(entryResult.isSuccessful());
		payload.writeInt(resultMessageBytes.length);
		payload.writeBytes(resultMessageBytes);
		for (Entry<AddedInfo, String> addedInfo : entryResult.getAddedInfo().entrySet()) {
			payload.writeInt(addedInfo.getKey().id);
			byte[] info = addedInfo.getValue().getBytes();
			payload.writeInt(info.length);
			payload.writeBytes(info);
		}
		
		ctx.channel().writeAndFlush(payload);
		getLogger().debug("Sent result");
		
		if (isVerificationComplete) {
			if (entryResult.isSuccessful()) {
				registrationSuccessful(ctx);
			} else {
				registrationFailed(ctx);
			}
		}
	}

	public abstract String createEmailMessage(String account, String generatedVerificationCode);
	public abstract EntryResult executeWhenVerificationSuccessful() throws IOException;
	
	protected void onSuccessfulRegistration(ChannelHandlerContext ctx) {
		login(ctx, clientInfo);
	}
}
