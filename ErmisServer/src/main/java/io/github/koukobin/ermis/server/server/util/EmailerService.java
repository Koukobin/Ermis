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

package main.java.io.github.koukobin.ermis.server.server.util;

import java.util.Properties;
import java.util.concurrent.CompletableFuture;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.activation.FileDataSource;
import javax.mail.Authenticator;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.base.Throwables;

import static main.java.io.github.koukobin.ermis.server.configs.EmailerSettings.*;
import main.java.io.github.koukobin.ermis.server.configs.ServerSettings;

/**
 * @author Ilias Koukovinis
 *
 */
public final class EmailerService {

	private static final Logger LOGGER = LogManager.getLogger("server");

	private static final Session session;
	private static final InternetAddress emailAddress;

	private EmailerService() {}

	static {
		Properties properties = new Properties();
		properties.put("mail.smtp.host", MAIL_SMTP_HOST);
		properties.put("mail.smtp.port", MAIL_SMTP_PORT);
		properties.put("mail.smtp.ssl.checkserveridentity", "true");
		properties.put("mail.smtp.auth", "true");
		properties.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");

		final SmtpProtocol SMTP_PROTOCOL = VALID_SMTP_PORTS_TO_PROTOCOl.get(MAIL_SMTP_PORT);
		if (SMTP_PROTOCOL == null)
			throw new RuntimeException("Invalid SMTP port: " + MAIL_SMTP_PORT);

		switch (SMTP_PROTOCOL) {
		case SSL_TLS -> {
			properties.put("mail.smtp.ssl.enable", "true");
			properties.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
		}
		case STARTTLS -> {
			properties.put("mail.smtp.starttls.enable", "true");
			properties.put("mail.smtp.starttls.required", "true");
		}
		}

		session = Session.getDefaultInstance(properties, new Authenticator() {
			@Override
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
			}
		});
		session.setDebug(!ServerSettings.IS_PRODUCTION_MODE);

		try {
			emailAddress = new InternetAddress(EMAIL_USERNAME);
		} catch (AddressException ae) {
			throw new RuntimeException(ae);
		}

		// Send test email to self to ensure emailer works correctly
		try {
			MimeMessage message = new MimeMessage(session);
			message.setFrom(emailAddress);
			message.addRecipients(Message.RecipientType.TO, EMAIL_USERNAME);
			message.setSubject("Test");
			message.setText("Test email");
			Transport.send(message);
		} catch (MessagingException me) {
			// Throw exception ONLY in prod; continue execution in dev
			if (ServerSettings.IS_PRODUCTION_MODE) {
				throw new RuntimeException(me);
			}
			LOGGER.debug(Throwables.getStackTraceAsString(me));
		}
	}

	public static void initialize() {
		// Helper method to initialize class
	}

	public static void sendEmail(String subject, String body, String... to) throws MessagingException {
		InternetAddress[] toAddress = new InternetAddress[to.length];
		for (int i = 0; i < toAddress.length; i++) {
			toAddress[i] = new InternetAddress(to[i]);
		}

		MimeMessage message = new MimeMessage(session);
		message.setFrom(emailAddress);
		message.addRecipients(Message.RecipientType.TO, toAddress);
		message.setSubject(subject);
		message.setText(body);

		sendAsyncMessage(message);
	}

	public static void sendEmailWithHTML(String subject, String text, String... to) throws MessagingException {
		InternetAddress[] toAddress = new InternetAddress[to.length];
		for (int i = 0; i < toAddress.length; i++) {
			toAddress[i] = new InternetAddress(to[i]);
		}

		MimeMessage message = new MimeMessage(session);
		message.setFrom(emailAddress);
		message.addRecipients(Message.RecipientType.TO, toAddress);
		message.setSubject(subject);
		message.setContent(text, "text/html");

		sendAsyncMessage(message);
	}

	public static void sendEmailWithAttachments(String subject, String text, String[] attachmentsFilePath, String... to) throws MessagingException {
		InternetAddress[] toAddress = new InternetAddress[to.length];
		for (int i = 0; i < toAddress.length; i++) {
			toAddress[i] = new InternetAddress(to[i]);
		}

		MimeMessage message = new MimeMessage(session);
		message.setFrom(emailAddress);
		message.addRecipients(Message.RecipientType.TO, toAddress);
		message.setSubject(subject);

		BodyPart messageBodyText = new MimeBodyPart();
		messageBodyText.setText(text);

		Multipart multipart = new MimeMultipart();
		for (int i = 0; i < attachmentsFilePath.length; i++) {
			MimeBodyPart attachment = new MimeBodyPart();
			DataSource source = new FileDataSource(attachmentsFilePath[i]);
			attachment.setDataHandler(new DataHandler(source));
			attachment.setFileName(attachmentsFilePath[i]);
			multipart.addBodyPart(attachment);
		}

		multipart.addBodyPart(messageBodyText);
		message.setContent(multipart);

		sendAsyncMessage(message);
	}

	public static boolean isValidEmailAddress(String email) {
		boolean result = true;
		try {
			InternetAddress emailAddr = new InternetAddress(email);
			emailAddr.validate();
		} catch (AddressException ex) {
			LOGGER.debug("Invalid email address", ex);
			result = false;
		}
		return result;
	}

	private static void sendAsyncMessage(MimeMessage message) {
		CompletableFuture.runAsync(() -> {
			try {
				Transport.send(message);
			} catch (MessagingException me) {
				LOGGER.debug(Throwables.getStackTraceAsString(me));
			}
		});
	}
}
