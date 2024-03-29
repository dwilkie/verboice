#= require workflow/resources/localized_resource_selector

onWorkflow ->
  class window.Resource

    @find: (guid, callback) ->
      $.getJSON "/projects/#{project_id}/resources/find.json?guid=#{guid}", (data) ->
        callback?(new Resource(data))

    @search: (q, callback) ->
      $.getJSON "/projects/#{project_id}/resources.json?q=#{q}", (data) ->
        callback?((new Resource(i) for i in data))

    constructor: (hash = {}) ->

      unpack_localized_resources = (localized_resources) =>
        localized_resources = localized_resources or []
        _.map languages, (l) =>
          localized_resource = _.find localized_resources, (lr) => lr.language is l.key
          localized_resource ||= language: l.key
          LocalizedResourceSelector.from_hash(localized_resource).with_title(l.value).with_language(l.key).with_parent(@)

      @id = ko.observable hash.id
      @name = ko.observable hash.name
      @guid = ko.observable hash.guid
      @project_id = hash.project_id || project_id
      @localized_resources = ko.observableArray unpack_localized_resources hash.localized_resources

      @current_editing_localized_resource = ko.observable @localized_resources()[0]

      @is_valid = ko.computed =>
        _.all(@localized_resources(), (x) => x.is_valid());

    to_hash: () =>
      id: @id()
      guid: @guid()
      project_id: @project_id
      resource:
        name: @name()
        localized_resources_attributes: @pack_localized_resources()

    save: (callback) =>
      data = @to_hash()
      if @id()
        $.ajax
          type: 'PUT'
          url: "/projects/#{@project_id}/resources/#{@id()}.json"
          contentType: 'application/json'
          data: JSON.stringify(data)
          success: (response) =>
            @save_localized_resources response.localized_resources
            callback?(@)
      else
        $.ajax
          type: 'POST'
          url: "/projects/#{@project_id}/resources.json"
          contentType: 'application/json',
          data: JSON.stringify(data),
          success: (response) =>
            @id(response.id)
            @guid(response.guid)
            @save_localized_resources response.localized_resources
            callback?(@)

    edit: (localized_resource) =>
      @current_editing_localized_resource(localized_resource)

    pack_localized_resources: () =>
      result = {}
      for lr, i in @localized_resources()
        do (lr, i) ->
          result[i] = lr.to_hash()
      result

    save_localized_resources: (arr = []) =>
      for hash in arr
        localized_resource = _.find @localized_resources(), (x) => x.language is hash.language
        localized_resource.id(hash.id) if localized_resource?

    show_language: (language) =>
      for lr in @localized_resources()
        if lr.language == language
          @current_editing_localized_resource(lr)
