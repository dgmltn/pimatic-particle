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
var variable = 'tempf';

// Test login
var login = spark.login({accessToken: token});
login.then(function(token) {
  console.log('Logged in: ', token);
}, function(err) {
  console.log('spark error:', err);
});

// Test getVariable
login.then(function(token) {
  console.log("Testing getVariable...");
  return spark.getVariable(coreid, variable);
})
.then(function(data) {
  console.log(variable + ' retrieved successfully: ', data.result);
}, function(err) {
  console.log('spark error:', err);
});

// Test getEventStream
var eventStreamHandler = function(data) {
  console.log("Event: ", data);
};

login.then(function(token) {
  console.log("Testing getEventStream...");
  spark.getEventStream(false, config.coreid, eventStreamHandler);
}, function(err) {
  console.log('spark error:', err);
});
