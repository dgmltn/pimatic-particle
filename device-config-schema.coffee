module.exports ={
  title: "pimatic-particle device config schemas"
  ParticlePresenceSensor: {
    title: "ParticlePresenceSensor config options"
    type: "object"
    properties: 
      eventType:
        description: "Value of 'type' field in Particle server event (e.g. 'motion-detected')"
        format: "string"
      autoReset:
        description: "Reset the state to absent after resetTime"
        type: "boolean"
        default: true
      resetTime:
        description: "Time after that the presence value is reseted to absent."
        type: "integer"
        default: 60000
  }
}
