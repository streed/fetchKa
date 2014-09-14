log4js = require("log4js")
log4js.replaceConsole()
kafka = require("kafka-node")
Producer = kafka.HighLevelProducer
 
exports.FetchKaProducer = class FetchKaProducer

  LOG = log4js.getLogger("FetchKaProducer")
  
  class InnerBuilder
    constructor: () ->
      @_options = {}
      @_options["connectStr"] = "localhost:2181"
      @_topics = []
      @_encoder = (msg) -> JSON.stringify msg

    connectString: (connectStr) ->
      @_options["connectStr"] = connectStr
      @

    addTopic: (topic) ->
      @_topics.push topic
      @

    setTopics: (@_topics) ->
      @

    setEncoder: (@_encoder) ->
      @

    build: () ->
      kafkaClient = new kafka.Client @_options["connectStr"]
      if(@_topics == undefined)
        throw new Error("Producer requires a list of valid topics.")
      return new FetchKaProducer( new Producer(kafkaClient, @_options), @_topics)

  @Builder: InnerBuilder

  constructor: (@_client, @_topics, @_encoder) ->
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
        @send([{topic: topic, messages:@_encoder({message: message})}], cb)
    else
      throw new Error("Topic is not in the valid list of topics: ", @_topics)

  send: (messages, cb) ->
    @_send(messages, cb)

  _send: (messages, cb) ->
    if(@_isReady)
      messages = ({topic:message.topic, messages:@_encoder(message.messages)} for message in messages when message.topic in @_topics)
      LOG.trace("I am connected and we filtered out any messages that cannot be sent. So publish the remaining messages: ", messages)
      @_client.send(messages, cb)
    else
      throw new Error("Producer is not ready")

