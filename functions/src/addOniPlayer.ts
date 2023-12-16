import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// 'oni'の値が変更されたときにトリガーされる関数
export const addOniPlayer = functions.database
  .ref("/games/{roomId}/players/{playerId}/oni")
  .onWrite((change, context) => {
    // 'oni'の現在の値を取得
    const isOni: boolean | null = change.after.val();

    // プレイヤーIDを取得
    const playerId: string = context.params.playerId;

    // ルームIDを取得
    const roomId: string = context.params.roomId;

    // 'oni'がtrueの場合、プレイヤーIDを'oniPlayers'に追加
    if (isOni === true) {
      return admin
        .database()
        .ref(`/games/${roomId}/oniPlayers/${playerId}`)
        .set(true);
    } else {
      // 'oni'がtrueでない場合、プレイヤーIDを'oniPlayers'から削除
      return admin
        .database()
        .ref(`/games/${roomId}/oniPlayers/${playerId}`)
        .remove();
    }
  });
