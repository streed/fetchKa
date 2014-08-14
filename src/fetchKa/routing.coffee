log4js = require("log4js")

class FetchKaProxy
  LOG = log4js.getLogger("FetchKaProxy")

  constructor: (@handler) ->
    @topic = @handler.topic
    @name = @handler.name
    
  onMessage: (message) ->
    @handler.onMessage message

exports.FetchKaRouting = class FetchKaRouting

  LOG = log4js.getLogger("FetchKaRouting")

  class InnerBuilder
    constructor: (@_topic) ->
      @_parent = undefined
      @
      
    routing: (@route) ->
      @

    parent: (@_parent) ->
      @

    build: () ->
      routing = new FetchKaRouting(@_topic, @_parent)
      routing.addRouting @route
      return routing

  @Builder: (topic) ->
    return new InnerBuilder(topic)

  constructor: (@topic, @parent, errorHandler) ->
    @level = []

    if errorHandler
      @errorHandler = errorHandler
    else
      @errorHandler = LOG.error.bind(LOG)
    
  addRouting: (route) ->
    @level = (route.filter (r) -> not (r instanceof Array)).map (r) -> new FetchKaProxy(r)
    subLevel = route.filter (r) -> r instanceof Array
    @next = []
    for s in subLevel
      @next.push new FetchKaRouting.Builder(@topic).routing(s).parent(@).build()

  onMessage: (message) ->
    try
      for l in @level
        if l.topic == "*" or @topic == l.topic
          l.onMessage message

      for n in @next
        if n.topic == "*" or @topic == n.topic
          n.onMessage message
    catch e
      @_onError(e)

  _onError: (error) ->
    if @parent
      @parent._onError(error)
    else
      @errorHandler(error)

