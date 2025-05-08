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
package github.koukobin.ermis.client.main.java.service.client;

import java.io.File;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;

import github.koukobin.ermis.client.main.java.database.models.LocalAccountInfo;
import github.koukobin.ermis.client.main.java.database.models.ServerInfo;
import github.koukobin.ermis.client.main.java.service.client.Events.EntryMessage;
import github.koukobin.ermis.client.main.java.service.client.io.ByteBufInputStream;
import github.koukobin.ermis.client.main.java.service.client.io.ByteBufOutputStream;
import github.koukobin.ermis.client.main.java.service.client.models.ChatRequest;
import github.koukobin.ermis.client.main.java.service.client.models.ChatSession;
import github.koukobin.ermis.client.main.java.service.client.models.EntryResult;
import github.koukobin.ermis.common.entry.AddedInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo;
import github.koukobin.ermis.common.entry.CreateAccountInfo.CredentialValidation;
import github.koukobin.ermis.common.entry.EntryType;
import github.koukobin.ermis.common.entry.GeneralEntryAction;
import github.koukobin.ermis.common.entry.LoginInfo;
import github.koukobin.ermis.common.entry.Resultable;
import github.koukobin.ermis.common.entry.LoginInfo.CredentialsExchange;
import github.koukobin.ermis.common.entry.Verification;
import github.koukobin.ermis.common.message_types.ClientMessageType;
import github.koukobin.ermis.common.results.ResultHolder;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;

/**
 * 
 * @author Ilias Koukovinis
 */
public class Client {

	private static ByteBufInputStream in;
	private static ByteBufOutputStream out;

	private static SSLSocket sslSocket;

	private static AtomicBoolean isLoggedIn = new AtomicBoolean(false);

	private static MessageTransmitter messageTransmitter;

	private static ServerInfo serverInfo;

	public enum ServerCertificateVerification {
		VERIFY, IGNORE
	}

	/** Don't let anyone else instantiate this class */
    private Client() {}

	public static void initialize(ServerInfo serverInfo, ServerCertificateVerification scv) throws ClientInitializationException {
		InetAddress remoteAddress = serverInfo.getAddress();
		int remotePort = serverInfo.getPort();

		if (remotePort <= 0) {
			throw new IllegalArgumentException("Port cannot be below zero");
		}

		try {
			KeyStore ks = KeyStore.getInstance("JKS");
			ks.load(null, null);

			KeyManagerFactory kmf = KeyManagerFactory.getInstance("SunX509");
			kmf.init(ks, null);

			TrustManager[] trustManagers = null;

			switch (scv) {
			case VERIFY -> {
				TrustManagerFactory tmf = TrustManagerFactory.getInstance("SunX509");
				tmf.init(ks);

				trustManagers = tmf.getTrustManagers();
			}
			case IGNORE -> {
				// Disable certificate validation
				trustManagers = new TrustManager[] { new X509TrustManager() {
					public X509Certificate[] getAcceptedIssuers() {
						return new X509Certificate[0];
					}

					@Override
					public void checkClientTrusted(X509Certificate[] certs, String authType) {
					}

					@Override
					public void checkServerTrusted(X509Certificate[] certs, String authType) {
					}
				} };
			}
			default -> throw new IllegalArgumentException("Unknown type: " + scv);
			}

			SSLContext sc = SSLContext.getInstance("TLSv1.3");
			sc.init(kmf.getKeyManagers(), trustManagers, new SecureRandom());

			SSLSocketFactory ssf = sc.getSocketFactory();
			sslSocket = (SSLSocket) ssf.createSocket(remoteAddress, remotePort);
			sslSocket.startHandshake();

			in = new ByteBufInputStream(sslSocket.getInputStream());
			out = new ByteBufOutputStream(sslSocket.getOutputStream());
		} catch (IOException | KeyStoreException | NoSuchAlgorithmException | CertificateException
				| UnrecoverableKeyException | KeyManagementException e) {
			throw new ClientInitializationException(e.getMessage());
		}

		Client.serverInfo = serverInfo;
	}
	
