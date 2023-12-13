"use strict";
/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUser = exports.onUserAdded = exports.helloWorld = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Start writing functions
// https://firebase.google.com/docs/functions/typescript
admin.initializeApp();
exports.helloWorld = (0, https_1.onRequest)((request, response) => {
  logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});
exports.onUserAdded = functions.database
  .ref("/users/{userId}")
  .onCreate((snapshot, context) => {
    const userData = snapshot.val();
    logger.info("User data:", userData);
    return null;
  });
exports.getUser = functions.https.onRequest((req, res) => {
  const userId = req.query.userId;
  if (!userId) {
    res.status(400).send("Missing user ID");
    return;
  }
  return admin
    .database()
    .ref(`/users/${userId}`)
    .once("value")
    .then((snapshot) => {
      res.status(200).send(snapshot.val());
      return;
    })
    .catch((error) => {
      res.status(500).send(error);
      return;
    });
});
exports.scheduledFunction = functions.pubsub
  .schedule("every 10 minutes")
  .onRun((context) => {
    console.log("This will be run every 10 minutes!");
    return null;
  });
//# sourceMappingURL=index.js.map
