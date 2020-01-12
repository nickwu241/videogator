const functions = require("firebase-functions");
const { PubSub } = require("@google-cloud/pubsub");

const projectId = "videogator";
const topicName = "commands";

exports.dialogflowHandler = functions.https.onRequest((request, response) => {
  console.log("Dialogflow Request headers: " + JSON.stringify(request.headers));
  console.log("Dialogflow Request body: " + JSON.stringify(request.body));
  const pubsub = new PubSub({ projectId });
  const topic = pubsub.topic(topicName);

  topic.publish(Buffer.from(request.body.queryResult.queryText));
  response.send("OK");
});
