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

import github.koukobin.ermis.server.main.java.configs.ConfigurationsPaths;

/**
 * @author Ilias Koukovinis
 *
 */
public final class ProfilePhotosStorage {

	private static final Logger LOGGER = LogManager.getLogger("server");

	private static final String PHOTO_DIRECTORY = ConfigurationsPaths.ROOT_FOLDER + "profile_photos/";

	static {
    	try {
			Files.createDirectory(Paths.get(PHOTO_DIRECTORY));
		} catch (FileAlreadyExistsException fae) {
			LOGGER.info("Photo directory {} already exists", PHOTO_DIRECTORY);
		} catch (IOException ioe) {
			LOGGER.error("Failed to create photo directory {}", PHOTO_DIRECTORY, ioe);
		}
    }
    
    private ProfilePhotosStorage() {}

    private static String generateUUID() {
    	return UUID.randomUUID().toString();
    }

    public static String createProfilePhoto(byte[] photoBytes) throws IOException {
    	String uuid = generateUUID();
		String photoFilePath = PHOTO_DIRECTORY + uuid;

        Path path = Paths.get(photoFilePath);
        Files.createFile(path);
        Files.write(path, photoBytes);
        return uuid;
    }
    
    public static byte[] loadProfilePhoto(String photoUUID) throws IOException {
        String photoFilePath = PHOTO_DIRECTORY + photoUUID;
        return Files.readAllBytes(Paths.get(photoFilePath));
    }
}

