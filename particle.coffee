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

      @framework.deviceManager.registerDeviceClass("ParticleButtons", {
        configDef: deviceConfigDef.ParticleButtons,
        createCallback: (config, lastState) => new ParticleButtons(config, lastState)
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
      @_openStream()

    # Listen to events
    _openStream: ->
      env.logger.debug 'Particle.getEventStream opening'
      req = Particle.getEventStream @eventType, @coreid, @_eventListener
      req.on 'end', ->
        env.logger.warn 'Particle.getEventStream ended. Resopening in 3s'
        setTimeout @_openStream, 3000

    # Use the fat arrow here for access to @changePresenceTo method
    _eventListener: (e) =>
      env.logger.debug JSON.stringify(e)
      @changePresenceTo(yes)

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
    constructor: (@config, lastState) ->
      valueAttribute = {
        description: 'The current value of the Variable'
        type: 'string'
      }

      if config.type? and config.type.length > 0
        valueAttribute.type = config.type

      if config.unit? and config.unit.length > 0
        valueAttribute.unit = config.unit

      if config.acronym?
        valueAttribute.acronym = config.acronym

      @name = config.name
      @id = config.id
      @coreid = config.coreid
      @intervalMs = config.intervalMs
      @variable = config.variable

      if valueAttribute.type == 'number'
        @_value = parseFloat lastState?.value?.value
      else
        @_value = lastState?.value?.value

      @addAttribute('value', valueAttribute)
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
        @_setValue data.result
      ), (err) ->
        env.logger.debug 'Particle.getVariable error:', err


  #############################################################################
  # ParticleButtons
  #############################################################################

  class ParticleButtons extends env.devices.ButtonsDevice

    constructor: (@config, lastState) ->
      @coreid = config.coreid
      super(@config)

    buttonPressed: (buttonId) =>
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          return @callFunction b.id, b.params
      throw new Error("No button with the id #{buttonId} found")

    callFunction: (functionName, funcParam) =>
      env.logger.debug "Particle: callFunction: " + functionName + " " + funcParam
      Particle.callFunction @coreid, functionName, funcParam
      .then ((data) =>
        env.logger.debug "Particle: callFunction result: ", data
        # @_setValue data.return_value
      ), (err) ->
        env.logger.debug 'Particle.callFunction error:', err

  #############################################################################
    
  plugin = new ParticlePlugin
  return plugin
