pimatic-particle
================

Pimatic plugin to interface with ([Particle][1]) connected devices. You must 
([generate an auth token][2]) manually before using this plugin.

Plugin:
-------

```JSON
{
    'plugin': 'particle',
    'auth': '[my particle auth token]'
}
```

ParticlePresenseSensor:
----------------------

This Pimatic device simply listens for events published by your Particle device
(see ([publish][3])). When an event is detected, this Pimatic device is "present"
for the amount of time as configured by resetTime.

```JSON
{
    'id': 'particle-motion-office',
    'class': 'ParticlePresenceSensor',
    'name': 'Office',
    'eventType': 'motion-detected',
    'autoReset': true,
    'resetTime': 60000
}
```

[1] http://particle.io
[2] http://docs.particle.io/photon/api/#authentication-generate-a-new-access-token
[3] http://docs.particle.io/core/firmware/#spark-publish
