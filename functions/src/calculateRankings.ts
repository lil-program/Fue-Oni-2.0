import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const calculateRankings = functions.database
  .ref("/games/{roomId}/settings/gameStart")
  .onUpdate(async (change, context) => {
    const gameStart: boolean = change.after.val();

    if (!gameStart) {
      const roomId: string = context.params.roomId;
      const oniPlayersRef = admin.database().ref(`/games/${roomId}/oniPlayers`);
      const playersRef = admin.database().ref(`/games/${roomId}/players`);

      const [oniPlayersSnapshot, playersSnapshot] = await Promise.all([
        oniPlayersRef.once("value"),
        playersRef.once("value"),
      ]);

      const oniPlayers = oniPlayersSnapshot.val();
      const players = playersSnapshot.val();

      // 各プレイヤーの名前を取得
      const playerNames = await Promise.all(
        Object.keys(players).map(async (playerId) => {
          const snapshot = await admin
            .database()
            .ref(`/users/${playerId}/name`)
            .once("value");
          return snapshot.val();
        })
      );

      const sortedPlayers = Object.keys(players).sort((a, b) => {
        if (oniPlayers[a] && oniPlayers[b]) {
          return oniPlayers[a] - oniPlayers[b];
        } else if (oniPlayers[a]) {
          return 1;
        } else if (oniPlayers[b]) {
          return -1;
        } else {
          return 0;
        }
      });

      let previousPlayer: string | null = null;
      let previousRank = 0;
      const rankings = sortedPlayers.map((player, index) => {
        let rank;
        if (
          previousPlayer &&
          oniPlayers[player] === oniPlayers[previousPlayer]
        ) {
          rank = previousRank;
        } else {
          rank = index + 1;
        }
        previousPlayer = player;
        previousRank = rank;
        return {
          player,
          rank,
          name: playerNames[index], // プレイヤーの名前を追加
          isOni: !!oniPlayers[player], // プレイヤーが最終的に鬼であったかどうかを追加
        };
      });

      const rankingsRef = admin.database().ref(`/games/${roomId}/rankings`);
      await rankingsRef.set(rankings);
    }
  });
