/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import static java.lang.System.getProperty;

/**
 * @author Ilias Koukovinis
 *
 */
public class SystemUtils {

	public static final String OS_NAME = getProperty("os.name");
	public static final String OS_VERSION = getProperty("os.version");
	public static final String OS_ARCH = getProperty("os.arch");
	public static final String USER_NAME = getProperty("user.name");
	public static final String USER_HOME = getProperty("user.home");
	public static final String JAVA_VERSION = getProperty("java.version");
	public static final String JAVA_VENDOR = getProperty("java.vendor");

	public static final boolean IS_OS_WINDOWS = matchesName("Windows");
	public static final boolean IS_OS_LINUX = matchesName("Linux");
	public static final boolean IS_OS_MAC = matchesName("Mac");
	public static final boolean IS_OS_UNIX = matchesName("Unix");
	public static final boolean IS_OS_SOLARIS = matchesName("SunOS");
	public static final boolean IS_OS_ANDROID = matchesName("Android");
	public static final boolean IS_OS_IOS = matchesName("iOS");

	private SystemUtils() {}

	private static boolean matchesName(String os) {
		return getProperty("os.name").toLowerCase().startsWith(os.toLowerCase());
	}

	public static boolean isWindows() {
		return IS_OS_WINDOWS;
	}

	public static boolean isLinux() {
		return IS_OS_LINUX;
	}

	public static boolean isMac() {
		return IS_OS_MAC;
	}

	public static boolean isUnix() {
		return IS_OS_UNIX;
	}

	public static boolean isSolaris() {
		return IS_OS_SOLARIS;
	}

	public static boolean isAndroid() {
		return IS_OS_ANDROID;
	}

	public static boolean isIOS() {
		return IS_OS_IOS;
	}

}
