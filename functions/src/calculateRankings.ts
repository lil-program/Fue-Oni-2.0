import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// 'gameStart'がfalseになったときにトリガーされる関数
export const calculateRankings = functions.database
  .ref("/games/{roomId}/settings/gameStart")
  .onUpdate(async (change, context) => {
    // 'gameStart'の新しい値を取得
    const gameStart: boolean = change.after.val();

    // ゲームが終了した場合（'gameStart'がfalseになった場合）
    if (!gameStart) {
      // ルームIDを取得
      const roomId: string = context.params.roomId;

      // データベースの'oniPlayers'と'players'への参照を取得
      const oniPlayersRef = admin.database().ref(`/games/${roomId}/oniPlayers`);
      const playersRef = admin.database().ref(`/games/${roomId}/players`);

      // 'oniPlayers'と'players'をフェッチ
      const [oniPlayersSnapshot, playersSnapshot] = await Promise.all([
        oniPlayersRef.once("value"),
        playersRef.once("value"),
      ]);

      // 順位を計算
      const oniPlayers = oniPlayersSnapshot.val();
      const players = playersSnapshot.val();
      const sortedPlayers = Object.keys(players).sort((a, b) => {
        if (oniPlayers[a] && oniPlayers[b]) {
          // 両方のプレイヤーが鬼である場合、鬼になった時間でソート
          return oniPlayers[a] - oniPlayers[b];
        } else if (oniPlayers[a]) {
          // プレイヤー'a'が鬼でプレイヤー'b'が鬼でない場合、'b'の順位が上
          return 1;
        } else if (oniPlayers[b]) {
          // プレイヤー'b'が鬼でプレイヤー'a'が鬼でない場合、'a'の順位が上
          return -1;
        } else {
          // どちらのプレイヤーも鬼でない場合、順位は同じ
          return 0;
        }
      });

      // 各プレイヤーに順位を割り当て
      let previousPlayer: string | null = null;
      let previousRank = 0;
      const rankings = sortedPlayers.map((player, index) => {
        let rank;
        if (
          previousPlayer &&
          oniPlayers[player] === oniPlayers[previousPlayer]
        ) {
          // 前のプレイヤーと同じ時間に鬼になった場合、同じ順位を割り当てる
          rank = previousRank;
        } else {
          // それ以外の場合、新しい順位を割り当てる
          rank = index + 1;
        }
        previousPlayer = player;
        previousRank = rank;
        return { player, rank };
      });

      // 順位をデータベースに保存
      const rankingsRef = admin.database().ref(`/games/${roomId}/rankings`);
      await rankingsRef.set(rankings);
    }
  });
