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

var openStream = function() {
  const req = spark.getEventStream(false, config.coreid, eventStreamHandler);
  req.on('end', function() {
    console.warn("Spark event stream ended! re-opening in 3 seconds...");
    setTimeout(openStream, 3 * 1000);
  });
}

spark.login({accessToken: token}).then(function(token) {
  console.log("Testing getEventStream...");
  openStream();
}, function(err) {
  console.log('spark error:', err);
});
