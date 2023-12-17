import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// 'oniPlayers'の数が変更されたときにトリガーされる関数
export const checkOniCount = functions.database
  .ref("/games/{roomId}/oniPlayers/{playerId}")
  .onWrite((change, context) => {
    // ルームIDを取得
    const roomId: string = context.params.roomId;

    // データベースの'oniPlayers'と'players'への参照を取得
    const oniPlayersRef = admin.database().ref(`/games/${roomId}/oniPlayers`);
    const playersRef = admin.database().ref(`/games/${roomId}/players`);

    // 'oniPlayers'の現在の数と'players'の数をフェッチ
    return Promise.all([
      oniPlayersRef.once("value"),
      playersRef.once("value"),
    ]).then(([oniPlayersSnapshot, playersSnapshot]) => {
      const oniPlayersCount: number = oniPlayersSnapshot.numChildren();
      const playersCount: number = playersSnapshot.numChildren();

      // 'oniPlayers'の数が'players'の数と等しい場合、'gameStart'をfalseに設定
      if (oniPlayersCount === playersCount) {
        return admin
          .database()
          .ref(`/games/${roomId}/settings/gameStart`)
          .set(false);
      } else {
        // 'oniPlayers'の数が'players'の数と等しくない場合、何もしない
        return null;
      }
    });
  });
