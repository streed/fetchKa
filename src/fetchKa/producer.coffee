log4js = require("log4js")
log4js.replaceConsole()
kafka = require("kafka-node")
Producer = kafka.HighLevelProducer
 
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
