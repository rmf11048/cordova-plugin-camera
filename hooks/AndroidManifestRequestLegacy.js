const path = require('path');
const fs = require('fs');
const { ConfigParser } = require('cordova-common');
const { Console } = require('console');

module.exports = function (context) {
    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;
    
    var manifestPath = path.join(projectRoot, 'platforms/android/app/src/main/AndroidManifest.xml');
    if (fs.existsSync(manifestPath)) {
		fs.readFile(manifestPath, 'utf8', function (err,data) {
                    if (err) {
                      throw new Error('Camera Plugin: Unable to read config.xml: ' + err);
                    }
                    console.log("Vai entrar no IF")
                    if (data.includes("<edit-config file=\"app/src/main/AndroidManifest.xml\" mode=\"merge\" target=\"/manifest/application\">")){
                      console.log("Entrou no IF!")
                      var result = data.replace(/<application/g, '<application android:requestLegacyExternalStorage="true"');
                      fs.writeFile(manifestPath, result, 'utf8', function (err) {
                      if (err) 
                        {throw new Error('Camera Plugin: Unable to write into config.xml: ' + err);}
                      else 
                        {console.log("Camera Plugin: config.xml patched for using requestLegacyExternalStorage successfuly!");}
                      })
                    }
                  });    	
    }

};