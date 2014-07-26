assert = require("assert")
Routing = require("../src/fetchka").FetchKaRouting

describe 'FetchKaRouting', ->
  describe 'addRouting', ->
    it 'should create the routing tree', ->
      routing = new Routing.Builder("test").routing([1, [ 2, 3 ], 4]).build()

      console.log "routing", routing.level
