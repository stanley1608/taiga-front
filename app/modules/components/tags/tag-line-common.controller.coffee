###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: tag-line.controller.coffee
###

trim = @.taiga.trim

module = angular.module('taigaCommon')

class TagLineCommonController

    @.$inject = []

    constructor: () ->
        @.tags = []
        @.colorArray = []
        @.addTag = false

    checkPermissions: () ->
        return _.includes(@.project.my_permissions, @.permissions)

    _createColorsArray: (projectTagColors) ->
        @.colorArray = _.map(projectTagColors, (index, value) ->
            return [value, index]
        )

    _renderTags: (tags, project) ->
        colored_tags = []
        tagsColors = project.tags_colors
        for name, color in tags
            color = tagsColors[name]
            colored_tags.push({
                name: name
                color: color
            })

        return colored_tags

    displayTagInput: () ->
        @.addTag = true

    onSelectDropdownTag: (tag, color) ->
        @.onAddTag(tag, color)

    closeTagInput: (event) ->
        if event.keyCode == 27
            @.addTag = false

    ## UNCOMMON UTILITIES

    onAddTag: (tag, color) ->
        @.loadingAddTag = true
        value = trim(tag.toLowerCase())

        tags = @.project.tags
        projectTags = @.project.tags_colors

        tags = [] if not tags?
        projectTags = {} if not projectTags?

        tags.push(value) if value not in tags
        projectTags[tag] = color || null

        console.log @.project.tags
        console.log @.project.tags_colors

        @.addTag = false
        @.loadingAddTag = false
        #Update Model

    onRemoveTag: (tag) ->
        @.loadingRemoveTag = tag
        value = trim(tag.toLowerCase())

        tags = @.project.tags

        tags.pull(value)

        @.loadingRemoveTag = false
        #Update Model

module.controller("TagLineCommonCtrl", TagLineCommonController)
