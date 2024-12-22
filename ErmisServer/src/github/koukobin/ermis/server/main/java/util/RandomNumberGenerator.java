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

import io.netty.util.internal.ThreadLocalRandom;

/**
 * @author Ilias Koukovinis
 *
 */
public final class RandomNumberGenerator {

	private RandomNumberGenerator() {}

    /**
     * Generates random numbers with the specified number of digits and fills the provided array with the generated numbers.
     *
     * @param array the array to be populated with random numbers
     * @param numDigits the number of digits for the random numbers to have
     */
    public static void generateArray(int[] array, int numDigits) {
        for (int i = 0; i < array.length; i++) {
            array[i] = generateRandomNumber(numDigits);
        }
    }

    /**
     * Generates random numbers between the specified origin (inclusive) and bound (exclusive)
     * and fills the provided array with the generated numbers.
     *
     * @param array the array to be populated with random numbers
     * @param origin the lower bound (inclusive) for the random numbers
     * @param bound the upper bound (exclusive) for the random numbers
     */
    public static void generateArray(int[] array, int origin, int bound) {
        for (int i = 0; i < array.length; i++) {
            array[i] = generateRandomNumber(origin, bound);
        }
    }
    
    public static int generateRandomNumber(int numDigits) {
        int origin = (int) Math.pow(10, numDigits - 1);
        int bound = (int) (Math.pow(10, numDigits));
        return generateRandomNumber(origin, bound);
    }

    /**
     * Generates a random number between the specified origin (inclusive) and bound (exclusive).
     *
     * @param origin the lower bound (inclusive)
     * @param bound the upper bound (exclusive)
     * @return a random number between origin (inclusive) and bound (exclusive)
     */
    public static int generateRandomNumber(int origin, int bound) {
        return ThreadLocalRandom.current().nextInt(origin, bound);
    }
    
}
