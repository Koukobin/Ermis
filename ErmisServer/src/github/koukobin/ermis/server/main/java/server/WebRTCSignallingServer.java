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
package github.koukobin.ermis.server.main.java.server;

import static io.netty.handler.codec.http.HttpHeaderNames.CONNECTION;
import static io.netty.handler.codec.http.HttpHeaderNames.CONTENT_TYPE;
import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;

import java.io.File;
import java.io.RandomAccessFile;
import java.net.URI;

import javax.net.ssl.SSLEngine;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.Unpooled;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.epoll.EpollEventLoopGroup;
import io.netty.channel.epoll.EpollServerSocketChannel;
import io.netty.channel.group.ChannelGroup;
import io.netty.channel.group.DefaultChannelGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.DefaultHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaderValues;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.codec.http.HttpUtil;
import io.netty.handler.codec.http.LastHttpContent;
import io.netty.handler.codec.http.websocketx.TextWebSocketFrame;
import io.netty.handler.codec.http.websocketx.WebSocketFrame;
import io.netty.handler.codec.http.websocketx.WebSocketServerProtocolHandler;
import io.netty.handler.ssl.SslHandler;
import io.netty.handler.stream.ChunkedFile;
import io.netty.handler.stream.ChunkedWriteHandler;
import io.netty.util.CharsetUtil;
import io.netty.util.concurrent.GlobalEventExecutor;

/**
 * @author Ilias Koukovinis
 *
 */
public class WebRTCSignallingServer {

	private static final Logger LOGGER;

	private static final ClientConnector connector;

	static {
		LOGGER = LogManager.getLogger("server");
		connector = new ClientConnector();
	}

	public static void run() throws InterruptedException {
		// Configure the server.
		EpollEventLoopGroup bossGroup = new EpollEventLoopGroup(1);
		EpollEventLoopGroup workerGroup = new EpollEventLoopGroup(1);
		try {
			ServerBootstrap b = new ServerBootstrap();

			b.group(bossGroup, workerGroup)
				.channel(EpollServerSocketChannel.class)
				.childHandler(connector);

			Channel ch = b.bind(ServerSettings.SERVER_ADDRESS, ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT).sync().channel();
			LOGGER.info("Secure Server running on https://{}:{}", ServerSettings.SERVER_ADDRESS, ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT);
			ch.closeFuture().sync();
		} finally {
			bossGroup.shutdownGracefully();
			workerGroup.shutdownGracefully();
		}
	}

	private static class ClientConnector extends ChannelInitializer<SocketChannel> {
		@Override
		protected void initChannel(SocketChannel ch) {
			ChannelPipeline p = ch.pipeline();

			// If SSL is enabled we add SSL handler first to encrypt and decrypt everything.
			// P.S I forgot to add the if statement
			SSLEngine engine = SslContextProvider.sslContext.newEngine(ch.alloc());
			engine.setUseClientMode(false);
			p.addLast("ssl", new SslHandler(engine));

			// Add HTTP server codec (combination of HttpRequestDecoder and
			// HttpResponseEncoder).
			p.addLast(new HttpServerCodec());

			// Aggregate an HttpMessage and its following HttpContents into a single
			// FullHttpRequest or FullHttpResponse.
			p.addLast(new HttpObjectAggregator(65536));

			// Support writing a large data stream asynchronously.
			p.addLast(new ChunkedWriteHandler());

			// Custom handler: Route requests either to static file serving or to WebSocket.
			p.addLast(new HttpRequestHandler("/ws"));

			// If upgrade is requested to WebSocket at /ws, this handler will take care of
			// handshake.
			p.addLast(new WebSocketServerProtocolHandler("/ws"));

			// WebSocket frame handler that performs the signaling broadcast.
			p.addLast(new WebSocketFrameHandler());
		}
	}

	private static class HttpRequestHandler extends SimpleChannelInboundHandler<FullHttpRequest> {

		private final String wsUri;

		public HttpRequestHandler(String wsUri) {
			this.wsUri = wsUri;
		}

