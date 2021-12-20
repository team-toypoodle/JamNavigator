/*
Use the following code to retrieve configured secrets from SSM:

const aws = require('aws-sdk');

const { Parameters } = await (new aws.SSM())
    .getParameters({
    Names: ["secretkey"].map(secretName => process.env[secretName]),
    WithDecryption: true,
    })
    .promise();

Parameters will be of the form { Name: 'secretName', Value: 'secretValue', ... }[]
*/


/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	key
Amplify Params - DO NOT EDIT */

var express = require('express')
var bodyParser = require('body-parser')
var awsServerlessExpressMiddleware = require('aws-serverless-express/middleware')
var admin = require("firebase-admin");
var serviceAccount = require('serviceAccount.json');

// Initi for Firebase
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

// declare a new express app
var app = express()
app.use(bodyParser.json())
app.use(awsServerlessExpressMiddleware.eventContext())

// Enable CORS for all methods
app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "*")
    next()
});


/**********************
 * Example get method *
 **********************/


app.post('/push/:token', async (req, res) => {

    console.log("POST-A : " + item);

    // prepare fcm message
    // https://firebase.google.com/docs/cloud-messaging/send-message?hl=ja
    const fcm = admin.messaging();
    var item = {
        notification: { title: req.body.title, body: req.body.body },
        apns: {
            payload: {
                aps: {
                    sound: "default"
                }
            }
        },
    };
    if( req.body.type == "token"){
        item.token = req.params.token;
    }
    if( req.body.type == "topic"){
        item.topic = req.params.token;
    }
    console.log("POST-A : " + item);
    const messages = [];
    messages.push(item);

    try {
        console.log('------ PUSH REQUESTED1 !!');
        console.log(item);
        const response = await fcm.sendAll(messages);
        console.log(response.successCount + ' messages were sent successfully');
    }
    catch( ex ) {
        console.log("*** FCM PUSH ERROR1 : " + ex);
    }

    res.json({success: 'post-1 call completed.', url: req.url, body: req.body});
});


app.get('/', async (req, res) => {
    // type: 'topic', token: 'request-topic', title: 'Hey!!', message: 'Piko!' 
    const e = req.apiGateway.event;
    console.log("GET-A : " + e);
    const fcm = admin.messaging();
    const item = {
        notification: { title: e.title, body: e.message },
        apns: {
            payload: {
                aps: {
                    sound: "default"
                }
            }
        },
    };
    if( e.type == "token"){
        item.token = e.token;
    }
    if( e.type == "topic"){
        item.topic = e.token;
    }
    const messages = [];
    messages.push(item);

    try {
        console.log('------ PUSH REQUESTED2 !!' );
        console.log(item);
        const response = await fcm.sendAll(messages);
        console.log(response.successCount + ' messages were sent successfully');
    }
    catch( ex ) {
        console.log("*** FCM PUSH ERROR2 : " + ex);
    }
    res.json({success: 'get-a call succeed!', url: req.url});
});


app.post('/push/:token/*', function(req, res) {
    res.json({success: 'post-2 call succeed!', url: req.url, body: req.body});
});

/****************************
* Example put method *
****************************/

app.put('/push/:token', function(req, res) {
    // Add your code here
    res.json({success: 'put-1 call succeed!', url: req.url, body: req.body})
});

app.put('/push/:token/*', function(req, res) {
    // Add your code here
    res.json({success: 'put-2 call succeed!', url: req.url, body: req.body})
});

/****************************
* Example delete method *
****************************/

app.delete('/push/:token', function(req, res) {
    // Add your code here
    res.json({success: 'delete-1 call succeed!', url: req.url});
});

app.delete('/push/:token/*', function(req, res) {
    // Add your code here
    res.json({success: 'delete-2 call succeed!', url: req.url});
});

app.listen(3000, function() {
    console.log("App started")
});

// Export the app object. When executing the application local this does nothing. However,
// to port it to AWS Lambda we will create a wrapper around that will load the app from
// this file
module.exports = app
