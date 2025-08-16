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

import java.lang.reflect.Field;
import java.lang.reflect.InaccessibleObjectException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Ilias Koukovinis
 *
 */
public final class MemoryUtil {

	private static final Logger logger = LoggerFactory.getLogger(MemoryUtil.class);
	
	private MemoryUtil() {}

	public static void freeStringFromMemory(String stringToFree) {
		try {
			Field field = String.class.getDeclaredField("value");
			field.setAccessible(true);
			field.set(stringToFree, new byte[] {});
		} catch (NoSuchFieldException | IllegalArgumentException | IllegalAccessException
				| InaccessibleObjectException e) {
			logger.error(e.getMessage(), e);
		}
	}
}
