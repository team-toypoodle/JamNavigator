
/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	API_JAMNAVIGATOR_GRAPHQLAPIIDOUTPUT
	API_JAMNAVIGATOR_GRAPHQLAPIENDPOINTOUTPUT
	API_JAMNAVIGATOR_GRAPHQLAPIKEYOUTPUT
	code
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
var tapeRepos = require('./DemotapeRepository.js');

// INTERVAL TIMER TRIGGER
exports.handler = async (event) => {

  // call lambda function sample
  //await pushToTopicAsync("request-topic", "Hi! Hello !!", "How are you ?");
  //await pushToTokenAsync("e1-g15ILyUOCgr1bi5tlB8:APA91bGQouAWNFK7si71ubBWQ4XkSgoO-uiBl-4euf7GiztOWNg0BVLteoA04yzwdtqCQTgNxNFuchLyElOWQTHvcwIEzNlqRpGDRru4lCQTJl_dtkz0HRMk6GYfKYVOrqEdasuJI0vo", "おーい", "こんにちは！")

  // get GraphQL data sample  
  const data = await tapeRepos.getItem()
  return {
      statusCode: 200,
      body: JSON.stringify(data),
  }
}

// トピックに対して通知要求
const pushToTopicAsync = async (topicName, pushTitle, pushMessage) => {
  let lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
  const params = {
    FunctionName: "arn:aws:lambda:ap-northeast-1:456263665996:function:jamnavipushapi-dev", // Lambda 関数の ARN を指定
    InvocationType: "RequestResponse",
    Payload: JSON.stringify({
      type: "topic",
      token: topicName,
      title: pushTitle,
      message: pushMessage,
    }),
  };
  const result = await lambda.invoke(params).promise();
}

// レジストレーショントークンに対して通知要求
const pushToTokenAsync = async (tokenStr, pushTitle, pushMessage) => {
  let lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
  const params = {
    FunctionName: "arn:aws:lambda:ap-northeast-1:456263665996:function:jamnavipushapi-dev", // Lambda 関数の ARN を指定
    InvocationType: "RequestResponse",
    Payload: JSON.stringify({
      type: "token",
      token: tokenStr,
      title: pushTitle,
      message: pushMessage,
    }),
  };
  const result = await lambda.invoke(params).promise();
}


/*
Use the following code to retrieve configured secrets from SSM:

const { Parameters } = await (new AWS.SSM())
  .getParameters({
    Names: ["secret"].map(secretName => process.env[secretName]),
    WithDecryption: true,
  })
  .promise();

Parameters will be of the form { Name: 'secretName', Value: 'secretValue', ... }[]
*/
