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
package github.koukobin.ermis.common.entry;

import java.util.HashMap;
import java.util.Map;

import github.koukobin.ermis.common.IDable;
import github.koukobin.ermis.common.results.ResultHolder;
import github.koukobin.ermis.common.util.EnumIntConverter;

/**
 * 
 * @author Ilias Koukovinis
 *
 */
public final class LoginInfo {
    
    private LoginInfo() {}

	public enum Credential implements EntryType.CredentialInterface {
		EMAIL(1), PASSWORD(2);

		private static final Map<Integer, Credential> valuesById = new HashMap<>();

		static {
			for (Credential credential : Credential.values()) {
				valuesById.put(credential.id, credential);
			}
		}

		public final int id;

		Credential(int id) {
			this.id = id;
		}

		public int id() {
			return id;
		}

		public static Credential fromId(int id) {
			return valuesById.get(id);
		}
	}

	public enum PasswordType {
		PASSWORD(1), BACKUP_VERIFICATION_CODE(2);

		private static final Map<Integer, PasswordType> valuesById = new HashMap<>();

		static {
			for (PasswordType passwordType : PasswordType.values()) {
				valuesById.put(passwordType.id, passwordType);
			}
		}

		public final int id;

		PasswordType(int id) {
			this.id = id;
		}

		public static PasswordType fromId(int id) {
			return valuesById.get(id);
		}
	}

	public enum Action {
		TOGGLE_PASSWORD_TYPE(1), ADD_DEVICE_INFO(2);

		private static final Map<Integer, Action> valuesById = new HashMap<>();

		static {
			for (Action action : Action.values()) {
				valuesById.put(action.id, action);
			}
		}

		public final int id;

		Action(int id) {
			this.id = id;
		}

		public static Action fromId(int id) {
			return EnumIntConverter.fromId(valuesById, id);
		}
	}

	public enum AuthenticationStage {
		CREDENTIALS_EXCHANGE(1), LOGIN(2);

		private static final Map<Integer, AuthenticationStage> valuesById = new HashMap<>();

		static {
			for (AuthenticationStage stage : AuthenticationStage.values()) {
				valuesById.put(stage.id, stage);
			}
		}

		public final int id;

		AuthenticationStage(int id) {
			this.id = id;
		}

		public static AuthenticationStage fromId(int id) {
			return EnumIntConverter.fromId(valuesById, id);
		}
	}

	public static class CredentialsExchange {
		public enum Result {
            SUCCESFULLY_EXCHANGED_CREDENTIALS(1, true, "Succesfully exchanged credentials!"),
            INCORRECT_EMAIL(2, false, "Incorrect email!"),
			ACCOUNT_DOESNT_EXIST(3, false, "Account doesn't exist!");

			private static final Map<Integer, Result> valuesById = new HashMap<>();

			static {
				for (Result result : Result.values()) {
					valuesById.put(result.id, result);
				}
			}

			public final int id;
			public final ResultHolder resultHolder;

			Result(int id, boolean isSuccessful, String message) {
				this.id = id;
				this.resultHolder = new ResultHolder(isSuccessful, message);
			}

			public static Result fromId(int id) {
				return EnumIntConverter.fromId(valuesById, id);
			}
		}
	}

	public static class Login {
		public enum Result implements IDable {
            SUCCESFULLY_LOGGED_IN(1, true, "Succesfully logged into your account!"),
            ERROR_WHILE_LOGGING_IN(2, false, "An error occurred while logging into your account! Please contact the server administrator and let them know that their server is broken."),
            INCORRECT_PASSWORD(3, false, "Incorrect password."),
			INCORRECT_BACKUP_VERIFICATION_CODE(4, false, "Incorrect backup verification code.");

			private static final Map<Integer, Result> valuesById = new HashMap<>();

			static {
				for (Result result : Result.values()) {
					valuesById.put(result.id, result);
				}
			}

			public final int id;
			public final ResultHolder resultHolder;

			Result(int id, boolean isSuccessful, String message) {
				this.id = id;
				this.resultHolder = new ResultHolder(isSuccessful, message);
			}

			public static Result fromId(int id) {
				return EnumIntConverter.fromId(valuesById, id);
			}

			@Override
			public int getID() {
				return id;
			}

		}
	}
}

