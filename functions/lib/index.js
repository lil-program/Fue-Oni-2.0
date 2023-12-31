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
exports.getUser = exports.onUserAdded = exports.onNewRoomCreated = exports.helloWorld = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const addOniPlayer_1 = require("./addOniPlayer");
const checkOniCount_1 = require("./checkOniCount");
const calculateRankings_1 = require("./calculateRankings");
// Start writing functions
// https://firebase.google.com/docs/functions/typescript
admin.initializeApp();
exports.addOniPlayer = addOniPlayer_1.addOniPlayer;
exports.checkOniCount = checkOniCount_1.checkOniCount;
exports.calculateRankings = calculateRankings_1.calculateRankings;
exports.helloWorld = (0, https_1.onRequest)((request, response) => {
    logger.info("Hello logs!", { structuredData: true });
    response.send("Hello from Firebase!");
});
exports.onNewRoomCreated = functions.database
    .ref("/games/{roomId}")
    .onCreate((snapshot, context) => {
    const roomId = context.params.roomId;
    const allRoomIdRef = admin.database().ref(`allroomId/${roomId}`);
    return allRoomIdRef.set(true);
});
exports.onUserAdded = functions.database
    .ref("/users/{userId}")
    .onCreate((snapshot) => {
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
//# sourceMappingURL=index.js.map