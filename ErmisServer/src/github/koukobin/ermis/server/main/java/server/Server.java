/* Copyright (C) 2021-2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import java.net.InetSocketAddress;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLEngine;

import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.codec.Encoder;
import github.koukobin.ermis.server.main.java.server.codec.PrimaryDecoder;
import github.koukobin.ermis.server.main.java.server.netty_handlers.DispatcherHandler;
import github.koukobin.ermis.server.main.java.server.netty_handlers.MessageRateLimiter;
import github.koukobin.ermis.server.main.java.server.netty_handlers.StartingEntryHandler;
import github.koukobin.ermis.server.main.java.server.netty_handlers.commands.CommandsHolder;
import github.koukobin.ermis.server.main.java.server.util.EmailerService;
import github.koukobin.ermis.server.main.java.server.web_rtc_signalling_server.WebRTCSignallingServer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.MultiThreadIoEventLoopGroup;
import io.netty.channel.epoll.EpollIoHandler;
import io.netty.channel.epoll.EpollServerSocketChannel;
import io.netty.channel.epoll.EpollSocketChannel;
import io.netty.handler.ssl.SslHandler;
import io.netty.util.ResourceLeakDetector;
import io.netty.util.internal.logging.InternalLoggerFactory;
import io.netty.util.internal.logging.Log4J2LoggerFactory;

/**
 * @author Ilias Koukovinis
 *
 */
public final class Server {

	private static final Logger LOGGER;

	private static EpollServerSocketChannel serverSocketChannel;

	private static MultiThreadIoEventLoopGroup bossGroup;
	private static MultiThreadIoEventLoopGroup workerGroup;

	private static ClientConnector clientConnector;

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
			CommandsHolder.initialize();

			// Block scope leveraged to group related logic both visually and semantically
			{
				ThreadFactory bossGroupThreadFactory = (Runnable r) -> new Thread(r, "Thread-ClientConnector");
				bossGroup = new MultiThreadIoEventLoopGroup(1, bossGroupThreadFactory, EpollIoHandler.newFactory());
			}
			workerGroup = new MultiThreadIoEventLoopGroup(ServerSettings.WORKER_THREADS, EpollIoHandler.newFactory());

			/**
			 * WorkerGroup utilizing virtual threads alternatively:
			 * 
			 * <pre>
			 * workerGroup = new MultiThreadIoEventLoopGroup(
		     * 		ServerSettings.WORKER_THREADS,
			 * 		Thread.ofVirtual().factory(), 
			 * 		EpollIoHandler.newFactory()
			 * );
			 * </pre>
			 */

			clientConnector = new ClientConnector();
		} catch (Exception e) {
			LOGGER.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException(e);
		}
	}

	public static void start() {
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
				ResourceLeakDetector.setLevel(ResourceLeakDetector.Level.PARANOID);
			}

			serverSocketChannel = (EpollServerSocketChannel) bootstrapTCP.bind().sync().channel();
			InetSocketAddress serverAddress = serverSocketChannel.localAddress();

			LOGGER.info("Messaging Server started successfully on port {} and at address {}", serverAddress.getPort(),
					serverAddress.getHostName());
			LOGGER.info("Waiting for new connections...");

			Server.addNettyTerminationShutdownHook();
		} catch (Exception e) {
			LOGGER.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException("Failed to start Messaging Server", e);
		}

		try {
			WebRTCSignallingServer.run();
		} catch (Exception e) {
			LOGGER.fatal(Throwables.getStackTraceAsString(e));
			throw new RuntimeException("Failed to start WebRTC Signaling Server", e);
		}

		// Add two second delay before warning "server is running
		// in development mode" to ensure it is not obscured among
		// other console output
		try {
			TimeUnit.SECONDS.sleep(2);
			for (int i = 0; i < 10; i++) LOGGER.warn("WARNING: SERVER RUNNING IN DEVELOPMENT MODE");
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
		}
	}

	private static class ClientConnector extends ChannelInitializer<EpollSocketChannel> {

		@Override
		public void initChannel(EpollSocketChannel ch) {
			ChannelPipeline pipeline = ch.pipeline();

			// If SSL is enabled we add SSL handler first to encrypt and decrypt everything.
			// P.S I forgot to add the if statement
			SSLEngine engine = SslContextProvider.sslContext.newEngine(ch.alloc());
			engine.setUseClientMode(false);
			pipeline.addLast("ssl", new SslHandler(engine));

			addNormalPipeline(pipeline);
		}

		private static void addNormalPipeline(ChannelPipeline pipeline) {
			// Codec
			pipeline.addLast("decoder", new PrimaryDecoder());
			pipeline.addLast("encoder", new Encoder());

			// Handlers
			pipeline.addLast(MessageRateLimiter.class.getName(), new MessageRateLimiter());
			pipeline.addLast(DispatcherHandler.class.getName(), new DispatcherHandler());
			pipeline.addLast(StartingEntryHandler.class.getName(), new StartingEntryHandler());
		}
	}

	private static void addNettyTerminationShutdownHook() {
		Runtime.getRuntime().addShutdownHook(new Thread(() -> {
			workerGroup.shutdownGracefully();
			bossGroup.shutdownGracefully();

			// Logger not available in shutdown hook - use sysout instead
			System.out.println("Stopped waiting for new connections...");
		}));
	}
}
