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

class TagLineController

    @.$inject = [
        "$rootScope",
        "$tgConfirm",
        "$tgQueueModelTransformation"
    ]

    constructor: (@rootScope, @confirm, @modelTransform) ->
        @.tags = @._renderTags(@.type.tags, @.project)
        @.addTag = false
        @.colorArray = _.map(@.project.tags_colors, (index, value) ->
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
        @.addTag = false
        @.onAddTag(tag, color)

    closeTagInput: (event) ->
        if event.keyCode == 27
            @.addTag = false

    onDeleteTag: (tag) ->
        console.log "tag:", tag.name
        @.loadingRemoveTag = tag.name
        onDeleteTagSuccess = () =>
            @rootScope.$broadcast("object:updated")
            @.tags = @._renderTags(@.type.tags, @.project)
            @.loadingRemoveTag = false

        onDeleteTagError = () =>
            console.log 'error'
            @.loadingRemoveTag = false

        tagName = trim(tag.name.toLowerCase())
        transform = @modelTransform.save (item) ->
            tags = _.clone(item.tags, false)
            item.tags = _.pull(tags, tagName)
            return item

        return transform.then(onDeleteTagSuccess, onDeleteTagError)

    onAddTag: (tag, color) ->
        @.loadingAddTag = true
        if !color
            color = null

        newTag = [tag, color]

        onAddTagSuccess = () =>
            @rootScope.$broadcast("object:updated")
            @.addTag = false
            @.loadingAddTag = false
            @.tags = @._renderTags(@.type.tags, @.project)

        onAddTagError = () =>
            @.loadAddTag = false
            console.log 'error'

        transform = @modelTransform.save (item) ->
            if not item.tags
                item.tags = []

            tags = _.clone(item.tags)
            tags.push(newTag) if tag.name not in tags
            item.tags = tags
            return item

        return transform.then(onAddTagSuccess, onAddTagError)

module.controller("TagLineCtrl", TagLineController)
