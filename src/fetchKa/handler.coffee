exports.FetchKaHandler = class FetchKaHandler

  class InnerBuilder
    constructor: () ->
      @params = {}
      @params.topic = "*"
      @params.name = (->
        id = ""
        id += Math.random().toString(36).substr(2) while id.length < 8
      )()

      @params.onMessage = -> return null
      @params.onError = -> return null

    setName: (name) ->
      @params.name = name
      @

    setTopic: (topic) ->
      @params.topic = topic
      @

    setOnMessage: (onMessage) ->
      @params.onMessage = onMessage
      @

    setOnError: (onError) ->
      @params.onError = onError
      @

    set: (options) ->
      for key, value of options
        @params[key] = value
      @counter = 0
      @

    build: () ->
      return new FetchKaHandler(@params)

  @Builder: () ->
    return new InnerBuilder

  constructor: (options) ->
    for key, value of options
      @[key] = value
