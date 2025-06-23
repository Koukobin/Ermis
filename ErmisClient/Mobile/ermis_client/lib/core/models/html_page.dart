/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

class DonationHtmlPage {
  String html;
  String htmlFileName;

  DonationHtmlPage(this.html, this.htmlFileName);

  void setHtml(String html) {
    this.html = html;
  }

  void setHtmlFileName(String htmlFileName) {
    this.htmlFileName = htmlFileName;
  }

  String getHtml() => html;

  String getHtmlFileName() => htmlFileName;

  @override
  int get hashCode => html.hashCode ^ htmlFileName.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DonationHtmlPage) return false;
    return html == other.html && htmlFileName == other.htmlFileName;
  }

  @override
  String toString() {
    return 'DonationHtmlPage {html: $html, htmlFileName: $htmlFileName}';
  }
}