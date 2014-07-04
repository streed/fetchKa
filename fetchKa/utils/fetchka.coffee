kafka = require("kafka-node")
Consumer = kafka.HighLevelConsumer

exports.FetchKaConsumer = class FetchKaConsumer

  class InnerBuilder
    constructor: () ->
      @_topics = []
      @_options = {}
      @

    addTopic: (t) ->
      @_topics.push {topic: t}
      @

    connectString: (connectStr) ->
      @_options["connectStr"] = connectStr
      @

    build: () ->
      kafkaClient = new kafka.Client
      return new FetchKaConsumer( new Consumer(kafkaClient, @_topics, @_options), @_topics)

  @Builder: InnerBuilder

  constructor: (@_client, topics) ->
    @_listeners = {}

    for t in topics
      @_listeners[t.topic] = []

  _onMessage: (message) ->
    if message.topic of @_listeners
      for listener in @_listeners[message.topic]
        listener.onMessage(message)

  _onError: (err) ->
    for listener in @_listeners
      listener.onError(err)

  register: (listener) ->
    console.log listener.topic
    if listener.topic not of @_listeners
      throw new Error("This client is not listening to: " + listener.topic)
    @_listeners[listener.topic].push listener
    @

  deregister: (listener) ->
    @_listeners[listener.topic].filter (l) -> l isnt listener
    @

  start: () ->
    @_client.on "message", @_onMessage.bind(@)
    @_client.on "error", @_onError.bind(@)

exports.FetchKaHandler = class FetchKaHandler

  class InnerBuilder
    constructor: () ->
      @_topic = undefined
      @_onMessage = -> return null
      @_onError = -> return null

    setTopic: (@_topic) -> @

    setOnMessage: (@_onMessage) -> @

    setOnError: (@_onError) -> @

    build: () ->
      return new FetchKaHandler(@_topic, @_onMessage, @_onError)

  @Builder: InnerBuilder

  constructor: (topic, onMessage, onError) ->
    @topic = topic
    @onMessage = onMessage
    @onError = onError
        
