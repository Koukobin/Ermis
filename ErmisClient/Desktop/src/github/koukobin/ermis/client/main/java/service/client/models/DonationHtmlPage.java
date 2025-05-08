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
package github.koukobin.ermis.client.main.java.service.client.models;

import java.util.Objects;

/**
 * @author Ilias Koukovinis
 *
 */
@Deprecated(forRemoval = true)
public class DonationHtmlPage {

	private String html;
	private String htmlFileName;

	public DonationHtmlPage() {}

	public DonationHtmlPage(String html, String htmlFileName) {
		this.html = html;
		this.htmlFileName = htmlFileName;
	}

	public void setHtml(String html) {
		this.html = html;
	}

	public void setHtmlFileName(String htmlFileName) {
		this.htmlFileName = htmlFileName;
	}

	public String getHtml() {
		return html;
	}

	public String getHtmlFileName() {
		return htmlFileName;
	}

	@Override
	public int hashCode() {
		return Objects.hash(html, htmlFileName);
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

		DonationHtmlPage other = (DonationHtmlPage) obj;
		return Objects.equals(html, other.html) && Objects.equals(htmlFileName, other.htmlFileName);
	}

	@Override
	public String toString() {
		return "DonationHtmlPage [html=" + html + ", htmlFileName=" + htmlFileName + "]";
	}
}
