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
package github.koukobin.ermis.server.main.java.server;

import java.io.FileInputStream;
import java.io.OutputStream;
import java.math.BigInteger;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.security.KeyStore;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

import javax.crypto.SecretKey;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManagerFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;
import com.google.common.collect.Lists;

import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.util.EnumIntConverter;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.util.AESGCMCipher;
import github.koukobin.ermis.server.main.java.util.AESKeyGenerator;
import github.koukobin.ermis.server.main.java.util.InsecureRandomNumberGenerator;
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.buffer.Unpooled;
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelOption;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.epoll.EpollDatagramChannel;
import io.netty.channel.epoll.EpollEventLoopGroup;
import io.netty.channel.socket.DatagramPacket;
import io.netty.handler.codec.MessageToMessageDecoder;
import io.netty.handler.codec.MessageToMessageEncoder;
import io.netty.handler.ssl.ApplicationProtocolConfig;
import io.netty.handler.ssl.ApplicationProtocolNames;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.SslProvider;
import io.netty.handler.ssl.SupportedCipherSuiteFilter;
import io.netty.handler.ssl.ApplicationProtocolConfig.Protocol;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectedListenerFailureBehavior;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectorFailureBehavior;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ServerUDP {

	private static final Logger LOGGER;
	
	private static Channel serverSocketChannel;

	private static EpollEventLoopGroup workerGroup;
	
	private static AtomicBoolean isRunning;

	private ServerUDP() throws IllegalAccessException {
		throw new IllegalAccessException("Server cannot be constructed since it is statically initialized!");
	}

	static {
		LOGGER = LogManager.getLogger("server");
	}
	
	static {
		try {
			LOGGER.info("Initializing...");
			
			workerGroup = new EpollEventLoopGroup(ServerSettings.WORKER_THREADS);
			
			isRunning = new AtomicBoolean(false);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	public static void start() {
		if (ServerUDP.isRunning.get()) {
			throw new IllegalStateException("Server cannot start since the server is already running");
		}
		
		try {
			InetSocketAddress localAddress = new InetSocketAddress(ServerSettings.SERVER_ADDRESS, ServerSettings.UDP_PORT);
			
			Bootstrap bootstrapUDP = new Bootstrap();
			bootstrapUDP.group(workerGroup)
			    .channel(EpollDatagramChannel.class)
			    .localAddress(localAddress)
			    .option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT)
			    .handler(new Test());
	        
			serverSocketChannel = bootstrapUDP.bind().sync().channel();

			ServerUDP.isRunning.set(true);

			InetSocketAddress serverAddress = (InetSocketAddress) serverSocketChannel.localAddress();

			LOGGER.info("UDP Server started successfully on port {} and at address {}", serverAddress.getPort(),
					serverAddress.getHostName());
			LOGGER.info("Waiting for incoming calls...");
		} catch (Exception e) {
			throw new RuntimeException("Failed to start UDP server", e);
		}
	}

	public static class UdpDecoder extends MessageToMessageDecoder<DatagramPacket> {

		@Override
		protected void decode(ChannelHandlerContext ctx, DatagramPacket packet, List<Object> out) throws Exception {
			ByteBuf content = packet.content();
			int chatSessionID = content.readInt();
			byte[] contentBytes = new byte[content.readableBytes()];
			content.readBytes(contentBytes);

			out.add(new Packet(chatSessionID, contentBytes, packet.sender()));
		}
	}

	public static class UdpEncoder extends MessageToMessageEncoder<ByteBuf> {

		private final InetSocketAddress recipientAddress;

		public UdpEncoder(InetSocketAddress recipientAddress) {
			this.recipientAddress = recipientAddress;
		}

		@Override
		protected void encode(ChannelHandlerContext ctx, ByteBuf msg, List<Object> out) throws Exception {
			DatagramPacket packet = new DatagramPacket(msg, recipientAddress);
			out.add(packet);
		}

	}

	private static record Packet(int chatSessionID, byte[] content, InetSocketAddress sender) {

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + Arrays.hashCode(content);
			result = prime * result + Objects.hash(chatSessionID, sender);
			return result;
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj) {
				return true;
			}

			if (obj == null) {
				return false;
			}

			if (getClass() != obj.getClass()) {
				return false;
			}

			Packet other = (Packet) obj;
			return chatSessionID == other.chatSessionID 
					&& Arrays.equals(content, other.content)
					&& Objects.equals(sender, other.sender);
		}

		@Override
		public String toString() {
			return "Packet [chatSessionID=" + chatSessionID 
					+ ", content=" + Arrays.toString(content) 
					+ ", sender=" + sender + "]";
		}
	}

	public record VoiceChat(int key, List<InetSocketAddress> members, AESGCMCipher aesKey) {}
	
	enum ServerMessage {
		VOICE(4),
		USER_ADDED(0),
		CALL_ENDED(1);
		
		private final int id;
		ServerMessage(int id) {
			this.id = id;
		}
	}
	
	enum ClientMessage {
		VOICE(4),
		END_CALL(1);
		
		private static final HashMap<Integer, ClientMessage> values;
		
		static {
			values = new HashMap<>(
					Arrays.stream(ClientMessage.values())
					.collect(Collectors.toMap(type -> type.id, type -> type))
					);
		}

		private final int id;

		ClientMessage(int id) {
			this.id = id;
		}
		
		public static ClientMessage fromId(int id) {
			return EnumIntConverter.fromId(values, id);
		}
	}
	
