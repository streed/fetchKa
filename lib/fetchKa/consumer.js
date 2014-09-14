// Generated by CoffeeScript 1.7.1
(function() {
  var Consumer, FetchKaConsumer, kafka, log4js;

  log4js = require("log4js");

  log4js.replaceConsole();

  kafka = require("kafka-node");

  Consumer = kafka.HighLevelConsumer;

  exports.FetchKaConsumer = FetchKaConsumer = (function() {
    var InnerBuilder, LOG;

    LOG = log4js.getLogger("FetchKaConsumer");

    InnerBuilder = (function() {
      function InnerBuilder() {
        this._topics = [];
        this._options = {};
        this._options["connectStr"] = "localhost:2181";
        this;
      }

      InnerBuilder.prototype.addTopic = function(t) {
        this._topics.push({
          topic: t
        });
        return this;
      };

      InnerBuilder.prototype.connectString = function(connectStr) {
        this._options["connectStr"] = connectStr;
        return this;
      };

      InnerBuilder.prototype.build = function() {
        var kafkaClient;
        kafkaClient = new kafka.Client(this._options["connectStr"]);
        return new FetchKaConsumer(new Consumer(kafkaClient, this._topics, this._options), this._topics);
      };

      return InnerBuilder;

    })();

    FetchKaConsumer.Builder = InnerBuilder;

    function FetchKaConsumer(_client, topics) {
      var t, _i, _len;
      this._client = _client;
      this._listeners = {};
      for (_i = 0, _len = topics.length; _i < _len; _i++) {
        t = topics[_i];
        this._listeners[t.topic] = [];
      }
      LOG.info("Listening to: ", topics);
    }

    FetchKaConsumer.prototype._onMessage = function(message) {
      var listener, topic, _i, _len, _ref, _results;
      topic = message.topic;
      if (topic in this._listeners) {
        LOG.trace("Received a message and forwarding it to the listeners: ", message);
        try {
          message = JSON.parse(JSON.parse(message.value));
        } catch (_error) {
          LOG.info(message);
        }
        LOG.info(this._listeners, message);
        _ref = this._listeners[topic];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          listener = _ref[_i];
          _results.push(listener.onMessage(message.message));
        }
        return _results;
      } else {
        return LOG.debug("Received message was for a topic that I am not following: ", message);
      }
    };

    FetchKaConsumer.prototype._onError = function(err) {
      var listener, _i, _len, _ref, _results;
      LOG.error("Error: ", err);
      _ref = this._listeners;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        listener = _ref[_i];
        _results.push(listener.onError(err));
      }
      return _results;
    };

    FetchKaConsumer.prototype.register = function(listener) {
      LOG.trace("Registering: ", listener.constructor.name);
      if (!(listener.topic in this._listeners)) {
        throw new Error("This client is not listening to: " + listener.topic);
      }
      this._listeners[listener.topic].push(listener);
      return this;
    };

    FetchKaConsumer.prototype.unregister = function(listener) {
      LOG.info("Unregistering: ", listener.name);
      this._listeners[listener.topic].filter(function(l) {
        return l !== listener;
      });
      return this;
    };

    FetchKaConsumer.prototype.start = function() {
      LOG.info("Starting to wait for messages");
      this._client.on("message", this._onMessage.bind(this));
      return this._client.on("error", this._onError.bind(this));
    };

    return FetchKaConsumer;

  })();

}).call(this);