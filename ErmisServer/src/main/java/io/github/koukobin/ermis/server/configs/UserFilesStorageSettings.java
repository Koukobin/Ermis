package main.java.io.github.koukobin.ermis.server.configs;

public class UserFilesStorageSettings {
	public final String ROOT_FOLDER;
	public final String PROFILE_PHOTOS_DIRECTORY;
	public final String SENT_FILES_DIRECTORY;

	public UserFilesStorageSettings(ConfigurationLoader loader) {
		this.ROOT_FOLDER              = loader.getUserFilesStorageRoot();
		this.PROFILE_PHOTOS_DIRECTORY = loader.getProfilePhotosDir();
		this.SENT_FILES_DIRECTORY     = loader.getSentFilesDir();
	}
}
