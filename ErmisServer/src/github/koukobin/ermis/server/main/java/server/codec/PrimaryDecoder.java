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
import github.koukobin.ermis.common.message_types.MessageDeliveryStatus;
import github.koukobin.ermis.common.message_types.ServerInfoMessage;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.util.CompressionDetector;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import net.jpountz.lz4.LZ4DecompressorWithLength;
import net.jpountz.lz4.LZ4Factory;
import net.jpountz.lz4.LZ4SafeDecompressor;

/**
 * @author Ilias Koukovinis
 *
 */
public final class PrimaryDecoder extends Decoder {

	private static final Logger LOGGER = LogManager.getLogger("server");

	@Override
	public boolean decodeMessage(ChannelHandlerContext ctx, ByteBuf in) {
		LOGGER.debug("Message received");
		int length;
		try {
			// Decoder supports both Zstd and Lz4 compression
			if (CompressionDetector.isZstdCompressed(in)) {
				length = zstdDecompress(in);
			} else if (CompressionDetector.isLz4Compressed(in)) {
				length = lz4Decompress(in);
			} else {
				length = in.capacity();
				LOGGER.debug("Message not compressed (or compression algorithm is not supported)");
			}
		} catch (Exception e) {
			LOGGER.debug("{} thrown for message; details: {}",
					e.getClass().getSimpleName(),
					Throwables.getStackTraceAsString(e));
			Decoder.createErrorResponse(ctx, ServerInfoMessage.DECOMPRESSION_FAILED);
			return false; // Decompression failed, terminate the method early
		}

		ClientMessageType messageType;
		try {
			messageType = ClientMessageType.fromId(in.readInt());
		} catch (IndexOutOfBoundsException iobe) {
			byte[] fuck = new byte[length];
			in.readBytes(fuck);
			LOGGER.debug("{} thrown for message \"{}\"; details: {}",
					iobe.getClass().getSimpleName(),
					ByteBufUtil.hexDump(fuck),
					Throwables.getStackTraceAsString(iobe));
			Decoder.createErrorResponse(ctx, ServerInfoMessage.MESSAGE_TYPE_NOT_RECOGNIZED);
			return false;
		}

		int maxLength = determineMaxLength(ctx, in, messageType);
		if (maxLength == -1) {
			return false; // Invalid message type or content type
		}

		if (length > maxLength) {
			Decoder.sendMessageExceedsMaximumMessageLength(ctx, maxLength);
			return false;
		}

		return true;
	}

	private static int zstdDecompress(ByteBuf in) {
		in.markReaderIndex();
		byte[] compressedData = new byte[in.capacity()];
		in.readBytes(compressedData);
		in.resetReaderIndex();

		int decompressedSize = (int) Zstd.getFrameContentSize(compressedData);
		byte[] decompressedData = Zstd.decompress(compressedData, decompressedSize);

		in.writerIndex(0);
		in.writeBytes(decompressedData);

		return decompressedData.length;
	}

	private static int lz4Decompress(ByteBuf in) {
		in.markReaderIndex();
		byte[] compressedData = new byte[in.capacity()];
		in.readBytes(compressedData);
		in.resetReaderIndex();

		class Lz4Decompressor {
			private static final LZ4SafeDecompressor decompressor;

			static {
				LZ4Factory factory = LZ4Factory.fastestInstance();
				decompressor = factory.safeDecompressor();
			}
			
			private Lz4Decompressor() {}
		}

		int decompressedLength = LZ4DecompressorWithLength.getDecompressedLength(compressedData);
		byte[] decompressedData = new byte[decompressedLength];
		Lz4Decompressor.decompressor.decompress(compressedData, decompressedData);

		in.writerIndex(0);
		in.writeBytes(decompressedData);

		return decompressedData.length;
	}

	private static int determineMaxLength(ChannelHandlerContext ctx, ByteBuf data, ClientMessageType messageType) {
		switch (messageType) {
		case CLIENT_CONTENT:
			int tempMessageID = 0;
			ClientContentType contentType;
			try {
				tempMessageID = data.readInt();
				contentType = ClientContentType.fromId(data.readInt());
			} catch (IndexOutOfBoundsException iobe) {
				LOGGER.debug(Throwables.getStackTraceAsString(iobe));
				Decoder.createErrorResponse(ctx, ServerInfoMessage.CONTENT_TYPE_NOT_KNOWN);

				ByteBuf messageFailure = ctx.alloc().ioBuffer();
				messageFailure.writeInt(ServerMessageType.MESSAGE_DELIVERY_STATUS.id);
				messageFailure.writeInt(MessageDeliveryStatus.FAILED.id);
				messageFailure.writeInt(tempMessageID);
				ctx.channel().writeAndFlush(messageFailure);
				return -1;
			}

			int maxLength = getMaxLengthForContentType(ctx, contentType);
			if (maxLength == -1 || data.capacity() > maxLength) {
				ByteBuf messageRejected = ctx.alloc().ioBuffer();
				messageRejected.writeInt(ServerMessageType.MESSAGE_DELIVERY_STATUS.id);
				messageRejected.writeInt(MessageDeliveryStatus.REJECTED.id);
				messageRejected.writeInt(tempMessageID);
				ctx.channel().writeAndFlush(messageRejected);
			}

			return maxLength;
		case USER_ENTRY:
			return SimpleDecoder.MAX_LENGTH; // Kinda shitty code but for now this will suffice
		case USER_COMMAND:
			return getMaxLengthForCommand(ctx, data);
		default:
			LOGGER.debug("Message type not implemented!");
			Decoder.createErrorResponse(ctx, ServerInfoMessage.MESSAGE_TYPE_NOT_IMPLEMENTED);
			return -1;
		}
	}

	private static int getMaxLengthForContentType(ChannelHandlerContext ctx, ClientContentType contentType) {
		switch (contentType) {
		case FILE, IMAGE, VOICE:
			return ServerSettings.MAX_CLIENT_MESSAGE_FILE_BYTES;
		case TEXT, GIF:
			return ServerSettings.MAX_CLIENT_MESSAGE_TEXT_BYTES;
		default:
			LOGGER.debug("Content type not implemented!");
			Decoder.createErrorResponse(ctx, ServerInfoMessage.CONTENT_TYPE_NOT_IMPLEMENTED);
			return -1;
		}
	}

	private static int getMaxLengthForCommand(ChannelHandlerContext ctx, ByteBuf data) {
		try {
			ClientCommandType commandType = ClientCommandType.fromId(data.readInt());
			return (commandType == ClientCommandType.SET_ACCOUNT_ICON) 
					? ServerSettings.MAX_CLIENT_MESSAGE_FILE_BYTES
					: ServerSettings.MAX_CLIENT_MESSAGE_TEXT_BYTES;
		} catch (IndexOutOfBoundsException iooe) {
			LOGGER.debug(Throwables.getStackTraceAsString(iooe));
			Decoder.createErrorResponse(ctx, ServerInfoMessage.COMMAND_NOT_KNOWN);
			return -1;
		}
	}

}
