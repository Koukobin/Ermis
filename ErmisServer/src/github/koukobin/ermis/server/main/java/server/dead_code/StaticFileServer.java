/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
package github.koukobin.ermis.server.main.java.server.dead_code;

/**
 * @author Ilias Koukovinis
 *
 */
class StaticFileServer {

//	private static final Logger LOGGER;
//
//	private static EpollServerSocketChannel serverSocketChannel;
//	private static EpollEventLoopGroup group;
//
//	private static ClientConnector clientConnector;
//
//	private static AtomicBoolean isRunning;
//
//	private StaticFileServer() throws IllegalAccessException {
//		throw new IllegalAccessException("StaticFileServer cannot be constructed since it is statically initialized!");
//	}
//
//	static {
//		LOGGER = LogManager.getLogger("server");
//		InternalLoggerFactory.setDefaultFactory(Log4J2LoggerFactory.INSTANCE);
//	}
//
//	static {
//		try {
//			LOGGER.info("Initializing...");
//
//			group = new EpollEventLoopGroup(1);
//			clientConnector = new ClientConnector();
//
//			isRunning = new AtomicBoolean(false);
//		} catch (Exception e) {
//			LOGGER.fatal(Throwables.getStackTraceAsString(e));
//			throw new RuntimeException(e);
//		}
//	}
//
//	public static void start() {
//		if (isRunning.get()) {
//			throw new IllegalStateException("Static file server cannot start since the server is already running");
//		}
//		
//		try {
//			InetSocketAddress localAddress = new InetSocketAddress(ServerSettings.SERVER_ADDRESS, 9090);
//			
//			ServerBootstrap bootstrapTCP = new ServerBootstrap();
//			bootstrapTCP.group(group)
//				.channel(EpollServerSocketChannel.class)
//				.childHandler(clientConnector)
//				.localAddress(localAddress)
//				.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT)
//				.option(ChannelOption.SO_BACKLOG, ServerSettings.SERVER_BACKLOG)
//				.option(ChannelOption.CONNECT_TIMEOUT_MILLIS, ServerSettings.CONNECT_TIMEOUT_MILLIS)
//				.childOption(ChannelOption.SO_KEEPALIVE, true);
//
//			// If server isn't production ready we add a logging handler for more detailed logging
//			if (!ServerSettings.IS_PRODUCTION_READY) {
//				bootstrapTCP.handler(new LoggingHandler(LogLevel.INFO));
//				ResourceLeakDetector.setLevel(ResourceLeakDetector.Level.ADVANCED);
//			}
//
//			serverSocketChannel = (EpollServerSocketChannel) bootstrapTCP.bind().sync().channel();
//
//			isRunning.set(true);
//
//			InetSocketAddress serverAddress = serverSocketChannel.localAddress();
//
//			LOGGER.info("Static file server started successfully on port {} and at address {}", serverAddress.getPort(),
//					serverAddress.getHostName());
//		} catch (Exception e) {
//			LOGGER.fatal(Throwables.getStackTraceAsString(e));
//			throw new RuntimeException("Failed to start Static file server", e);
//		}
//	}
//
//	private static class ClientConnector extends ChannelInitializer<EpollSocketChannel> {
//
//		private static final SslContext sslContext;
//
//		static {
//			try {
//				char[] certificatePassword = ServerSettings.SSL.CERTIFICATE_PASSWORD.toCharArray();
//
//				KeyStore ks = KeyStore.getInstance(ServerSettings.SSL.CERTIFICATE_TYPE);
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
//				LOGGER.fatal(Throwables.getStackTraceAsString(e));
//				throw new RuntimeException(e);
//			}
//		}
//
//		@Override
//		public void initChannel(EpollSocketChannel ch) {
//			ChannelPipeline pipeline = ch.pipeline();
//
//			// If SSL is enabled we add SSL handler first to encrypt and decrypt everything.
//			// P.S I forgot to add the if statement
//			SSLEngine engine = sslContext.newEngine(ch.alloc());
//			engine.setUseClientMode(false);
//			pipeline.addLast("ssl", new SslHandler(engine));
//			pipeline.addLast("protocolDetector", new ProtocolDetectorHandler());
//		}
//
//		private static class ProtocolDetectorHandler extends ChannelInboundHandlerAdapter {
//			@Override
//			public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
//				try {
//					ByteBuf byteBuf = (ByteBuf) msg;
//					String message = byteBuf.toString(CharsetUtil.UTF_8);
//
//					// Simple detection of HTTP request (e.g., starts with "GET" or "POST")
//					if (message.startsWith("GET") || message.startsWith("POST")) {
//						// If it's HTTP, pass it to the HTTP pipeline
//						ctx.pipeline().addLast("httpDecoder", new HttpRequestDecoder());
//						ctx.pipeline().addLast("httpAggregator", new HttpObjectAggregator(1048576));
//						ctx.pipeline().addLast("httpEncoder", new HttpResponseEncoder());
//
//						// Handlers
//						ctx.pipeline().addLast("httpHandler", new HttpStaticFileServerHandler());
//						ctx.fireChannelRead(msg);
//					}
//				} finally {
//					ctx.pipeline().remove(this);
//				}
//			}
//
//			@Override
//			public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
//				LOGGER.debug(Throwables.getStackTraceAsString(cause));
//			}
//		}
//
//	}
//
//	public static void stop() {
//		if (!isRunning.get()) {
//			throw new IllegalStateException("Static file server has not started therefore cannot be stopped");
//		}
//
//		group.shutdownGracefully();
//		isRunning.set(false);
//
//		LOGGER.info("Static file server stopped succesfully on port {} and at address {}",
//				serverSocketChannel.localAddress().getHostName(), serverSocketChannel.localAddress().getPort());
//	}
}
