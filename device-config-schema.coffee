module.exports ={
  title: "pimatic-particle device config schemas"
  ParticlePresenceSensor: {
    title: "ParticlePresenceSensor config options"
    type: "object"
    properties: 
      coreid:
        description: "The id of the particular Particle core device"
        format: "string"
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
  ParticleVariable: {
    title: "ParticleVariable config options"
    type: "object"
    properties:
      coreid:
        description: "The id of the particular Particle core device"
        format: "string"
      variable:
        description: "The name of the Particle device variable to retrieve"
        format: "string"
      intervalMs:
        description: "Amount of time (in MS) to wait before trying a second query"
        format: "integer"
        default: 60000
      type:
        description: "The variable type returned from Particle: 'string' or 'number'"
        format: "string"
        default: "string"
      unit:
        description: "Unit represented by this variable. Only valid if type == 'number'"
        format: "string"
        default: ""
      acronym:
        description: "Acronym/label of this variable."
        format: "string"
        default: ""
  }
  ParticleButtons: {
    title: "ParticleButtons config options"
    type: "object"
    properties:
      coreid:
        description: "The id of the particular Particle core device"
        format: "string"
      buttons:
        description: "Buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              description: "Id must match the name of the function of the Particle device"
              type: "string"
            text:
              type: "string"
            confirm:
              description: "Ask the user to confirm the button press"
              type: "boolean"
              default: false
            params:
              description: "Parameters to send to the Particle device along with the callFunction"
              type: "string"
  }
}
