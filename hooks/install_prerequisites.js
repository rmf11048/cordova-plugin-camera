console.log("Running hook to install push notifications pre-requisites");

var child_process = require('node_modules/child_process');
var deferral = require('node_modules/q').defer();

module.exports = function (context) {
  var output = child_process.exec('npm install', {cwd: __dirname}, function (error) {
    if (error !== null) {
      console.log('exec error: ' + error);
      deferral.reject('npm installation failed');
    }
    else {
      deferral.resolve();
    }
  });

  return deferral.promise;
};
