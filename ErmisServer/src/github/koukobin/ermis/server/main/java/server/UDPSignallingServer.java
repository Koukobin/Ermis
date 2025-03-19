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
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManagerFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;
import com.google.common.collect.Lists;

import github.koukobin.ermis.common.message_types.ClientContentType;
import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.util.EnumIntConverter;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.server.ServerUDP.ServerMessage;
import github.koukobin.ermis.server.main.java.server.ServerUDP.VoiceChat;
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
public final class UDPSignallingServer {

	private static final Logger LOGGER;
	
	private static Channel serverSocketChannel;

	private static EpollEventLoopGroup workerGroup;
	
	private static AtomicBoolean isRunning;

	private UDPSignallingServer() throws IllegalAccessException {
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
		if (UDPSignallingServer.isRunning.get()) {
			throw new IllegalStateException("Server cannot start since the server is already running");
		}
		
		try {
			InetSocketAddress localAddress = new InetSocketAddress(ServerSettings.SERVER_ADDRESS, 9999);
			
			Bootstrap bootstrapUDP = new Bootstrap();
			bootstrapUDP.group(workerGroup)
			    .channel(EpollDatagramChannel.class)
			    .localAddress(localAddress)
			    .option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT)
			    .handler(new Test());
	        
			serverSocketChannel = bootstrapUDP.bind().sync().channel();

			UDPSignallingServer.isRunning.set(true);

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

	private static class Test extends SimpleChannelInboundHandler<DatagramPacket> {

		private static final Map<InetAddress, byte[]> socks = new ConcurrentHashMap<>();

		@Override
		public void channelRead0(ChannelHandlerContext ctx, DatagramPacket packet) throws Exception {
			LOGGER.debug("Packet received");
			InetAddress address = packet.sender().getAddress();
			ByteBuf content = packet.content();

			byte[] secretKey = socks.get(packet.sender().getAddress());
			ByteBuf decryptedContent;
			{
				ByteBuf encryptedContent = content.slice();
				byte[] a = new byte[encryptedContent.readableBytes()];
				encryptedContent.readBytes(a);
				byte[] b = AESKeyGenerator.decrypt(new SecretKeySpec(secretKey, "AES"), a);

				decryptedContent = ctx.alloc().ioBuffer();
				decryptedContent.writeBytes(b);
			}

			int chatSessionID = content.readInt();

			List<ClientInfo> activeMembers = ActiveChatSessions.getChatSession(chatSessionID).getActiveMembers();
			Optional<ClientInfo> a = activeMembers.stream().filter((ClientInfo clientInfo) -> clientInfo.getInetAddress().equals(address)).findFirst();
			if (!a.isPresent()) {
				LOGGER.debug("USER NOT PART OF CHAT SESSION");
				return;
			}

			ClientInfo initiator = a.get();

//			List<InetSocketAddress> recipients = activeMembers.stream().map((ClientInfo clientInfo) -> {
//				return clientInfo.getInetSocketAddress();
//			}).toList();

			ByteBuf payload = ctx.alloc().ioBuffer();
			payload.writeInt(ServerMessageType.VOICE_CALL_INCOMING.id);
			payload.writeInt(packet.sender().getPort());
			payload.writeInt(chatSessionID);
			payload.writeInt(initiator.getClientID());
			payload.writeBytes(secretKey);

			for (ClientInfo activeMember : activeMembers) {
				if (activeMember.getClientID() == initiator.getClientID()) {
					continue;
				}

				activeMember.getChannel().writeAndFlush(payload);
			}

			LOGGER.debug("Voice chat added");
		}
	}

	public static byte[] createVoiceChat(InetAddress address) {
		var a = AESKeyGenerator.genereateRawSecretKey();
		Test.socks.put(address, a);
		return a;
	}

	public static void stop() {
		if (!UDPSignallingServer.isRunning.get()) {
			throw new IllegalStateException("Server has not started therefore cannot be stopped");
		}

		workerGroup.shutdownGracefully();

		UDPSignallingServer.isRunning.set(false);

		LOGGER.info("Server stopped succesfully on port {} and at address {}",
				((InetSocketAddress) serverSocketChannel.localAddress()).getHostName(),
				((InetSocketAddress) serverSocketChannel.localAddress()).getPort());

		LOGGER.info("Stopped waiting for incoming calls");
	}
}


