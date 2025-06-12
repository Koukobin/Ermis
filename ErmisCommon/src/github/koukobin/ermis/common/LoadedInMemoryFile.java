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
package github.koukobin.ermis.common;

import java.util.Arrays;
import java.util.Objects;

/**
 * @author Ilias Koukovinis
 *
 */
public class LoadedInMemoryFile {

	private String fileName;
	private byte[] fileBytes;

	public LoadedInMemoryFile() {}

	public LoadedInMemoryFile(String fileName, byte[] fileBytes) {
		this.fileName = fileName;
		this.fileBytes = fileBytes;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public void setFileBytes(byte[] fileBytes) {
		this.fileBytes = fileBytes;
	}

	public String getFileName() {
		return fileName;
	}

	public byte[] getFileBytes() {
		return fileBytes;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + Arrays.hashCode(fileBytes);
		result = prime * result + Objects.hash(fileName);
		return result;
	}

	@Override
	public boolean equals(Object obj) {

		if (this == obj) {
			return true;
		}

		if (obj == null) {
			return false;
		}

		if (getClass() != obj.getClass()) {
			return false;
		}

		LoadedInMemoryFile other = (LoadedInMemoryFile) obj;
		return Arrays.equals(fileBytes, other.fileBytes) && Objects.equals(fileName, other.fileName);
	}

	@Override
	public String toString() {
		return "File [fileName=" + fileName + ", fileBytes=" + Arrays.toString(fileBytes) + "]";
	}
}
