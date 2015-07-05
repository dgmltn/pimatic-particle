# pimatic-particle
Pimatic plugin to interface with Particle connected devices

Plugin:
{
    'plugin': 'particle',
    'auth': '[my particle auth token]'
}

Device:

{
    'id': 'particle-motion-office',
    'name': 'Office',
    'eventType': 'motion-detected',
    'autoReset': true,
    'resetTime': 60000
}
