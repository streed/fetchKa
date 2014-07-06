log4js = require("log4js")
log4js.replaceConsole()
kafka = require("kafka-node")
Consumer = kafka.HighLevelConsumer
Producer = kafka.HighLevelProducer

exports.FetchKaConsumer = class FetchKaConsumer

  LOG = log4js.getLogger("FetchKaConsumer")

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

exports.FetchKaHandler = class FetchKaHandler

  class InnerBuilder
    constructor: () ->
      @_topic = undefined
      @_onMessage = -> return null
      @_onError = -> return null

    setTopic: (@_topic) -> @

    setOnMessage: (@_onMessage) -> @

    setOnError: (@_onError) -> @

    set: (options) ->
      if "onMessage" of options
        @setOnMessage options.onMessage
      if "onError" of options
        @setOnError options.onError
      if "topic" of options
        @setTopic options.topic

      @

    build: () ->
      return new FetchKaHandler(@_topic, @_onMessage, @_onError)

  @Builder: InnerBuilder

  constructor: (@topic, @onMessage, @onError) ->
        
exports.FetchKaProducer = class FetchKaProducer

  LOG = log4js.getLogger("FetchKaProducer")
  
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
    LOG.trace("Created a new Producer that will publish messages to: ", @_topics)
    @_isReady = false
    @

  ready: (cb) ->
    LOG.trace("Connection to Kafka is ready, running the callback")
    cb.bind(@)
    outer = ->
      @_isReady = true
      cb()

    @_client.on("ready", outer.bind(@))

  sendOne: (topic, message, cb, batch=false) ->
    if(topic in @_topics)
      LOG.trace( "Sending a message to", topic, message)
      if(batch)
        LOG.trace("Batching upto 10 messages before sending to kafka.")
      else
        LOG.trace("Sending a single message to Kafka")
        @send([{topic: topic, messages: JSON.stringify {message: message}}], cb)
    else
      throw new Error("Topic is not in the valid list of topics: ", @_topics)

  send: (messages, cb) ->
    @_send(messages, cb)

  _send: (messages, cb) ->
    if(@_isReady)
      LOG.info messages
      messages = ({topic:message.topic, messages:JSON.stringify(message.messages)} for message in messages when message.topic in @_topics)
      LOG.trace("I am connected and we filtered out any messages that cannot be sent. So publish the remaining messages: ", messages)
      @_client.send(messages, cb)
    else
      throw new Error("Producer is not ready")

