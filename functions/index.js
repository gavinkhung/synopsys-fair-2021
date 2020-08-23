const functions = require('firebase-functions');

const admin = require('firebase-admin');
const { stringify } = require('querystring');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.sendNotif = functions.https.onRequest((request, response) => {
  functions.logger.info("plesae this shoudl work"); 
  functions.logger.info(request.body);
//   functions.logger.info(request.body.token); 
// functions.logger.write(request.body);

    var message = JSON.parse(request.body); 


    admin.messaging().send(message).then((resp) => {
        // functions.logger.write("Sent succesfully"+ resp); 
        response.header({
            "Access-Control-Allow-Origin": "*"
        })
        response.send("true");
        
        return true; 
    }).catch((err) => {
        functions.logger.log("Error detected"+ err); 
        response.header({
            "Access-Control-Allow-Origin": "*"
        });
        response.send("false");
        
        return false; 
    })
 
});
