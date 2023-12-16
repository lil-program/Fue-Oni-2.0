import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// 'oniPlayers'の数が変更されたときにトリガーされる関数
export const checkOniCount = functions.database
  .ref("/games/{roomId}/oniPlayers/{playerId}")
  .onWrite((change, context) => {
    // ルームIDを取得
    const roomId: string = context.params.roomId;

    // データベースの'oniPlayers'と'initialOniCount'への参照を取得
    const oniPlayersRef = admin.database().ref(`/games/${roomId}/oniPlayers`);
    const initialOniCountRef = admin
      .database()
      .ref(`/games/${roomId}/settings/initialOniCount`);

    // 'oniPlayers'の現在の数と'initialOniCount'をフェッチ
    return Promise.all([
      oniPlayersRef.once("value"),
      initialOniCountRef.once("value"),
    ]).then(([oniPlayersSnapshot, initialOniCountSnapshot]) => {
      const oniPlayersCount: number = oniPlayersSnapshot.numChildren();
      const initialOniCount: number = initialOniCountSnapshot.val();

      // 'oniPlayers'の数が'initialOniCount'と等しい場合、'gameStart'をfalseに設定
      if (oniPlayersCount === initialOniCount) {
        return admin
          .database()
          .ref(`/games/${roomId}/settings/gameStart`)
          .set(false);
      } else {
        // 'oniPlayers'の数が'initialOniCount'と等しくない場合、何もしない
        return null;
      }
    });
  });
