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
package github.koukobin.ermis.server.main.java.databases.postgresql.ermis_database.complexity_checker;

import java.util.List;
import java.util.Objects;

import me.gosimple.nbvcxz.Nbvcxz;
import me.gosimple.nbvcxz.scoring.Result;
import me.gosimple.nbvcxz.resources.Configuration;
import me.gosimple.nbvcxz.resources.ConfigurationBuilder;
import me.gosimple.nbvcxz.resources.Dictionary;
import me.gosimple.nbvcxz.resources.DictionaryBuilder;

/**
 * @author Ilias Koukovinis
 *
 */
public final class PasswordComplexityChecker {

	/**
	 * Password entropy estimator
	 */
	private static final Nbvcxz nbvcxz;

	static {

		/*
		 * A map of excluded words on a per-user basis using a hypothetical "User"
		 * object that contains this info
		 */
		List<Dictionary> dictionaryList = ConfigurationBuilder.getDefaultDictionaries();
		dictionaryList.add(new DictionaryBuilder()
				.setDictionaryName("exclude")
				.setExclusion(true)
				.createDictionary());
		
		Configuration configuration = new ConfigurationBuilder()
				.setDictionaries(dictionaryList)
				.createConfiguration();
		
		nbvcxz = new Nbvcxz(configuration);
	}

	private Requirements requirements;

	public PasswordComplexityChecker() {}

	public PasswordComplexityChecker(Requirements requirements) {
		this.requirements = requirements;
	}

	public void setRequirements(Requirements requirements) {
		this.requirements = requirements;
	}

	public boolean estimate(String password) {
		return estimate(requirements, password);
	}

	public static boolean estimate(Requirements requirements, String password) {
		// Check if password has exceeded minimum required entropy
		Result result = nbvcxz.estimate(password);

		boolean hasPasswordExceededMinEntropy = requirements.getMinEntropy() > result.getEntropy();

		if (hasPasswordExceededMinEntropy) {
			return false;
		}

		return ComplexityCheckerUtil.estimate(requirements, password);
	}

	@Override
	public int hashCode() {
		return Objects.hash(requirements);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}

		if (obj == null) {
			return false;
		}

		if (getClass() != obj.getClass()) {
			return false;
		}

		PasswordComplexityChecker other = (PasswordComplexityChecker) obj;
		return Objects.equals(requirements, other.requirements);
	}

	@Override
	public String toString() {
		return "PasswordComplexityChecker [requirements=" + requirements + "]";
	}
}
