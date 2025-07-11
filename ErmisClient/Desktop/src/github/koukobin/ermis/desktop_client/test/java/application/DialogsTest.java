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
package github.koukobin.ermis.desktop_client.test.java.application;

import github.koukobin.ermis.desktop_client.main.java.util.dialogs.DialogsUtil;
import javafx.scene.control.ButtonType;

/**
 * @author Ilias Koukovinis
 *
 */
public class DialogsTest {

	public static void main(String[] args) {
		
		ButtonType resendVerificationCodeButtonType = new ButtonType("Resend code");
		DialogsUtil.createTextInputDialog(
				"Enter the code that was sent to your email to verify it is really you", 
				null,
				"Verification Code", 
				resendVerificationCodeButtonType, 
				ButtonType.OK)
		.showAndWait();

		DialogsUtil.showSuccessDialog("You have succesfully logged in!");
		DialogsUtil.showInfoDialog("Information here!");
		DialogsUtil.showExceptionDialog(new RuntimeException("Exception!"));
		DialogsUtil.showErrorDialog("Fatal error!");
		DialogsUtil.createTextInputDialog("sdf", "sdf", "sdf").showAndWait();
	}
}
