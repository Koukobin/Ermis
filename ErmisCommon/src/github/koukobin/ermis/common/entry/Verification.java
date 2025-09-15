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
public final class Verification {

	private Verification() {}

	public enum Action {
		RESEND_CODE(1);

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

	public enum Result implements IDable, Resultable {
        SUCCESFULLY_VERIFIED(1, true, "Succesfully verified!"),
        WRONG_CODE(2, false, "Incorrect code!"),
        RUN_OUT_OF_ATTEMPTS(3, false, "Run out of attempts!");

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
		
		@Override
		public boolean isSuccessful() {
			return resultHolder.isSuccessful();
		}

		@Override
		public String message() {
			return resultHolder.getResultMessage();
		}
	}
}
