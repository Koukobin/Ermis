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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database;

import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.github.luben.zstd.Zstd;
import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;

import github.koukobin.ermis.common.util.CompressionDetector;
import github.koukobin.ermis.server.main.java.configs.ConfigurationsPaths.UserFilesStorage;

/**
 * @author Ilias Koukovinis
 *
 */
public final class FilesStorage {

	private static final int FILE_COMPRESSION_LEVEL = 4; // 1 (fastest) to 22 (highest compression)

	private static final Logger LOGGER = LogManager.getLogger("server");

	private static final LoadingCache<String /* ID */, byte[] /* Content */> filesCache;
	private static final LoadingCache<String /* ID */, byte[] /* Content */> profilePhotosCache;

	private FilesStorage() {}

	public static void initialize() {
		// Helper method to initialize class
	}

	static {
		try {
			Files.createDirectories(Paths.get(UserFilesStorage.PROFILE_PHOTOS_DIRECTORY));
			Files.createDirectories(Paths.get(UserFilesStorage.SENT_FILES_DIRECTORY));
		} catch (FileAlreadyExistsException fae) {
			LOGGER.info("Directory {} already exists", fae.getFile());
		} catch (IOException ioe) {
			LOGGER.error("Failed to create directory; {}", ioe.getMessage());
			throw new RuntimeException(ioe);
		}
	}

	static {
		final int maxWeight = 50 * 1024 * 1024; // 50 MB
		filesCache = CacheBuilder.newBuilder()
                .maximumWeight(maxWeight)
                .weigher((String key, byte[] value) -> value.length) // Weigh by byte array size in bytes
                .recordStats() // Enable statistics
                .build(new CacheLoader<String, byte[]>() {

					@Override
					public byte[] load(String uuid) throws IOException {
						String sentFilePath = UserFilesStorage.SENT_FILES_DIRECTORY + uuid;
						return Files.readAllBytes(Paths.get(sentFilePath));
					}
				});
	}

	static {
		final int maxWeight = 50 * 1024 * 1024; // 50 MB
		profilePhotosCache = CacheBuilder.newBuilder()
                .maximumWeight(maxWeight)
                .weigher((String key, byte[] value) -> value.length) // Weigh by byte array size in bytes
				.recordStats() // Enable statistics
				.build(new CacheLoader<String, byte[]>() {

					@Override
					public byte[] load(String uuid) throws IOException {
						String photoFilePath = UserFilesStorage.PROFILE_PHOTOS_DIRECTORY + uuid;
						return Files.readAllBytes(Paths.get(photoFilePath));
					}
				});
	}

	private static String generateUUID() {
		return UUID.randomUUID().toString();
	}

	public static String storeProfilePhoto(byte[] photoBytes) throws IOException {
		String uuid = generateUUID();
		String photoFilePath = UserFilesStorage.PROFILE_PHOTOS_DIRECTORY + uuid;
		byte[] photoBytesCompressed = Zstd.compress(photoBytes, FILE_COMPRESSION_LEVEL);

		Path path = Paths.get(photoFilePath);
		Files.createFile(path);
		Files.write(path, photoBytesCompressed);

		profilePhotosCache.put(uuid, photoBytesCompressed); // Cache file on initial transmission, when retrieval is most likely
		return uuid;
	}

	public static String storeSentFile(byte[] fileBytes) throws IOException {
		String uuid = generateUUID();
		String photoFilePath = UserFilesStorage.SENT_FILES_DIRECTORY + uuid;
		byte[] fileBytesCompressed = Zstd.compress(fileBytes, FILE_COMPRESSION_LEVEL);

		Path path = Paths.get(photoFilePath);
		Files.createFile(path);
		Files.write(path, fileBytesCompressed);

		filesCache.put(uuid, fileBytesCompressed); // Cache file on initial transmission, when retrieval is most likely
		return uuid;
	}

	public static byte[] loadProfilePhoto(String photoUUID) throws IOException {
		try {
			byte[] photoBytes = profilePhotosCache.get(photoUUID);

			if (CompressionDetector.isZstdCompressed(photoBytes)) {
				return Zstd.decompress(photoBytes, (int) Zstd.getFrameContentSize(photoBytes));
			}

			return photoBytes;
		} catch (ExecutionException ee) {
			throw new IOException(ee);
		}
	}

	public static byte[] loadUserFile(String fileUUID) throws IOException {
		try {
			byte[] fileBytes = filesCache.get(fileUUID);

			if (CompressionDetector.isZstdCompressed(fileBytes)) {
				return Zstd.decompress(fileBytes, (int) Zstd.getFrameContentSize(fileBytes));
			}

			return fileBytes;
		} catch (ExecutionException ee) {
			throw new IOException(ee);
		}
	}

}