		@Override
		protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest request) throws Exception {
			if (wsUri.equalsIgnoreCase(request.uri())) {
				// If the request is for /ws, pass it along.
				ctx.fireChannelRead(request.retain());
			} else {
				// Serve static file (index.html) for any other request.
				if (HttpUtil.is100ContinueExpected(request)) {
					send100Continue(ctx);
				}

				// Assuming index.html is located in the "public" folder in your working
				// directory.
				File file = new File(new URI("file:////index.html"));
				System.out.println("Exists: " + file.exists());
				if (!file.exists() || file.isHidden()) {
					sendError(ctx, HttpResponseStatus.NOT_FOUND);
					return;
				}

				if (HttpUtil.is100ContinueExpected(request)) {
					send100Continue(ctx);
				}

				RandomAccessFile raf = new RandomAccessFile(file, "r");
				long fileLength = raf.length();

				HttpResponse response = new DefaultHttpResponse(HTTP_1_1, HttpResponseStatus.OK);
				HttpUtil.setContentLength(response, fileLength);
				setContentTypeHeader(response, file);
				if (HttpUtil.isKeepAlive(request)) {
					response.headers().set(CONNECTION, HttpHeaderValues.KEEP_ALIVE);
				}
				ctx.write(response);

				// Use ChunkedFile instead of DefaultFileRegion
				ChannelFuture sendFileFuture = ctx.write(new ChunkedFile(raf), ctx.newProgressivePromise());
				ChannelFuture lastContentFuture = ctx.writeAndFlush(LastHttpContent.EMPTY_LAST_CONTENT);

				// Optionally add a listener to close the connection if Keep-Alive is not set.
				if (!HttpUtil.isKeepAlive(request)) {
					lastContentFuture.addListener(ChannelFutureListener.CLOSE);
				}
			}
		}

		private static void send100Continue(ChannelHandlerContext ctx) {
			FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1, HttpResponseStatus.CONTINUE);
			ctx.writeAndFlush(response);
		}

		private static void sendError(ChannelHandlerContext ctx, HttpResponseStatus status) {
			FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1, status,
					Unpooled.copiedBuffer("Failure: " + status + "\r\n", CharsetUtil.UTF_8));
			response.headers().set(CONTENT_TYPE, "text/plain; charset=UTF-8");
			ctx.writeAndFlush(response).addListener(ChannelFutureListener.CLOSE);
		}

		private static void setContentTypeHeader(HttpResponse response, File file) {
			// Simple content type mapping based on file extension.
			String name = file.getName();
			if (name.endsWith(".html")) {
				response.headers().set(CONTENT_TYPE, "text/html; charset=UTF-8");
			} else if (name.endsWith(".css")) {
				response.headers().set(CONTENT_TYPE, "text/css; charset=UTF-8");
			} else if (name.endsWith(".js")) {
				response.headers().set(CONTENT_TYPE, "application/javascript");
			} else {
				response.headers().set(CONTENT_TYPE, "application/octet-stream");
			}
		}
	}

	private static class WebSocketFrameHandler extends SimpleChannelInboundHandler<WebSocketFrame> {

		// A thread-safe channel group to maintain active WebSocket connections.
		private static final ChannelGroup channels = new DefaultChannelGroup(GlobalEventExecutor.INSTANCE);

		@Override
		public void handlerAdded(ChannelHandlerContext ctx) throws Exception {
			channels.add(ctx.channel());
		}

		@Override
		public void handlerRemoved(ChannelHandlerContext ctx) throws Exception {
			channels.remove(ctx.channel());
		}

		@Override
		protected void channelRead0(ChannelHandlerContext ctx, WebSocketFrame frame) throws Exception {
			// Only handle text frames.
			if (frame instanceof TextWebSocketFrame textwebsocketframe) {
				String message = textwebsocketframe.text();
				// Broadcast the message to every channel except the sender.
				for (Channel ch : channels) {
					if (ch != ctx.channel()) {
						ch.writeAndFlush(new TextWebSocketFrame(message));
					}
				}
			} else {
				// Close the connection if a binary or other frame is received.
				System.err.println("Unsupported frame received: " + frame.getClass().getName());
				ctx.channel().close();
			}
		}

		@Override
		public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
			cause.printStackTrace();
			ctx.close();
		}
	}
}