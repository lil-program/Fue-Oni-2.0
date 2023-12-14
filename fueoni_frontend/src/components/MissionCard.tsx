import {
  Button,
  Card,
  CardActions,
  CardContent,
  Chip,
  Grid,
  Typography,
} from "@mui/material";
import { Difficulty } from "../api";
import apiClient from "../apiClient";
import { MissionWithId } from "../types";

interface MissionCardProps {
  mission: MissionWithId;
}

export default function MissionCard({ mission }: MissionCardProps) {
  const difficultyColor = () => {
    switch (mission.difficulty) {
      case Difficulty.Easy:
        return "success";
      case Difficulty.Normal:
        return "warning";
      case Difficulty.Hard:
        return "error";
      default:
        return "default";
    }
  };

  const handleDelete = async () => {
    try {
      await apiClient.deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(
        mission.id.toString()
      );
      // ここで削除後の処理を行うことができます。例えば、削除の成功メッセージを表示したり、ミッションリストを更新したりします。
    } catch (error) {
      // エラーハンドリングを行います。例えば、エラーメッセージを表示します。
      console.error(error);
    }
  };

  return (
    <Grid item xs={12} sm={6} md={4}>
      <Card
        style={{ boxShadow: "0 4px 8px 0 rgba(0,0,0,0.2)", margin: "10px" }}
      >
        <CardContent>
          <Grid container direction={"column"} rowSpacing={1}>
            <Grid item>
              <Typography variant="h5" component="div">
                {mission.title}
              </Typography>
            </Grid>
            <Grid item>
              <Chip
                variant="filled"
                color={difficultyColor()}
                size="small"
                label={`難易度: ${mission.difficulty}`}
              />
            </Grid>
            <Grid item>
              <Typography variant="subtitle1" color="text.secondary">
                時間制限: {mission.time_limit} minutes
              </Typography>
            </Grid>
            <Grid item>
              <Typography variant="body2" color="text.secondary">
                問題文: {mission.description}
              </Typography>
            </Grid>
            <Grid item>
              <Typography variant="body2" color="text.secondary">
                解答: {mission.answer}
              </Typography>
            </Grid>
          </Grid>
        </CardContent>
        <CardActions>
          <Button size="small">編集</Button>
          <Button size="small" onClick={handleDelete}>
            削除
          </Button>
        </CardActions>
      </Card>
    </Grid>
  );
}
