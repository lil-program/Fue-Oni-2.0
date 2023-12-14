import {
  Button,
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
} from "@mui/material";
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import apiClient from "../../apiClient";
import { MissionWithId } from "../../types";

interface RouteParams {
  [key: string]: string | undefined;
}

export default function MissionEdit() {
  const { id } = useParams<RouteParams>();
  const [mission, setMission] = useState<MissionWithId | null>(null);

  useEffect(() => {
    const fetchMission = async () => {
      if (!id) {
        console.error("Mission ID is undefined");
        return;
      }

      try {
        const response =
          await apiClient.getMissionApiV1MissionsMissionMissionIdGet(id);
        const missionWithId: MissionWithId = {
          ...response.data,
          id: id,
        };
        setMission(missionWithId);
      } catch (error) {
        console.error(error);
      }
    };

    fetchMission();
  }, [id]);

  if (!mission) {
    return <div>Loading...</div>;
  }

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
              <TextField label="Title" defaultValue={mission.title} />
            </Grid>
            <Grid item>
              <Typography variant="body2" color="text.secondary">
                問題文: {mission.description}
              </Typography>
              <TextField
                label="Description"
                defaultValue={mission.description}
              />
            </Grid>
            <Grid item>
              <Typography variant="body2" color="text.secondary">
                解答: {mission.answer}
              </Typography>
              <TextField label="Answer" defaultValue={mission.answer} />
            </Grid>
          </Grid>
        </CardContent>
        <Button size="small">保存</Button>
      </Card>
    </Grid>
  );
}
