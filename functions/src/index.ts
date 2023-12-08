/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

admin.initializeApp();

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

export const onNewRoomCreated = functions.database
  .ref("/games/{roomId}")
  .onCreate((snapshot, context) => {
    const roomId = context.params.roomId;
    const allRoomIdRef = admin.database().ref(`allroomId/${roomId}`);
    return allRoomIdRef.set(true);
  });

export const onUserAdded = functions.database
  .ref("/users/{userId}")
  .onCreate((snapshot) => {
    const userData = snapshot.val();
    logger.info("User data:", userData);
    return null;
  });

export const getUser = functions.https.onRequest((req, res) => {
  const userId = req.query.userId;
  if (!userId) {
    res.status(400).send("Missing user ID");
    return;
  }
  return admin
    .database()
    .ref("/users/${userId}")
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
  .onRun(() => {
    console.log("This will be run every 10 minutes!");
    return null;
  });
