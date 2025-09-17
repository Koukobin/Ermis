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
package github.koukobin.ermis.server.main.java.server.web_rtc_signalling_server;

import static io.netty.handler.codec.http.HttpHeaderNames.CONNECTION;
import static io.netty.handler.codec.http.HttpHeaderNames.CONTENT_TYPE;
import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;

import java.io.File;
import java.io.RandomAccessFile;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.URI;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.net.ssl.SSLEngine;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;
import com.google.common.collect.Lists;

import github.koukobin.ermis.common.message_types.ServerMessageType;
import github.koukobin.ermis.common.message_types.VoiceCallMessageType;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;
import github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.ErmisDatabase;
import github.koukobin.ermis.server.main.java.server.ActiveChatSessions;
import github.koukobin.ermis.server.main.java.server.ChatSession;
import github.koukobin.ermis.server.main.java.server.ClientInfo;
import github.koukobin.ermis.server.main.java.server.SslContextProvider;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.MultiThreadIoEventLoopGroup;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.epoll.EpollIoHandler;
import io.netty.channel.epoll.EpollServerSocketChannel;
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

/**
 * @author Ilias Koukovinis
 *
 */
public class WebRTCSignallingServer {

	private static final Logger LOGGER;
	private static final ClientInitializer connector;

	static {
		LOGGER = LogManager.getLogger("server");
		connector = new ClientInitializer();
	}

	private WebRTCSignallingServer() throws IllegalAccessException {
		throw new IllegalAccessException("WebRTCSignallingServer cannot be constructed since it is statically initialized!");
	}

	public static void run() throws InterruptedException {
		MultiThreadIoEventLoopGroup bossGroup = new MultiThreadIoEventLoopGroup(1, EpollIoHandler.newFactory());
		MultiThreadIoEventLoopGroup workerGroup = new MultiThreadIoEventLoopGroup(1, EpollIoHandler.newFactory());
		try {
			ServerBootstrap b = new ServerBootstrap();
			b.group(bossGroup, workerGroup)
				.channel(EpollServerSocketChannel.class)
				.childHandler(connector);

			Channel ch = b.bind(ServerSettings.SERVER_ADDRESS, ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT).sync().channel();
			LOGGER.info("WebRTC Signalling Server successfully debuted on https://{}:{}", ServerSettings.SERVER_ADDRESS, ServerSettings.VOICE_CALL_SIGNALLING_SERVER_PORT);
			ch.closeFuture().sync();
		} finally {
			bossGroup.shutdownGracefully();
			workerGroup.shutdownGracefully();
		}
	}

	private static class ClientInitializer extends ChannelInitializer<SocketChannel> {
		@Override
		protected void initChannel(SocketChannel ch) {
			ChannelPipeline p = ch.pipeline();

			// Add SSL handler first to encrypt and decrypt everything
			SSLEngine engine = SslContextProvider.sslContext.newEngine(ch.alloc());
			engine.setUseClientMode(false);
			p.addLast("ssl", new SslHandler(engine));

			// Add HTTP server codec
			p.addLast(new HttpServerCodec());

			// Aggregate an HttpMessage and its following HttpContents into a single
			// FullHttpRequest or FullHttpResponse
			p.addLast(new HttpObjectAggregator(65536));

			// Support writing a large data stream asynchronously.
			p.addLast(new ChunkedWriteHandler());

			// Route requests either to static file serving or to WebSocket (the former should be removed in the future)
			p.addLast(new HttpRequestHandler("/ws"));

			// If upgrade is requested to WebSocket at /ws, this handler will take care of
			// handshake
			p.addLast(new WebSocketServerProtocolHandler("/ws"));

			// Handler that performs WebRTC signalling
			p.addLast(new WebRTCSignallingHandler());
		}
	}

	/**
	 *
	 * Used solely for testing purposes on browser
	 * 
	 */
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
				File file = new File(new URI("file:///var/ermis-server/www/web_rtc_test.html"));
				if (!file.exists() || file.isHidden()) {
					sendError(ctx, HttpResponseStatus.NOT_FOUND);
					return;
				}

				if (HttpUtil.is100ContinueExpected(request)) {
					send100Continue(ctx);
				}

