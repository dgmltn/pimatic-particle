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

spark.login({accessToken: token})
.then(function(token) {
  console.log('Logged in: ', token);
  return spark.getVariable(coreid, variable);
})
.then(function(data) {
  console.log(variable + ' retrieved successfully: ' + data.result);
}, function(err) {
  console.log('spark error:', err);
});
