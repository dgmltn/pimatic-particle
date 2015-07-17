pimatic-particle
================

Pimatic plugin to interface with [Particle][1] connected devices. You must 
[generate an auth token][2] manually before using this plugin.

Plugin:
-------

```JSON
{
    "plugin": "particle",
    "auth": "[my particle auth token]"
}
```

ParticlePresenseSensor:
-----------------------

This Pimatic device simply listens for events published by your Particle device
(see [publish][3]). When an event is detected, this Pimatic device is "present"
for the amount of time as configured by resetTime. deviceId is optional here.

```JSON
{
    "id": "particle-motion-office",
    "class": "ParticlePresenceSensor",
    "name": "Office",
    "coreid": "1234567890abcdef",
    "eventType": "motion-detected",
    "autoReset": true,
    "resetTime": 60000,
}
```

ParticleVariable:
-----------------

This Pimatic device queries your Particle device for a variable that you have
setup, at a fixed rate. The interval time is specified in ms.

```JSON
{
    "id": "particle-temperature",
    "class": "ParticleVariable",
    "coreid": "1234567890abcdef",
    "name": "Office Temperature",
    "variable": "tempf",
    "intervalMs": 60000
}
```

 [1]: http://particle.io
 [2]: http://docs.particle.io/photon/api/#authentication-generate-a-new-access-token
 [3]: http://docs.particle.io/core/firmware/#spark-publish
