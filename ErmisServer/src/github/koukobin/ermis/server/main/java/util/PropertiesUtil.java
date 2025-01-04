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
package github.koukobin.ermis.server.main.java.util;

import java.util.Properties;

/**
 * @author Ilias Koukovinis
 *
 */
public final class PropertiesUtil {

	private PropertiesUtil() {}
	
    public static void resolvePlaceholders(Properties properties) {
        for (String key : properties.stringPropertyNames()) {
            String value = properties.getProperty(key);
            properties.setProperty(key, resolveValue(value, properties));
        }
    }

    public static String resolveValue(String value, Properties properties) {
        while (value.contains("${")) {
            int start = value.indexOf("${") + 2;
            int end = value.indexOf("}", start);
            String placeholder = value.substring(start, end);
            String replacement = properties.getProperty(placeholder, "");
            value = value.replace("${" + placeholder + "}", replacement);
        }
        return value;
    }
}
