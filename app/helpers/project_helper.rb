# Copyright (C) 2010-2012, InSTEDD
#
# This file is part of Verboice.
#
# Verboice is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Verboice is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Verboice.  If not, see <http://www.gnu.org/licenses/>.

module ProjectHelper

  def languages_for_js
    LanguageList::COMMON_LANGUAGES.map{|l| {label: l.name, value: l.iso_639_1}}.to_json
  end

  def project_languages_json(project)
    project.languages.map { |lang| {key: lang['language'], value: LanguageList::LanguageInfo.find(lang['language']).name} }.to_json
  end

end