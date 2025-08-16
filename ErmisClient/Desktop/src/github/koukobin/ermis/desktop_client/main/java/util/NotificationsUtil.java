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
package github.koukobin.ermis.desktop_client.main.java.util;

import java.io.IOException;
import java.util.function.Consumer;

import org.controlsfx.control.Notifications;

import github.koukobin.ermis.desktop_client.main.java.info.GeneralAppInfo;
import github.koukobin.ermis.desktop_client.main.java.info.chat_interface.ChatInterfaceInfo;
import javafx.application.Platform;
import javafx.geometry.Pos;
import javafx.scene.media.Media;
import javafx.scene.media.MediaPlayer;
import javafx.util.Duration;

/**
 * @author Ilias Koukovinis
 *
 */
public final class NotificationsUtil {

	private static final MediaPlayer notificationPlayer;
	private static final Consumer<String> popupNotificationer;

	static {
		Media media = new Media(ChatInterfaceInfo.NOTIFICATION_SOUND_LOCATION);
		notificationPlayer = new MediaPlayer(media);
		notificationPlayer.setCycleCount(Integer.MAX_VALUE); // Playable infinite times
		notificationPlayer.setOnEndOfMedia(() -> {
			// once media is over stop the player so it does not continue to repeat
			notificationPlayer.stop();
		});

		if (SystemUtils.IS_OS_LINUX) {
			popupNotificationer = (String message) -> {
				ProcessBuilder processBuilder = new ProcessBuilder("/usr/bin/notify-send", GeneralAppInfo.TITLE, message);
				try {
					processBuilder.start();
				} catch (IOException ioe) {
					ioe.printStackTrace();
				}
			};
		} else {
			popupNotificationer = (String message) -> {

				Notifications.create()
				.title(GeneralAppInfo.TITLE)
				.text(message)
				.hideAfter(Duration.seconds(5))
				.position(Pos.TOP_RIGHT)
				.darkStyle()
				.showInformation();

				Platform.runLater(notificationPlayer::play);
			};
		}
	}
	
	private NotificationsUtil() {}

	public static void createNotification(String text) {
		popupNotificationer.accept(text);
	}

	public static void createMessageNotification(String displayName, String message) {
		createNotification(displayName + " says \"" + message + "\"");
	}
}
