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

package github.koukobin.ermis.server.main.java.server.util;

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

import github.koukobin.ermis.server.main.java.configs.EmailerSettings;
import github.koukobin.ermis.server.main.java.configs.ServerSettings;

/**
 * @author Ilias Koukovinis
 *
 */
public final class EmailerService {

	private static final Logger LOGGER = LogManager.getLogger("server");
	private static final Session session;
	
	private EmailerService() {}
	
	static {
		Properties properties = System.getProperties();
		properties.put("mail.smtp.host", EmailerSettings.MAIL_SMTP_HOST);
		properties.put("mail.smtp.port", EmailerSettings.MAIL_SMTP_PORT);
		properties.put("mail.smtp.ssl.checkserveridentity", "true");
		properties.put("mail.smtp.auth", "true");
		properties.put("mail.smtp.starttls.enable", "true");
		properties.put("mail.smtp.starttls.required", "true");
		properties.put("mail.smtp.ssl.protocols", "TLSv1.3");
		properties.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");

		session = Session.getDefaultInstance(properties, new Authenticator() {
			@Override
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(EmailerSettings.EMAIL_USERNAME, EmailerSettings.EMAIL_PASSWORD);
			}
		});
		session.setDebug(ServerSettings.IS_PRODUCTION_READY);
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
