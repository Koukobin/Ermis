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
public final class CreateAccountInfo {

	private CreateAccountInfo() {}

	public enum Credential implements EntryType.CredentialInterface {
		USERNAME(0), PASSWORD(1), EMAIL(2);

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
			return EnumIntConverter.fromId(valuesById, id);
		}
	}
	
    public enum Action {
        ADD_DEVICE_INFO(1), FETCH_REQUIREMENTS(3);

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
        CREDENTIALS_VALIDATION(1), CREATE_ACCOUNT(2);

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

	public static class CredentialValidation {
		public enum Result {
			SUCCESFULLY_EXCHANGED_CREDENTIALS(1, true, "Succesfully exchanged credentials!"),
			UNABLE_TO_GENERATE_CLIENT_ID(2, false, "Unable to generate client id!"),
			EMAIL_ALREADY_USED(3, false, "Email is already used!"),
			USERNAME_REQUIREMENTS_NOT_MET(4, false, "Username requirements not met!"),
			PASSWORD_REQUIREMENTS_NOT_MET(5, false, "Password requirements not met!"),
			INVALID_EMAIL_ADDRESS(6, false, "Invalid email address");

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

	public static class CreateAccount {
        public enum Result implements IDable {
            SUCCESFULLY_CREATED_ACCOUNT(1, true, "Account successfully created!"),
            ERROR_WHILE_CREATING_ACCOUNT(2, false, "An error occurred while creating your account!"),
            DATABASE_MAX_SIZE_REACHED(3, false, "Database maximum capacity reached! Unfortunately, your request could not be processed."),
            EMAIL_ALREADY_USED(4, false, "Email is already used!");

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




