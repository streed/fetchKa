log4js = require("log4js")
log4js.replaceConsole()
kafka = require("kafka-node")
Consumer = kafka.HighLevelConsumer

exports.FetchKaConsumer = class FetchKaConsumer

  LOG = log4js.getLogger("FetchKaConsumer")

  class InnerBuilder
    constructor: () ->
      @_topics = []
      @_options = {}
      @_options["connectStr"] = "localhost:2181"
      @

    addTopic: (t) ->
      @_topics.push {topic: t}
      @

    connectString: (connectStr) ->
      @_options["connectStr"] = connectStr
      @

    build: () ->
      kafkaClient = new kafka.Client @_options["connectStr"]
      return new FetchKaConsumer( new Consumer(kafkaClient, @_topics, @_options), @_topics)

  @Builder: InnerBuilder

  constructor: (@_client, topics) ->
    @_listeners = {}

    for t in topics
      @_listeners[t.topic] = []

    LOG.info("Listening to: ", topics)

  _onMessage: (message) ->
    topic = message.topic
    if topic of @_listeners
      LOG.trace("Received a message and forwarding it to the listeners: ", message)
      try
        message = JSON.parse message.value
      catch
        LOG.info message
      LOG.info @_listeners, message
      for listener in @_listeners[topic]
        listener.onMessage(message)
    else
      LOG.debug("Received message was for a topic that I am not following: ", message)

  _onError: (err) ->
    LOG.error("Error: ", err)
    for listener in @_listeners
      listener.onError(err)

  register: (listener) ->
    LOG.trace("Registering: ", listener.constructor.name)
    if listener.topic not of @_listeners
      throw new Error("This client is not listening to: " + listener.topic)
    @_listeners[listener.topic].push listener
    @

  unregister: (listener) ->
    LOG.info("Unregistering: ", listener.name)
    @_listeners[listener.topic].filter (l) -> l isnt listener
    @

  start: () ->
    LOG.info("Starting to wait for messages")
    @_client.on "message", @_onMessage.bind(@)
    @_client.on "error", @_onError.bind(@)

