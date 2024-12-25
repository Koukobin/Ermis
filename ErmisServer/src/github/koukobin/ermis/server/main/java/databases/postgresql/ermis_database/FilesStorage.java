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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database;

import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import github.koukobin.ermis.server.main.java.configs.ConfigurationsPaths.UserFilesStorage;

/**
 * @author Ilias Koukovinis
 *
 */
public final class FilesStorage {

	private static final Logger LOGGER = LogManager.getLogger("server");

	static {
		try {
			Files.createDirectories(Paths.get(UserFilesStorage.PROFILE_PHOTOS_DIRECTORY));
			Files.createDirectories(Paths.get(UserFilesStorage.SENT_FILES_DIRECTORY));
		} catch (FileAlreadyExistsException fae) {
			LOGGER.info("Photo directory {} already exists", UserFilesStorage.PROFILE_PHOTOS_DIRECTORY);
		} catch (IOException ioe) {
			LOGGER.error("Failed to create photo directory {}", UserFilesStorage.PROFILE_PHOTOS_DIRECTORY, ioe);
		}
    }
    
    private FilesStorage() {}

    private static String generateUUID() {
		return UUID.randomUUID().toString();
	}

	public static String createProfilePhoto(byte[] photoBytes) throws IOException {
		String uuid = generateUUID();
		String photoFilePath = UserFilesStorage.PROFILE_PHOTOS_DIRECTORY + uuid;

		Path path = Paths.get(photoFilePath);
		Files.createFile(path);
		Files.write(path, photoBytes);
		return uuid;
	}

	public static byte[] loadProfilePhoto(String photoUUID) throws IOException {
		String photoFilePath = UserFilesStorage.PROFILE_PHOTOS_DIRECTORY + photoUUID;
		return Files.readAllBytes(Paths.get(photoFilePath));
	}
	
	public static String createUserFile(byte[] fileBytes) throws IOException {
		String uuid = generateUUID();
		String photoFilePath = UserFilesStorage.SENT_FILES_DIRECTORY + uuid;

		Path path = Paths.get(photoFilePath);
		Files.createFile(path);
		Files.write(path, fileBytes);
		return uuid;
	}

	public static byte[] loadUserFile(String photoUUID) throws IOException {
		String photoFilePath = UserFilesStorage.SENT_FILES_DIRECTORY + photoUUID;
		return Files.readAllBytes(Paths.get(photoFilePath));
	}
}