				try (RandomAccessFile raf = new RandomAccessFile(file, "r")) {
					long fileLength = raf.length();

					HttpResponse response = new DefaultHttpResponse(HTTP_1_1, HttpResponseStatus.OK);
					HttpUtil.setContentLength(response, fileLength);
					setContentTypeHeader(response, file);
					if (HttpUtil.isKeepAlive(request)) {
						response.headers().set(CONNECTION, HttpHeaderValues.KEEP_ALIVE);
					}
					ctx.write(response);

					// Use ChunkedFile instead of DefaultFileRegion
					@SuppressWarnings("unused")
					ChannelFuture sendFileFuture = ctx.write(new ChunkedFile(raf), ctx.newProgressivePromise());
					ChannelFuture lastContentFuture = ctx.writeAndFlush(LastHttpContent.EMPTY_LAST_CONTENT);

					// Optionally add a listener to close the connection if Keep-Alive is not set.
					if (!HttpUtil.isKeepAlive(request)) {
						lastContentFuture.addListener(ChannelFutureListener.CLOSE);
					}
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

	public static void addVoiceCall(ChatSession chatSession, int initiatorClientID) {
		int chatSessionID = chatSession.getChatSessionID();

		List<Channel> channelsList = Lists.newArrayList();
		for (ClientInfo member : chatSession.getActiveMembers()) {
			VoiceChatUser user = WebRTCSignallingHandler.addressToUsers.get(member.getInetAddress());

			if (user == null) {
				user = new VoiceChatUser(chatSessionID, member.getClientID());
				WebRTCSignallingHandler.addressToUsers.put(member.getInetAddress(), user);
			}
		}

		long tsDebuted = Instant.now().getEpochSecond();

		int voiceCallHistoryID;
		try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
			voiceCallHistoryID = conn.addActiveVoiceCall(tsDebuted, chatSessionID, initiatorClientID);
		}

		ActiveVoiceChat call = new ActiveVoiceChat(tsDebuted, voiceCallHistoryID, initiatorClientID, channelsList);
		WebRTCSignallingHandler.chatSessionIDToParticipants.put(chatSessionID, call);
	}

	public static boolean isVoiceCallAlreadyActive(int chatSessionID) {
		return WebRTCSignallingHandler.chatSessionIDToParticipants.get(chatSessionID) != null;
	}

	private static class WebRTCSignallingHandler extends SimpleChannelInboundHandler<WebSocketFrame> {

		private static final Map<InetAddress, VoiceChatUser> addressToUsers = new ConcurrentHashMap<>();
		private static final Map<Integer, ActiveVoiceChat> chatSessionIDToParticipants = new ConcurrentHashMap<>();

		private VoiceChatUser user;

		@Override
		public void handlerAdded(ChannelHandlerContext ctx) throws Exception {
			user = addressToUsers.get(getInetAddressOfChannel(ctx));
			user.channel = ctx.channel();

			ActiveVoiceChat call = chatSessionIDToParticipants.get(user.chatSessionID);
			call.activeChannels().add(user.channel);

			try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
				conn.addVoiceCallParticipant(call.voiceCallID(), user.clientID);
			}
		}

		@Override
		public void handlerRemoved(ChannelHandlerContext ctx) throws Exception {
			addressToUsers.remove(getInetAddressOfChannel(ctx));

			int chatSessionID = user.chatSessionID;
			ActiveVoiceChat call = chatSessionIDToParticipants.get(chatSessionID);

			List<Channel> activeChannels = call.activeChannels();
			activeChannels.remove(user.channel);

			if (activeChannels.isEmpty()) {
				chatSessionIDToParticipants.remove(chatSessionID);

				// Broadcast voice call cancellation to ensure that
				// any notification or screen associated with call is eliminated
				{
					ByteBuf payload = ctx.alloc().ioBuffer();
					payload.writeInt(ServerMessageType.VOICE_CALLS.id);
					payload.writeByte(VoiceCallMessageType.CANCEL_INCOMING_VOICE_CALL.id);
					payload.writeInt(chatSessionID);

					ActiveChatSessions.broadcastToChatSession(payload, chatSessionID);
				}

				long tsEnded = Instant.now().getEpochSecond();
				try (ErmisDatabase.GeneralPurposeDBConnection conn = ErmisDatabase.getGeneralPurposeConnection()) {
					conn.setEndedVoiceCall(tsEnded, call.voiceCallID());
				}
			}
		}

		private static InetAddress getInetAddressOfChannel(ChannelHandlerContext ctx) {
			return ((InetSocketAddress) ctx.channel().remoteAddress()).getAddress();
		}

		@Override
		protected void channelRead0(ChannelHandlerContext ctx, WebSocketFrame frame) throws Exception {
			// Only handle text frames
			if (frame instanceof TextWebSocketFrame textWebSocketFrame) {
				String message = textWebSocketFrame.text();
				// Broadcast the message to every other channel in call
				for (Channel ch : chatSessionIDToParticipants.get(user.chatSessionID).activeChannels()) {
					if (ch != ctx.channel()) {
						ch.writeAndFlush(new TextWebSocketFrame(message));
					}
				}
				return;
			}

			LOGGER.debug("Unsupported frame received: {}", frame.getClass().getName());
		}

		@Override
		public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
			LOGGER.debug(Throwables.getStackTraceAsString(cause));
			ctx.close();
		}
	}
}
