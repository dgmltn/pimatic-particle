module.exports = (env) ->

  Promise = env.require 'bluebird'

  Particle = require 'spark'

  #############################################################################
  # ParticlePlugin
  #############################################################################

  class ParticlePlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require("./device-config-schema")

      creds = accessToken: config.auth
      Particle.login creds
      .then (token) =>
        env.logger.debug 'Logged in: ', token

      @framework.deviceManager.registerDeviceClass("ParticlePresenceSensor", {
        configDef: deviceConfigDef.ParticlePresenceSensor,
        createCallback: (config, lastState) => new ParticlePresenceSensor(config, lastState)
      })

      @framework.deviceManager.registerDeviceClass("ParticleVariable", {
        configDef: deviceConfigDef.ParticleVariable,
        createCallback: (config, lastState) => new ParticleVariable(config, lastState)
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
      super()

      @_triggerAutoReset()
      Particle.getEventStream @eventType, @coreid, @_eventListener

    # Use the fat arrow here for access to @changePresenceTo method
    _eventListener: (e) =>
      env.logger.debug JSON.stringify(e)
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

    constructor: (@config, lastState) ->
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
      Particle.getVariable @coreid, @variable
      .then ((data) =>
        env.logger.debug @variable + ' retrieved successfully: ' + data.result
        @_setValue data.result
      ), (err) ->
        env.logger.debug 'getVariable error:', err

  #############################################################################
    
  plugin = new ParticlePlugin
  return plugin
