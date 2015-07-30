// A simple test that connects to your Particle event stream
// for a specific device (specified in configuration.json),
// and logs events as they happen.

var spark = require('spark');

// configuration.json should look like:
// {
//    "token": "<your particle.io token>",
//    "coreid": "<your particle.io coreid>"
//}
var configurationFile = 'configuration.json';
var fs = require('fs');

var config = JSON.parse(
  fs.readFileSync(configurationFile)
);

var token = config.token;
var coreid = config.coreid;

var eventStreamHandler = function(data) {
  console.log("Event: ", data);
};

spark.login({accessToken: token}).then(function(token) {
  console.log("Testing getEventStream...");
  spark.getEventStream(false, config.coreid, eventStreamHandler);
}, function(err) {
  console.log('spark error:', err);
});
