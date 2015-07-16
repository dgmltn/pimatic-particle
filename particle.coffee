module.exports = (env) ->

  EVENTS_URL = 'https://api.spark.io/v1/devices/events'

  Promise = env.require 'bluebird'

  EventSource = require 'eventsource'

  Particle = require 'spark'

  #############################################################################
  # PiMarticle
  #############################################################################

  class PiMarticle extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      authToken = config.auth
      esConfig = headers: 'Authorization': 'Bearer ' + authToken
      es = new EventSource(EVENTS_URL, esConfig)
      es.onerror = ->
        console.log 'ERROR!'
        return

      @framework.deviceManager.registerDeviceClass("ParticlePresenceSensor", {
        configDef: deviceConfigDef.ParticlePresenceSensor,
        createCallback: (config, lastState) => new ParticlePresenceSensor(config, es, lastState)
      })

      @framework.deviceManager.registerDeviceClass("ParticleVariable", {
        configDef: deviceConfigDef.ParticleVariable,
        createCallback: (config, lastState) => new ParticleVariable(config, authToken, lastState)
      })

  #############################################################################
  # ParticlePresenceSensor
  #############################################################################

  class ParticlePresenceSensor extends env.devices.PresenceSensor
    actions:
      changePresenceTo:
        params: 
          presence: 
            type: "boolean"

    constructor: (@config, es, lastState) ->
      @name = config.name
      @id = config.id
      @coreid = config.coreid
      @eventType = config.eventType
      @_presence = lastState?.presence?.value or off
      es.addEventListener @eventType, @_eventListener, false
      @_triggerAutoReset()
      super()

    # Use the fat arrow here for access to @changePresenceTo method
    _eventListener: (e) =>
      console.log JSON.stringify(e)
      if !@coreid || @coreid == e.coreid
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


  #############################################################################
  # ParticleVariable
  #############################################################################

  class ParticleVariable extends env.devices.Sensor
    attributes:
      value:
        description: "The current value of the Variable"
        type: "string"

    constructor: (@config, accessToken, lastState) ->
      @accessToken = accessToken
      @name = config.name
      @id = config.id
      @coreid = config.coreid
      @intervalMs = config.intervalMs
      @variable = config.variable
      @_value = lastState?.value?.value or ''
      super()

      @requestData()
      setInterval( =>
        @requestData()
      , @intervalMs
      )

    # Returns a promise that will be fulfilled with the value
    getValue: -> Promise.resolve(@_value)

    _setValue: (value) ->
      unless @_value is value
        @_value = value
        @emit "value", value

    requestData: () =>
      creds = accessToken: @accessToken
      Particle.login(creds).then((token) =>
        #console.log 'Logged in: ', token
        Particle.getVariable @coreid, @variable
      ).then ((data) =>
        #console.log @variable + ' retrieved successfully: ' + data.result
        @_setValue data.result
      ), (err) ->
        console.log 'Particle error:', err

  #############################################################################
    
  plugin = new PiMarticle
  return plugin
