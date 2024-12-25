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
import java.net.InetSocketAddress;
import java.security.KeyStore;
import java.util.Arrays;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManagerFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.codec.Encoder;
import github.koukobin.ermis.server.main.java.server.codec.PrimaryDecoder;
import github.koukobin.ermis.server.main.java.server.codec.SimpleDecoder;
import github.koukobin.ermis.server.main.java.server.netty_handlers.DispatcherHandler;
import github.koukobin.ermis.server.main.java.server.netty_handlers.MessageRateLimiter;
import github.koukobin.ermis.server.main.java.server.netty_handlers.StartingEntryHandler;
import github.koukobin.ermis.server.main.java.server.util.EmailerService;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.epoll.EpollEventLoopGroup;
import io.netty.channel.epoll.EpollServerSocketChannel;
import io.netty.channel.epoll.EpollSocketChannel;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpRequestDecoder;
import io.netty.handler.codec.http.HttpResponseEncoder;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.handler.ssl.ApplicationProtocolConfig;
import io.netty.handler.ssl.ApplicationProtocolConfig.Protocol;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectedListenerFailureBehavior;
import io.netty.handler.ssl.ApplicationProtocolConfig.SelectorFailureBehavior;
import io.netty.handler.ssl.ApplicationProtocolNames;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.SslHandler;
import io.netty.handler.ssl.SslProvider;
import io.netty.handler.ssl.SupportedCipherSuiteFilter;
import io.netty.util.CharsetUtil;
import io.netty.util.internal.logging.InternalLoggerFactory;
import io.netty.util.internal.logging.Log4J2LoggerFactory;

/**
 * @author Ilias Koukovinis
 *
 */
public final class Server {

	private static final Logger LOGGER;

	private static EpollServerSocketChannel serverSocketChannel;

	private static EpollEventLoopGroup bossGroup;
	private static EpollEventLoopGroup workerGroup;

	private static ClientConnector clientConnector;

	private static AtomicBoolean isRunning;

	private Server() throws IllegalAccessException {
		throw new IllegalAccessException("Server cannot be constructed since it is statically initialized!");
	}

	static {
		LOGGER = LogManager.getLogger("server");
		InternalLoggerFactory.setDefaultFactory(Log4J2LoggerFactory.INSTANCE);
	}

	static {
		try {
			LOGGER.info("Initializing...");

			EmailerService.initialize();
			ErmisDatabase.initialize();

			bossGroup = new EpollEventLoopGroup(1, (Runnable r) -> new Thread(r, "Thread-ClientConnector"));
			workerGroup = new EpollEventLoopGroup(ServerSettings.WORKER_THREADS);

			clientConnector = new ClientConnector();

			isRunning = new AtomicBoolean(false);
		} catch (Exception e) {
			LOGGER.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException(e);
		}
	}

	public static void start() {

		if (Server.isRunning.get()) {
			throw new IllegalStateException("Server cannot start since the server is already running");
		}
		
		try {
			
			InetSocketAddress localAddress = new InetSocketAddress(ServerSettings.SERVER_ADDRESS, ServerSettings.SERVER_PORT);
			
			ServerBootstrap bootstrapTCP = new ServerBootstrap();
			bootstrapTCP.group(bossGroup, workerGroup)
				.channel(EpollServerSocketChannel.class)
				.childHandler(clientConnector)
				.localAddress(localAddress)
				.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT)
				.option(ChannelOption.SO_BACKLOG, ServerSettings.SERVER_BACKLOG)
				.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, ServerSettings.CONNECT_TIMEOUT_MILLIS)
				.childOption(ChannelOption.SO_KEEPALIVE, true);
			
			// If server isn't production ready we add a logging handler for more detailed logging
			if (!ServerSettings.IS_PRODUCTION_READY) {
				bootstrapTCP.handler(new LoggingHandler(LogLevel.INFO));
			}

			serverSocketChannel = (EpollServerSocketChannel) bootstrapTCP.bind().sync().channel();

			Server.isRunning.set(true);

			InetSocketAddress socketAddress = serverSocketChannel.localAddress();