	  public static void syncWithServer() {
		  try {
			in.read();
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}

	public static void initiateMessageDispatcher() {
		Thread thread = new Thread("Thread-listenToMessages") {
			@Override
			public void run() {
				for (;;) {
					try {
						ByteBuf msg = in.read();
						GlobalMessageDispatcher.getDispatcher().dispatchMessage(msg);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
//				isClientListeningToMessages.set(false);
			}
		};
		thread.setDaemon(true);
		thread.start();
	}

    /**
     * Attempts to authenticate user by sending their email and password hash
     * over the network to the server for validation.
     * 
     * @param userInfo The local account information containing the user's email
     *                 and password hash.
     * @throws IOException 
     * @returns A CompletableFuture that resolves to a boolean indicating whether 
     *          the login attempt was successful.
     */
    public static boolean attemptHashedLogin(LocalAccountInfo userInfo) {
        ByteBuf buffer = Unpooled.buffer();
        buffer.writeInt(ClientMessageType.USER_ENTRY.id);
        buffer.writeInt(EntryType.LOGIN.id);

        // Email length and email
        buffer.writeInt(userInfo.getEmail().length());
        buffer.writeBytes(userInfo.getEmail().getBytes());

        // Password hash
        buffer.writeBytes(userInfo.getPasswordHash().getBytes());

        // Send the request
        try {
			out.write(buffer);
			isLoggedIn.set(in.read().readBoolean());
		} catch (IOException ioe) {
			ioe.printStackTrace(); // Should not happen
		}

        return isLoggedIn();
    }

	public static class Entry<T extends EntryType.CredentialInterface> {

		private final EntryType entryType;
		private boolean isVerificationComplete = false;

		private Entry(EntryType entryType) {
			if (isLoggedIn.get()) {
				throw new IllegalStateException("User is already logged in");
			}

			this.entryType = entryType;
		}

		public Resultable getResult() {
			EntryMessage msg = GlobalMessageDispatcher.getDispatcher()
					.observeMessages()
					.ofType(EntryMessage.class)
					.firstElement()
					.blockingGet();

			ByteBuf buffer = msg.getBuffer();
			
			int id = buffer.readInt();
			return entryType == EntryType.CREATE_ACCOUNT
		            ? CredentialValidation.Result.fromId(id)
		                    : CredentialsExchange.Result.fromId(id);
		}

		public void sendCredentials(Map<T, String> credentials) throws IOException {
			for (Map.Entry<T, String> credential : credentials.entrySet()) {
				int credentialInt = credential.getKey().id();
				byte[] credentialValueBytes = credential.getValue().getBytes();

				ByteBuf payload = Unpooled.buffer();
				payload.writeInt(ClientMessageType.USER_ENTRY.id);
				payload.writeInt(credentialInt);
				payload.writeBytes(credentialValueBytes);

				out.write(payload);
			}
		}

		public void sendEntryType() throws IOException {
			out.write(Unpooled.copyInt(ClientMessageType.USER_ENTRY.id, entryType.id));
		}

		public void sendVerificationCode(String verificationCode) throws IOException {
			ByteBuf payload = Unpooled.buffer();
			payload.writeInt(ClientMessageType.USER_ENTRY.id);
			payload.writeInt(Integer.valueOf(verificationCode));

			out.write(payload);
		}

		public EntryResult<Resultable> getVerificationResult() throws IOException {
			EntryMessage msg = GlobalMessageDispatcher.getDispatcher()
					.observeMessages()
					.ofType(EntryMessage.class)
					.firstElement()
					.blockingGet();
			ByteBuf payload = msg.getBuffer();

			isVerificationComplete = payload.readBoolean();
            isLoggedIn.set(payload.readBoolean());

            int id = payload.readInt();

			Map<AddedInfo, String> map = new EnumMap<>(AddedInfo.class);

            // Reading additional information from the ByteBuf
            while (payload.readableBytes() > 0) {
                AddedInfo addedInfo = AddedInfo.fromId(payload.readInt());
                int messageLength = payload.readInt();
                byte[] messageBytes = new byte[messageLength];
                payload.readBytes(messageBytes);

                // Adding the added info to the map with the UTF-8 decoded message
                map.put(addedInfo, new String(messageBytes));
            }

            return new EntryResult<>(
                    entryType == EntryType.CREATE_ACCOUNT
                    ? CredentialValidation.Result.fromId(id)
                    : CredentialsExchange.Result.fromId(id),
                map);
		}

		public void resendVerificationCode() throws IOException {
			ByteBuf payload = Unpooled.buffer(3 * Integer.BYTES);
			payload.writeInt(ClientMessageType.USER_ENTRY.id);
			payload.writeInt(GeneralEntryAction.action.id);
			payload.writeInt(Verification.Action.RESEND_CODE.id);

			out.write(payload);
		}

		public boolean isVerificationComplete() {
			return isVerificationComplete;
		}
	}

	public static class CreateAccountEntry extends Entry<CreateAccountInfo.Credential> {

		private CreateAccountEntry() {
			super(EntryType.CREATE_ACCOUNT);
		}
	}

	public static class LoginEntry extends Entry<LoginInfo.Credential> {

		private LoginEntry() {
			super(EntryType.LOGIN);
		}

		public void togglePasswordType() throws IOException {
			int actionId = LoginInfo.Action.TOGGLE_PASSWORD_TYPE.id;

			ByteBuf payload = Unpooled.buffer();
		    payload.writeInt(ClientMessageType.USER_ENTRY.id);
		    payload.writeInt(GeneralEntryAction.action.id);
			payload.writeInt(actionId);

			out.write(payload);
		}
	}

	public static class BackupVerificationEntry {

		@Deprecated
		public ResultHolder getResult() {
			EntryMessage msg = GlobalMessageDispatcher.getDispatcher()
					.observeMessages()
					.ofType(EntryMessage.class)
					.firstElement()
					.blockingGet();
			ByteBuf payload = msg.getBuffer();

			isLoggedIn.set(payload.readBoolean());

			byte[] resultMessageBytes = new byte[payload.readableBytes()];
			payload.readBytes(resultMessageBytes);

			String resultMessage = new String(resultMessageBytes);

			return new ResultHolder(isLoggedIn(), resultMessage);
		}
	}

	public static void startMessageHandler() throws IOException {
		if (!isLoggedIn()) {
			throw new IllegalStateException("User can't start writing server if he isn't logged in");
		}

		Client.messageTransmitter = new MessageTransmitter() {};
		Client.messageTransmitter.setByteBufOutputStream(out);
		Client.messageTransmitter.startListeningToMessages();
	}

	public static void sendMessageToClient(String message, int chatSessionIndex) throws IOException {
		messageTransmitter.sendMessageToClient(message, chatSessionIndex);
	}

	public static void sendFile(File file, int chatSessionIndex) throws IOException {
		messageTransmitter.sendFile(file, chatSessionIndex);
	}

	public static void stopListeningToMessages() {
		messageTransmitter.stopListeningToMessages();
	}

	public static BackupVerificationEntry createNewBackupVerificationEntry() {
		return new BackupVerificationEntry();
	}

	public static CreateAccountEntry createNewCreateAccountEntry() {
		return new CreateAccountEntry();
	}

	public static LoginEntry createNewLoginEntry() {
		return new LoginEntry();
	}

	public static boolean isLoggedIn() {
		return isLoggedIn.get();
	}

	public static boolean isClientListeningToMessages() {
		return messageTransmitter.isClientListeningToMessages();
	}

	public static String getDisplayName() {
		return messageTransmitter.getUsername();
	}

	public static int getClientID() {
		return messageTransmitter.getClientID();
	}

	public static byte[] getAccountIcon() {
		return messageTransmitter.getAccountIcon();
	}

	public static List<ChatSession> getChatSessions() {
		return messageTransmitter.getChatSessions();
	}

	public static List<ChatRequest> getFriendRequests() {
		return messageTransmitter.getChatRequests();
	}

	public static MessageTransmitter.Commands getCommands() {
		return messageTransmitter.getCommands();
	}

	public static ByteBufInputStream getByteBufInputStream() {
		return in;
	}

	public static ByteBufOutputStream getByteBufOutputStream() {
		return out;
	}

	public static MessageTransmitter getMessageHandler() {
		return messageTransmitter;
	}

	public static ServerInfo getServerInfo() {
		return serverInfo;
	}

	public static void close() throws IOException {
		messageTransmitter.close();
		out.close();
		in.close();
		sslSocket.close();
		isLoggedIn.set(false);
	}

    public static void initializeUDP() {
        try {
            // Create a DatagramSocket to bind to local port 8081
            DatagramSocket socket = new DatagramSocket(9090);
            
            // Server's address and port
            InetAddress serverAddress = InetAddress.getByName("192.168.10.103"); // Replace with server IP
            int serverPort = 8081;

            // Sending data to the server
            String message = "Hello, server!";
            byte[] buffer = message.getBytes();
            DatagramPacket packet = new DatagramPacket(buffer, buffer.length, serverAddress, serverPort);
            socket.send(packet);
            System.out.println("Data sent to " + serverAddress + ":" + serverPort);

            // Listening for responses
            byte[] receiveBuffer = new byte[1024];
            DatagramPacket receivePacket = new DatagramPacket(receiveBuffer, receiveBuffer.length);
            while (true) {
                socket.receive(receivePacket);
                String receivedData = new String(receivePacket.getData(), 0, receivePacket.getLength());
                System.out.println("Received: " + receivedData);
            }
        } catch (SocketException e) {
            System.err.println("Socket creation failed: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Failed to initialize UDP socket: " + e.getMessage());
        }
    }
}