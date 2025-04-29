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

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.message_types.VoiceCallMessageType;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.util.AESKeyGenerator;
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

/**
 * @author Ilias Koukovinis
 *
 */
public final class VoiceCallSignallingServer {

	private static final Logger LOGGER;
	
	private static Channel serverSocketChannel;

	private static EpollEventLoopGroup workerGroup;
	
	private static AtomicBoolean isRunning;

	private VoiceCallSignallingServer() throws IllegalAccessException {
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
		if (VoiceCallSignallingServer.isRunning.get()) {
			throw new IllegalStateException("Server cannot start since the server is already running");
		}
		
		try {
			InetSocketAddress localAddress = new InetSocketAddress(ServerSettings.SERVER_ADDRESS, ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT);
			
			Bootstrap bootstrapUDP = new Bootstrap();
			bootstrapUDP.group(workerGroup)
			    .channel(EpollDatagramChannel.class)
			    .localAddress(localAddress)
			    .option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT)
			    .handler(new Test());
	        
			serverSocketChannel = bootstrapUDP.bind().sync().channel();

			VoiceCallSignallingServer.isRunning.set(true);

			InetSocketAddress serverAddress = (InetSocketAddress) serverSocketChannel.localAddress();

			LOGGER.info("UDP Server started successfully on port {} and at address {}", serverAddress.getPort(),
					serverAddress.getHostName());
			LOGGER.info("Waiting for incoming calls...");
		} catch (Exception e) {
			throw new RuntimeException("Failed to start UDP Signalling Server", e);
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

		private static final Map<InetAddress, byte[]> calls2 = new ConcurrentHashMap<>();
		private static final Map<Integer, InetSocketAddress> calls3 = new ConcurrentHashMap<>();

		@Override
		public void channelRead0(ChannelHandlerContext ctx, DatagramPacket packet) throws Exception {
			LOGGER.debug("Packet received");
			InetAddress address = packet.sender().getAddress();
			final int port = packet.sender().getPort();

			ByteBuf content;
			{
				ByteBuf encryptedContent = packet.content();

				byte[] array = new byte[encryptedContent.readableBytes()];
				encryptedContent.readBytes(array);
				byte[] decrypted = AESKeyGenerator.decrypt(calls2.get(packet.sender().getAddress()), Arrays.copyOfRange(array, 0, 12), Arrays.copyOfRange(array, 12, array.length));

				content = Unpooled.wrappedBuffer(decrypted);
			}
			int clientID = content.readInt();

			List<ClientInfo> z = ActiveClients.getClient(clientID).stream().filter((ClientInfo ci) -> ci.getInetAddress().equals(address)).toList();

			if (z.isEmpty()) {
				LOGGER.debug("USER NOT AUTHORIZED!");
			}

			int chatSessionID = content.readInt();

			if (z.get(0).getChatSessions().stream().noneMatch((ChatSession session) -> session.getChatSessionID() == chatSessionID)) {
				LOGGER.debug("USER NOT PART OF CHAT SESSION");
			}

			List<ClientInfo> activeMembers = ActiveChatSessions.getChatSession(chatSessionID).getActiveMembers();

			calls3.put(clientID, packet.sender());

			{
				ByteBuf payload = ctx.alloc().ioBuffer();
				payload.writeInt(ServerMessageType.VOICE_CALLS.id);
				payload.writeInt(VoiceCallMessageType.USER_JOINED_VOICE_CALL.id);
				payload.writeInt(clientID);
				payload.writeInt(chatSessionID);
				payload.writeInt(port);
				payload.writeBytes(address.getAddress());

				for (ClientInfo ci : activeMembers) {
					if (ci.getClientID() == clientID) continue;
					payload.retain();
					System.out.println(ci.getClientID());
					System.out.println(String.format("%d -> %d", clientID, ci.getClientID()));
					ci.getChannel().writeAndFlush(payload.duplicate());
				}

				payload.retain();
			}

			{
				for (ClientInfo ci : activeMembers) {
					InetSocketAddress ciSocketAdress = calls3.get(ci.getClientID());
					if (ciSocketAdress == null || ci.getClientID() == clientID) continue;
					ByteBuf payload = ctx.alloc().ioBuffer();
					payload.writeInt(ServerMessageType.VOICE_CALLS.id);
					payload.writeInt(VoiceCallMessageType.USER_JOINED_VOICE_CALL.id);
					payload.writeInt(ci.getClientID());
					payload.writeInt(chatSessionID);
					payload.writeInt(ciSocketAdress.getPort());
					payload.writeBytes(ciSocketAdress.getAddress().getAddress());

					System.out.println(String.format("%d -> %d", ci.getClientID(), clientID));
					ActiveClients.forActiveAccounts(clientID, (ClientInfo activeAccount) -> {
						activeAccount.getChannel().writeAndFlush(payload);
					});
				}
			}

			LOGGER.debug("Success");
		}
	}

	public static byte[] createVoiceChat(int chatSessionID) {
		var rawSecretKey = AESKeyGenerator.generateRawSecretKey();
		List<ClientInfo> activemembers = ActiveChatSessions.getChatSession(chatSessionID).getActiveMembers();
		for (ClientInfo client : activemembers) {
			Test.calls2.put(client.getInetAddress(), rawSecretKey);
		}
		return rawSecretKey;
	}

	public static void stop() {
		if (!VoiceCallSignallingServer.isRunning.get()) {
			throw new IllegalStateException("Server has not started therefore cannot be stopped");
		}

		workerGroup.shutdownGracefully();

		VoiceCallSignallingServer.isRunning.set(false);

		LOGGER.info("Server stopped succesfully on port {} and at address {}",
				((InetSocketAddress) serverSocketChannel.localAddress()).getHostName(),
				((InetSocketAddress) serverSocketChannel.localAddress()).getPort());

		LOGGER.info("Stopped waiting for incoming calls");
	}
}


