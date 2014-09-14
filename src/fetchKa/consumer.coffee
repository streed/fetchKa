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
      @_decoder = (msg) -> JSON.parse JSON.parse(msg.value)
      @_validator = (msg) -> msg
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
        parsedMessage = @_decoder message
        validatedMessage = @_validator parsedMessage
        LOG.info @_listeners, message
        for listener in @_listeners[topic]
          listener.onMessage(validatedMessage.message)
      catch
        LOG.info message
    else
      LOG.debug("Received message was for a topic that I am not following: ", message)

  _onError: (err) ->
    LOG.error("Error: ", err)
    for listener in @_listeners
      listener.onError(err)

  ###
  # Kafka returns json string and the default method of encoding a message is to
  # decode it as JSON.
  #
  # This method allows you to pass in a custom decoder, specifically if you use a 
  # custom custom data type before sending a message into Kafka
  ###
  decoder: (@_decoder) ->
    @

  ###
  # It is important to validate your messages as they come in, this could be to
  # prevent random messages going though your consumers/routes or to add in some
  # level of security about your messages to ensure they are valid before processing
  # them
  #
  # Your custom validator should throw an InvalidMessageException
  ###
  validator: (@_validator) ->
    @

  ###
  # Register a new listener to this consumer.
  #
  # This can beither a single handler or a router.
  ###
  register: (listener) ->
    LOG.trace("Registering: ", listener.constructor.name)
    if listener.topic not of @_listeners
      throw new Error("This client is not listening to: " + listener.topic)
    @_listeners[listener.topic].push listener
    @

  ###
  # If you need to stop a listener from receiving a message at runtime, then
  # pass the listener to this method to remove it from the listener list.
  ###
  unregister: (listener) ->
    LOG.info("Unregistering: ", listener.name)
    @_listeners[listener.topic].filter (l) -> l isnt listener
    @

  ###
  # This starts the consumer to begin to listen to the Kafka topic it is
  # subscribed to.
  ###
  start: () ->
    LOG.info("Starting to wait for messages")
    @_client.on "message", @_onMessage.bind(@)
    @_client.on "error", @_onError.bind(@)

