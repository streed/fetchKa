log4js = require("log4js")
log4js.replaceConsole()

class FetchKaProxy
  LOG = log4js.getLogger("FetchKaProxy")

  constructor: (@handler) ->
    
  onMessage: (message) ->
    @handler.onMessage message

exports.FetchKaRouting = class FetchKaRouting

  LOG = log4js.getLogger("FetchKaRouting")

  class InnerBuilder
    constructor: (@_topic) ->
      
    routing: (@route) ->
      @

    build: () ->
      routing = new FetchKaRouting(@_topic)
      routing.addRouting @route
      return routing

  @Builder: InnerBuilder

  constructor: (@topic) ->
    @level = []
    
  addRouting: (route) ->
    @level = (route.filter (r) -> not (r instanceof Array)).map (r) -> new FetchKaProxy(r)
    subLevel = route.filter (r) -> r instanceof Array
    @next = []
    for s in subLevel
      @next.push new FetchKaRouting.Builder(@topic).routing(s).build()

  onMessage: (message) ->
    LOG.trace message
    for l in @level
      l.onMessage message

    for n in @next
      n.onMessage message