			LOGGER.info("Server started succesfully on port {} and at address {}", socketAddress.getPort(),
					socketAddress.getHostName());
			LOGGER.info("Waiting for new connections...");
		} catch (Exception e) {
			LOGGER.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException("Failed to start TCP server", e);
		}

		ServerUDP.start();
	}

	private static class ClientConnector extends ChannelInitializer<EpollSocketChannel> {

		private static final SslContext sslContext;

		static {
			try {

				char[] certificatePassword = ServerSettings.SSL.CERTIFICATE_PASSWORD.toCharArray();

				KeyStore ks = KeyStore.getInstance(ServerSettings.SSL.CERTIFICATE_TYPE);
				ks.load(new FileInputStream(ServerSettings.SSL.CERTIFICATE_LOCATION), certificatePassword);

				KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
				kmf.init(ks, certificatePassword);

				TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
				tmf.init(ks);

				sslContext = SslContextBuilder.forServer(kmf)
						.trustManager(tmf)
						.protocols(ServerSettings.SSL.getEnabledProtocols())
						.sslProvider(SslProvider.OPENSSL)
						.ciphers(Arrays.asList(ServerSettings.SSL.getEnabledCipherSuites()), SupportedCipherSuiteFilter.INSTANCE)
						.applicationProtocolConfig(
								new ApplicationProtocolConfig(Protocol.ALPN, SelectorFailureBehavior.NO_ADVERTISE,
										SelectedListenerFailureBehavior.ACCEPT, ApplicationProtocolNames.HTTP_1_1))
						.build();
			} catch (Exception e) {
				LOGGER.fatal(Throwables.getStackTraceAsString(e));
				throw new RuntimeException(e);
			}
		}

		@Override
		public void initChannel(EpollSocketChannel ch) {

			ChannelPipeline pipeline = ch.pipeline();

			// If SSL is enabled we add SSL handler first to encrypt and decrypt everything.
			// P.S I forgot to add the if statement
			SSLEngine engine = sslContext.newEngine(ch.alloc());
			engine.setUseClientMode(false);
			pipeline.addLast("ssl", new SslHandler(engine));

			// Add protocol detector (a custom handler to detect HTTP or custom protocol)
			pipeline.addLast("protocolDetector", new ProtocolDetectorHandler());
		}

		public static class ProtocolDetectorHandler extends ChannelInboundHandlerAdapter {
			@Override
			public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
				ByteBuf byteBuf = (ByteBuf) msg;
				String message = byteBuf.toString(CharsetUtil.UTF_8);

				// Simple detection of HTTP request (e.g., starts with "GET" or "POST")
				if (message.startsWith("GET") || message.startsWith("POST")) {
					// If it's HTTP, pass it to the HTTP pipeline
					ctx.pipeline().addLast("httpDecoder", new HttpRequestDecoder());
					ctx.pipeline().addLast("httpAggregator", new HttpObjectAggregator(1048576));
					ctx.pipeline().addLast("httpEncoder", new HttpResponseEncoder());
					ctx.pipeline().addLast("httpHandler", new HttpStaticFileServerHandler());

					ctx.fireChannelRead(msg);
				} else {
					ctx.pipeline().addLast("decoder", new PrimaryDecoder());
					ctx.pipeline().addLast("encoder", new Encoder());

					ClientInfo clientInfo = new ClientInfo();
					clientInfo.setChannel(ctx.channel());

					ctx.pipeline().addLast(MessageRateLimiter.class.getName(), new MessageRateLimiter());
					ctx.pipeline().addLast(DispatcherHandler.class.getName(), new DispatcherHandler());
					ctx.pipeline().addLast(StartingEntryHandler.class.getName(), new StartingEntryHandler(clientInfo));
				}

				ctx.pipeline().remove(this);
			}

			@Override
			public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
				LOGGER.debug(Throwables.getStackTraceAsString(cause));
			}
		}

	}

	public static void stop() {

		if (!Server.isRunning.get()) {
			throw new IllegalStateException("Server has not started therefore cannot be stopped");
		}

		workerGroup.shutdownGracefully();
		bossGroup.shutdownGracefully();

		Server.isRunning.set(false);

		LOGGER.info("Server stopped succesfully on port {} and at address {}",
				serverSocketChannel.localAddress().getHostName(), serverSocketChannel.localAddress().getPort());

		LOGGER.info("Stopped waiting for new connections...");
	}
}

