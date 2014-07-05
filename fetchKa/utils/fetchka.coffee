kafka = require("kafka-node")
Consumer = kafka.HighLevelConsumer
Producer = kafka.HighLevelProducer

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
        
exports.FetchKaProducer = class FetchKaProducer
  
  class InnerBuilder
    constructor: () ->
      @_options = {}
      @_topics = []

    connectString: (connectStr) ->
      @_options["connectStr"] = connectStr
      @

    addTopic: (topic) ->
      @_topics.push topic
      @

    setTopics: (@_topics) ->
      @

    build: () ->
      kafkaClient = new kafka.Client()
      if(@_topics == undefined)
        throw new Error("Producer requires a list of valid topics.")
      return new FetchKaProducer( new Producer(kafkaClient, @_options), @_topics)

  @Builder: InnerBuilder

  constructor: (@_client, @_topics) ->
    @_isReady = false
    @

  ready: (cb) ->
    cb.bind(@)
    outer = ->
      @_isReady = true
      cb()

    @_client.on("ready", outer.bind(@))

  send: (messages, cb) ->
    if(@_isReady)
      messages = (message for message in messages when message.topic in @_topics)
      @_client.send(messages, cb)
    else
      throw new Error("Producer is not ready")

