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

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.lang.annotation.Documented;

import static java.lang.annotation.ElementType.*;

/**
 * Marks a method or class as potentially vulnerable to security risks.
 * 
 * <p>
 * This annotation serves as a warning for developers to pay extra attention to
 * the implementation details of the annotated code. It indicates areas that
 * might expose the application to vulnerabilities, such as improper validation,
 * weak encryption, or potential misuse.
 * </p>
 * 
 * <p>
 * <strong>Note:</strong> This annotation is for informational purposes only and
 * is retained in the source code; i.e it is discarded by the compiler. It does
 * not affect runtime behavior.
 * </p>
 * 
 * @author Ilias Koukovinis
 */
@Documented
@Retention(RetentionPolicy.SOURCE)
@Target(value={METHOD, TYPE})
public @interface Vulnerable {

	String value();
}
