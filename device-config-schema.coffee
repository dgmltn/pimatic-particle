module.exports ={
  title: "pimatic-particle device config schemas"
  ParticlePresenceSensor: {
    title: "ParticlePresenceSensor config options"
    type: "object"
    properties: 
      eventType:
        description: "Value of 'type' field in Particle server event (e.g. 'motion-detected')"
        format: "string"
  }
}
