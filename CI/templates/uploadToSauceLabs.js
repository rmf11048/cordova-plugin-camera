var fetch = require('node-fetch');
var btoa = require('btoa');
var fs = require("fs");
var configurations = require('./configurations.json');

if(configurations.sauceLabsInfo == null) {
    throw new Error("Missing sauceLabsInfo object configuration in package.json");
}

if(process.env.npm_config_buildsPath == null) {
    throw new Error("Missing builds folder path argument \"buildsPath\"");
}

if(process.env.npm_config_sauceUser == null) {
    throw new Error("Missing Sauce Labs User");
}

const restApiEndpoint = "https://app.testobject.com/api/rest";
var dir = process.env.npm_config_buildsPath;
var sauceLabsUser = process.env.npm_config_sauceUser;
var sauceLabsInfo = configurations.sauceLabsInfo;

console.log("Start process")

var uploads = [];

fs.readdirSync(dir).forEach(function(appDir) {
    console.log("Start reading directorys")
    fs.stat(dir + appDir, (err, stats) => {
      if (err) { 
        throw new Error(err);
      } else if (stats.isDirectory()) {
        console.log("Directory " + stats)
        console.log("Read files on" + dir + appDir)
        fs.readdirSync(dir + appDir).forEach(function(appFile) {
            console.log("File " + appFile)
            var sauceAppDetails = sauceLabsInfo[appDir];
            if (sauceAppDetails != undefined) {
                console.log("Start uploading to Sauce Labs app " + appDir);
                if (appFile.includes("ios")) {
                    console.log("Uploading iOS");
                    uploadApplication(sauceAppDetails.iosAPIKey, "MABS 7.0 Pipeline", false, dir + appDir + "/" + appFile)
                        .then(appID => console.log("App " + appDir + " for ios platform was uploaded. With ID: " + appID))
                        .catch(error => console.log("An error ocurred while uploading app " + appDir + " for ios platform with error: " + error))
                } else if (appFile.includes("android")) {
                    console.log("Uploading Android");
                     uploadApplication(sauceAppDetails.androidAPIKey, "MABS 7.0 Pipeline", false, dir + appDir + "/" + appFile)
                        .then(appID => console.log("App " + appDir + " for android platform was uploaded. With ID: " + appID))
                        .catch(error => console.log("An error ocurred while uploading app " + appDir + " for android platform with error: " + error))
                }
            }
        });
      }
    });
});

async function uploadApplication(apiKey, appVersionName, appActive, applicationPath) {
    const readStream = fs.createReadStream(applicationPath);
    var response = await fetch(restApiEndpoint + "/storage/upload", {
        method: `POST`,
        headers: {
            'Authorization': getApplicationAuthorizationHeader(apiKey),
            'App-Identifier': apiKey,
            'App-DisplayName': appVersionName,
            'App-Active': appActive,
        },
        body: readStream,
    });
    return await response.text();
}

function getApplicationAuthorizationHeader(apiKey) {
    return "Basic " + btoa(sauceLabsUser + ":" + apiKey);
}