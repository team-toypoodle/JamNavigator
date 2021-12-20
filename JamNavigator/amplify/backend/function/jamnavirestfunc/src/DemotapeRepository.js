
const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();

// https://docs.amplify.aws/guides/functions/dynamodb-from-js-lambda/q/platform/ios/#scanning-a-table

exports.createItem = async () => {
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

    try {
        await docClient.put(paramsc).promise();
    }
    catch (err) {
        return err;
    }
}

exports.listItems = async () => {
    const paramss = {
        TableName : 'Demotape-7kqkbkjq7jholel7ettglx37re-dev',
    }

    try {
        const data = await docClient.scan(paramss).promise()
        return data
    }
    catch (err) {
        return err
    }
}


exports.getItem = async () => {
    const paramsg = {
        TableName : 'Demotape-7kqkbkjq7jholel7ettglx37re-dev',  
        Key: {
            id: '06D14B3D-F30E-4E7E-9CD9-EAEAE9C8F97C'
        }
    }

    try {
        const data = await docClient.get(paramsg).promise()
        return data
    }
    catch (err) {
        return err
    }
}

