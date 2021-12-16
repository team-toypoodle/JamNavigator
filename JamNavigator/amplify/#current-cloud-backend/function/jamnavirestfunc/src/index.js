
/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	API_JAMNAVIGATOR_GRAPHQLAPIIDOUTPUT
	API_JAMNAVIGATOR_GRAPHQLAPIENDPOINTOUTPUT
	API_JAMNAVIGATOR_GRAPHQLAPIKEYOUTPUT
	code
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();

const paramsc = {
  TableName : 'Demotape-7kqkbkjq7jholel7ettglx37re-dev',
  Item: {
    id: '99999999-9999-4E7E-9CD9-EAEAE9C8F97C',
    name: 'Tono Piano',
    generatedDateTime: '2021-12-13 13:34:45',
    userId: 'tonosaki',
    nStar: 5,
    hashMemo: '#Hey my music',
    genres: ["Rock"],
    instruments: ["Guitar"],
    _version: 1,
    __typename: 'Demotape',
    _lastChangedAt: 1639373577337,
    s3StorageKey: 'hoge',
    attributes: null,
    comments: null,
    createdAt: '2021-12-14T06:51:04.409Z',
    updatedAt: '2021-12-14T06:51:04.409Z',
  }
}

const paramsg = {
  TableName : 'Demotape-7kqkbkjq7jholel7ettglx37re-dev',
  Key: {
    id: '06D14B3D-F30E-4E7E-9CD9-EAEAE9C8F97C'
  }
}


async function createItem(){
  try {
    await docClient.put(paramsc).promise();
  } catch (err) {
    return err;
  }
}

async function getItem(){
  try {
    const data = await docClient.get(paramsg).promise()
    return data
  } catch (err) {
    return err
  }
}


exports.handler = async (event) => {
    try {
        await getItem()
        return {
            statusCode: 200,
            body: JSON.stringify(data),
        }
    }
    catch(err) {
        return {
            statusCode: 500,
            body: JSON.stringify('Tonosaki ERROR 500'),
        }
    }
};

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
