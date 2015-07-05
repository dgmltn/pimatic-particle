module.exports = (env) ->

  API_URL = 'https://api.spark.io/v1/devices/events'

  Promise = env.require 'bluebird'

  EventSource = require 'eventsource'

  class Particle extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      esConfig = headers: 'Authorization': 'Bearer ' + config.auth
      es = new EventSource(API_URL, esConfig)
      es.onerror = ->
        console.log 'ERROR!'
        return

      @framework.deviceManager.registerDeviceClass("ParticlePresenceSensor", {
        configDef: deviceConfigDef.ParticlePresenceSensor,
        createCallback: (config, lastState) => new ParticlePresenceSensor(config, es, lastState)
      })

  class ParticlePresenceSensor extends env.devices.PresenceSensor
    actions:
      changePresenceTo:
        params: 
          presence: 
            type: "boolean"

    constructor: (@config, es, lastState) ->
      @name = config.name
      @id = config.id
      @eventType = config.eventType
      @_presence = lastState?.presence?.value or off
      es.addEventListener @eventType, @_eventListener, false
      @_triggerAutoReset()
      super()

    # Use the fat arrow here for access to @changePresenceTo method
    _eventListener: (e) =>
      console.log JSON.stringify(e)
      @changePresenceTo(yes)
      return

    changePresenceTo: (presence) ->
      @_setPresence(presence)
      @_triggerAutoReset()
      return Promise.resolve()

    _triggerAutoReset: ->
      if @config.autoReset and @_presence
        clearTimeout(@_resetPresenceTimeout)
        @_resetPresenceTimeout = setTimeout(@_resetPresence, @config.resetTime) 

    _resetPresence: =>
      @_setPresence(no)

  plugin = new Particle
  return plugin
