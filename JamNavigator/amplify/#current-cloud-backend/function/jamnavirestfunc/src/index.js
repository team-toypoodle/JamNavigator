
/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	API_JAMNAVIGATOR_GRAPHQLAPIIDOUTPUT
	API_JAMNAVIGATOR_GRAPHQLAPIENDPOINTOUTPUT
	API_JAMNAVIGATOR_GRAPHQLAPIKEYOUTPUT
	code
Amplify Params - DO NOT EDIT */

var tapeRepos = require('./DemotapeRepository.js');

// INTERVAL TIMER TRIGGER
exports.handler = async (event) => {
    const data = await tapeRepos.getItem()
    return {
        statusCode: 200,
        body: JSON.stringify(data),
    }
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