//	private static class Test0 extends SimpleChannelInboundHandler<DatagramPacket> {
//
//		private static final SslContext sslContext;
//		
//		static {
//			try {
//				char[] certificatePassword = ServerSettings.SSL.CERTIFICATE_PASSWORD.toCharArray();
//				
//				KeyStore ks = KeyStore.getInstance("DTLS");
//				ks.load(new FileInputStream(ServerSettings.SSL.CERTIFICATE_LOCATION), certificatePassword);
//				
//				KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
//				kmf.init(ks, certificatePassword);
//				
//				TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
//				tmf.init(ks);
//				
//				sslContext = SslContextBuilder.forServer(kmf)
//						.trustManager(tmf)
//						.protocols(ServerSettings.SSL.getEnabledProtocols())
//						.sslProvider(SslProvider.OPENSSL)
//						.ciphers(Arrays.asList(ServerSettings.SSL.getEnabledCipherSuites()), SupportedCipherSuiteFilter.INSTANCE)
//						.applicationProtocolConfig(
//								new ApplicationProtocolConfig(Protocol.ALPN, SelectorFailureBehavior.NO_ADVERTISE,
//										SelectedListenerFailureBehavior.ACCEPT, ApplicationProtocolNames.HTTP_1_1))
//						.build();
//			} catch (Exception e) {
//				LOGGER.fatal("Initializing SSLContext failed:", e);
//				throw new RuntimeException(e);
//			}
//		}
//
//		@Override
//		public void handlerAdded(ChannelHandlerContext ctx) {
//			ctx.pipeline().addLast(new Test());
//		}
//
//		@Override
//		public void channelRead0(ChannelHandlerContext ctx, DatagramPacket msg) throws Exception {
//			
//		}
//		
//	}

	private static class Test extends SimpleChannelInboundHandler<DatagramPacket> {

		private static final Map<InetAddress, Integer> socks = new ConcurrentHashMap<>();
		private static final Map<Integer, VoiceChat> calls = new ConcurrentHashMap<>();

		@Override
		public void channelRead0(ChannelHandlerContext ctx, DatagramPacket packet) throws Exception {
			LOGGER.debug("Packet received");
			ByteBuf content = packet.content();

			SecretKey secretKey = calls.get(socks.get(packet.sender().getAddress())).aesKey.getSecretKey();
			int chatSessionID = content.readInt();
			ByteBuf encryptedContent;
			ByteBuf decryptedContent;
			{
				encryptedContent = content.slice();
				byte[] a = new byte[encryptedContent.readableBytes()];
				encryptedContent.readBytes(a);
				byte[] b = AESKeyGenerator.decrypt(secretKey, a);

				decryptedContent = ctx.alloc().ioBuffer();
				decryptedContent.writeBytes(b);
			}

			switch (ClientMessage.fromId(content.readInt())) {
			case END_CALL:
				calls.get(chatSessionID).members().remove(packet.sender());
				return;
			case VOICE:
				break;
			}

			int distinguishingKey = content.readInt();

			// Authorize using unique key
			if (distinguishingKey != calls.get(chatSessionID).key()) {
				LOGGER.debug("Incorrect key");
				return;
			}

			List<InetSocketAddress> recipients = calls.get(chatSessionID).members();
			if (!recipients.contains(packet.sender())) {
				LOGGER.debug("User joined chat session: {}", chatSessionID);

				ByteBuf buffer = ctx.alloc().ioBuffer();
				buffer.writeInt(ServerMessage.USER_ADDED.id);
				for (InetSocketAddress recipientAddress : recipients) {
					buffer.retain();
					DatagramPacket responsePacket = new DatagramPacket(buffer, recipientAddress);
					ctx.channel().writeAndFlush(responsePacket);
				}
				calls.get(chatSessionID).members().add(packet.sender());
			}

			ByteBuf contentBytes = ctx.alloc().ioBuffer(Integer.BYTES + content.readableBytes());
			contentBytes.writeInt(ServerMessage.VOICE.id);
			contentBytes.writeBytes(content.slice());
			contentBytes.retain(recipients.size() - 1);

			contentBytes.markReaderIndex();
			byte[] contentBytes2 = new byte[contentBytes.readableBytes()];
			contentBytes.readBytes(contentBytes2);
			contentBytes.resetReaderIndex();

			Path outputPath = Paths.get("/home/ilias/march.wav");
			if (!Files.exists(outputPath)) {
				// Write WAV header for the first time
				try (OutputStream os = Files.newOutputStream(outputPath, StandardOpenOption.CREATE)) {
					os.write(createWavHeader(44100, 2, 16)); // Adjust parameters as needed
				}
			}
			// Append raw PCM data
			Files.write(outputPath, contentBytes2, StandardOpenOption.APPEND);

			for (InetSocketAddress recipientAddress : recipients) {
				if (recipientAddress.equals(packet.sender())) {
					continue;
				}

				LOGGER.debug("Transmitting UDP message to address: {}", recipientAddress);
				DatagramPacket responsePacket = new DatagramPacket(contentBytes, recipientAddress);
				ctx.channel().writeAndFlush(responsePacket);
			}

		}
	}

	private static byte[] createWavHeader(int sampleRate, int channels, int bitsPerSample) {
		int byteRate = sampleRate * channels * bitsPerSample / 8;
		int blockAlign = channels * bitsPerSample / 8;

		ByteBuffer buffer = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN);
		buffer.put("RIFF".getBytes());
		buffer.putInt(0); // Placeholder for file size
		buffer.put("WAVE".getBytes());
		buffer.put("fmt ".getBytes());
		buffer.putInt(16); // Subchunk1 size (PCM)
		buffer.putShort((short) 1); // Audio format (1 = PCM)
		buffer.putShort((short) channels);
		buffer.putInt(sampleRate);
		buffer.putInt(byteRate);
		buffer.putShort((short) blockAlign);
		buffer.putShort((short) bitsPerSample);
		buffer.put("data".getBytes());
		buffer.putInt(0); // Placeholder for data chunk size
		return buffer.array();
	}

	public static VoiceChat createVoiceChat(int chatSessionID) {
		int key = InsecureRandomNumberGenerator.generateRandomNumber(8);
		AESGCMCipher aesKey = AESKeyGenerator.generateAESKey1();
		Test.calls.put(chatSessionID, new VoiceChat(key, Lists.newArrayList(), aesKey));
//		Test.socks.put(address, chatSessionID);
		return Test.calls.get(chatSessionID);
	}

	public static void stop() {
		if (!ServerUDP.isRunning.get()) {
			throw new IllegalStateException("Server has not started therefore cannot be stopped");
		}

		workerGroup.shutdownGracefully();

		ServerUDP.isRunning.set(false);

		LOGGER.info("Server stopped succesfully on port {} and at address {}",
				((InetSocketAddress) serverSocketChannel.localAddress()).getHostName(),
				((InetSocketAddress) serverSocketChannel.localAddress()).getPort());

		LOGGER.info("Stopped waiting for incoming calls");
	}
}


