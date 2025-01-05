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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
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
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManagerFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;
import com.google.common.collect.Lists;

import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.server.codec.Encoder;
import github.koukobin.ermis.server.main.java.server.codec.PrimaryDecoder;
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.buffer.Unpooled;
import io.netty.channel.Channel;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.ChannelPipeline;
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
import io.netty.handler.ssl.SslHandler;
import io.netty.handler.ssl.SslProvider;
import io.netty.handler.ssl.SupportedCipherSuiteFilter;
import io.netty.handler.ssl.ApplicationProtocolConfig.Protocol;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectedListenerFailureBehavior;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectorFailureBehavior;
import io.netty.util.CharsetUtil;

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
				.option(ChannelOption.SO_BACKLOG, ServerSettings.SERVER_BACKLOG)
				.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, ServerSettings.CONNECT_TIMEOUT_MILLIS)
	            .handler(new Test());
	        
			serverSocketChannel = bootstrapUDP.bind().sync().channel();

			ServerUDP.isRunning.set(true);

			InetSocketAddress serverAddress = (InetSocketAddress) serverSocketChannel.localAddress();

			LOGGER.info("UDP Server started succesfully on port {} and at address {}", serverAddress.getPort(),
					serverAddress.getHostName());
			LOGGER.info("Waiting for incoming calls...");
		}  catch (Exception e) {
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
    	
    	private static final Map<Integer, List<InetAddress>> calls = new ConcurrentHashMap<>();
    	
        @Override
        public void channelRead0(ChannelHandlerContext ctx, DatagramPacket packet) throws Exception {
			LOGGER.debug("Packet received");
			ByteBuf content = packet.content();
			
			int chatSessionID = content.readInt();
			List<InetAddress> recipients = calls.get(chatSessionID);
        	if (recipients == null || !recipients.contains(packet.sender().getAddress())) {
        		return;
        	}
        	
        	ByteBuf contentBytes = content.slice();
        	contentBytes.retain(recipients.size());
        	
        	contentBytes.markReaderIndex();
        	byte[] contentBytes2 = new byte[contentBytes.readableBytes()];
        	contentBytes.readBytes(contentBytes2);
        	contentBytes.resetReaderIndex();
        	
            Path outputPath = Paths.get("/home/ilias/test.wav");
        	if (!Files.exists(outputPath)) {
        		// Write WAV header for the first time
        		try (OutputStream os = Files.newOutputStream(outputPath, StandardOpenOption.CREATE)) {
        			os.write(createWavHeader(44100, 2, 16)); // Adjust parameters as needed
        		}
        	}
        	// Append raw PCM data
        	Files.write(outputPath, contentBytes2, StandardOpenOption.APPEND);

			for (InetAddress recipientAddress : recipients) {
				LOGGER.debug("Transmitting UDP message to address: {}", packet.sender());
				DatagramPacket responsePacket = new DatagramPacket(contentBytes.copy(), packet.sender());
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

	
	public static int addClientToVoiceChat(int chatSessionID, InetAddress socketAddress) {
		Test.calls.get(chatSessionID).add(socketAddress);
		return chatSessionID;
	}
	
	public static int addVoiceChat(int chatSessionID, InetAddress socketAddress) {
		Test.calls.put(chatSessionID, Lists.newArrayList(socketAddress));
		return chatSessionID;
	}
	
	public static void stop() {
		if (!ServerUDP.isRunning.get()) {
			throw new IllegalStateException("Server has not started therefore cannot be stopped");
		}

		workerGroup.shutdownGracefully();

		ServerUDP.isRunning.set(false);
		
		LOGGER.info("Server stopped succesfully on port {} and at address {}",
				((InetSocketAddress) serverSocketChannel.localAddress()).getHostName(), ((InetSocketAddress) serverSocketChannel.localAddress()).getPort());

		LOGGER.info("Stopped waiting for incoming calls");
	}
}



