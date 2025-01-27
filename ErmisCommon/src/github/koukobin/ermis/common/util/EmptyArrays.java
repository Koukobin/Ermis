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
package github.koukobin.ermis.common.util;

import java.lang.reflect.Field;

import github.koukobin.ermis.common.Account;
import github.koukobin.ermis.common.UserDeviceInfo;
import github.koukobin.ermis.common.message_types.UserMessage;

/**
 * Utility class providing immutable empty arrays for various types.
 * 
 * @author Ilias Koukovinis
 * 
 */
public final class EmptyArrays {

    // Immutable empty arrays for primitive types
    public static final boolean[] EMPTY_BOOLEAN_ARRAY = {};
    public static final byte[] EMPTY_BYTE_ARRAY = {};
    public static final char[] EMPTY_CHAR_ARRAY = {};
    public static final double[] EMPTY_DOUBLE_ARRAY = {};
    public static final float[] EMPTY_FLOAT_ARRAY = {};
    public static final int[] EMPTY_INT_ARRAY = {};
    public static final long[] EMPTY_LONG_ARRAY = {};
    public static final short[] EMPTY_SHORT_ARRAY = {};

    // Immutable empty arrays for wrapper classes
    public static final Boolean[] EMPTY_BOOLEAN_OBJECT_ARRAY = {};
    public static final Byte[] EMPTY_BYTE_OBJECT_ARRAY = {};
    public static final Character[] EMPTY_CHARACTER_OBJECT_ARRAY = {};
    public static final Double[] EMPTY_DOUBLE_OBJECT_ARRAY = {};
    public static final Float[] EMPTY_FLOAT_OBJECT_ARRAY = {};
    public static final Integer[] EMPTY_INTEGER_OBJECT_ARRAY = {};
    public static final Long[] EMPTY_LONG_OBJECT_ARRAY = {};
    public static final Short[] EMPTY_SHORT_OBJECT_ARRAY = {};

    // Immutable empty arrays for commonly used object types
    public static final Class<?>[] EMPTY_CLASS_ARRAY = {};
    public static final Field[] EMPTY_FIELD_ARRAY = {};
    public static final Object[] EMPTY_OBJECT_ARRAY = {};
    public static final String[] EMPTY_STRING_ARRAY = {};
    public static final UserDeviceInfo[] EMPTY_DEVICE_INFO_ARRAY = {};
    public static final Account[] EMPTY_ACCOUNT_ARRAY = {};
    public static final UserMessage[] EMPTY_USER_MESSAGES_ARRAY = {};

	/**
	 * Index value representing "not found" in a list or array.
	 */
    public static final int NOT_FOUND = -1;

    private EmptyArrays() {}
}

