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
package github.koukobin.ermis.server.main;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.util.Properties;

import github.koukobin.ermis.server.main.java.configs.ConfigurationsPaths;

/**
 * @author Ilias Koukovinis
 *
 */
public class ConfigLoader {

    private Properties properties;

    public ConfigLoader(String configFile) throws IOException {
        this(new FileInputStream(configFile));
    }

	public ConfigLoader(InputStream configFile) throws IOException {
		properties = new Properties();
		properties.load(configFile);
	}
    
    public void loadConfig() {
        Field[] fields = ConfigurationsPaths.class.getDeclaredFields();

        for (Field field : fields) {
        	System.out.println("Field [");
        	System.out.println(field.getName());
            if (field.isAnnotationPresent(ConfigProperty.class)) {
                ConfigProperty annotation = field.getAnnotation(ConfigProperty.class);
				String propertyKey = annotation.value();
				String propertyValue = properties.getProperty(propertyKey);

				System.out.println(propertyKey);
				if (propertyValue != null) {
					try {
						// Make the field accessible, even if it's private
						field.setAccessible(true);
						field.set(null, propertyValue);
					} catch (IllegalAccessException iae) {
						iae.printStackTrace();
					}
				}
			}
            
            System.out.println("]");
		}
        
    }
}
