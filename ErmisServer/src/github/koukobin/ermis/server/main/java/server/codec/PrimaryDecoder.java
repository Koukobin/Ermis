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
package github.koukobin.ermis.server.main.java.server.codec;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.github.luben.zstd.Zstd;
import com.google.common.base.Throwables;

import github.koukobin.ermis.common.message_types.ClientCommandType;
import github.koukobin.ermis.common.message_types.ClientMessageType;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.util.CompressionDetector;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author Ilias Koukovinis
 *
 */
public final class PrimaryDecoder extends Decoder {

	private static final Logger LOGGER = LogManager.getLogger("server");

	@Override
	public boolean handleMessage(ChannelHandlerContext ctx, int length, ByteBuf in) {
		if (CompressionDetector.isZstdCompressed(in)) {
			try {
				decompress(in);
			} catch (Exception e) {
				LOGGER.debug(Throwables.getStackTraceAsString(e));
				createErrorResponse(ctx, "Decompression failed");
				return false; // Decompression failed, terminate the method early
			}
		}

		ClientMessageType messageType;
		try {
			messageType = ClientMessageType.fromId(in.readInt());
		} catch (IndexOutOfBoundsException iobe) {
			LOGGER.debug(Throwables.getStackTraceAsString(iobe));
			createErrorResponse(ctx, "Message type not recognized!");
			return false;
		}

		int maxLength = determineMaxLength(ctx, in, messageType);
		if (maxLength == -1) {
			return false; // Invalid message type or content type
		}

		if (maxLength < length) {
			sendMessageExceedsMaximumMessageLength(ctx, maxLength);
			return false;
		}

		return true;
	}
	
	private static void decompress(ByteBuf in) {
		int compressedLength = in.readInt();
		byte[] compressedData = new byte[compressedLength];
		in.readBytes(compressedData);

		byte[] decompressedData = Zstd.decompress(compressedData, (int) Zstd.decompressedSize(compressedData));

		in.clear();
		in.writeBytes(decompressedData);
		in.capacity(decompressedData.length);
	}

	private static int determineMaxLength(ChannelHandlerContext ctx, ByteBuf data, ClientMessageType messageType) {
		switch (messageType) {
		case CLIENT_CONTENT:
			ClientContentType contentType;
			try {
				contentType = ClientContentType.fromId(data.readInt());
			} catch (IndexOutOfBoundsException iobe) {
				LOGGER.debug(Throwables.getStackTraceAsString(iobe));
				createErrorResponse(ctx, "Content type not known!");
				return -1;
			}
			return getMaxLengthForContentType(ctx, contentType);
		case ENTRY:
			return SimpleDecoder.MAX_LENGTH; // Kinda shitty code but for now this will suffice
		case COMMAND:
			return getMaxLengthForCommand(ctx, data);
		default:
			LOGGER.debug("Message type not implemented!");
			createErrorResponse(ctx, "Message type not implemented!");
			return -1;
		}
	}

	private static int getMaxLengthForContentType(ChannelHandlerContext ctx, ClientContentType contentType) {
		switch (contentType) {
		case FILE, IMAGE:
			return ServerSettings.MAX_CLIENT_MESSAGE_FILE_BYTES;
		case TEXT:
			return ServerSettings.MAX_CLIENT_MESSAGE_TEXT_BYTES;
		default:
			LOGGER.debug("Content type not implemented!");
			createErrorResponse(ctx, "Content type not implemented!");
			return -1;
		}
	}

	private static int getMaxLengthForCommand(ChannelHandlerContext ctx, ByteBuf data) {
		try {
			ClientCommandType commandType = ClientCommandType.fromId(data.readInt());
			return (commandType == ClientCommandType.ADD_ACCOUNT_ICON)
					? ServerSettings.MAX_CLIENT_MESSAGE_FILE_BYTES
					: ServerSettings.MAX_CLIENT_MESSAGE_TEXT_BYTES;
		} catch (IndexOutOfBoundsException iooe) {
			LOGGER.debug(Throwables.getStackTraceAsString(iooe));
			createErrorResponse(ctx, "Command not known!");
			return -1;
		}
	}

}