import { useEffect, useState } from "react";
import Container from "@mui/material/Container";
import Grid from "@mui/material/Grid";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Typography from "@mui/material/Typography";
import Pagination from "@mui/material/Pagination";

type Mission = {
  id: number;
  title: string;
  description: string;
};

export default function MissionBoard() {
  const [missions, setMissions] = useState<Mission[]>([]);
  const [page, setPage] = useState(1);

  useEffect(() => {
    // ここでミッションを取得します
    // 以下はダミーデータです
    const fetchedMissions = [
      { id: 1, title: "Mission 1", description: "Description 1" },
      { id: 2, title: "Mission 2", description: "Description 2" },
      // ...
    ];
    setMissions(fetchedMissions);
  }, [page]);

  const handlePageChange = (_: unknown, value: number) => {
    setPage(value);
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Grid container spacing={2}>
        {missions.map((mission) => (
          <Grid item xs={12} sm={6} md={4} key={mission.id}>
            <Card>
              <CardContent>
                <Typography variant="h5" component="div">
                  {mission.title}
                </Typography>
                <Typography variant="body2">{mission.description}</Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
      <Pagination count={10} page={page} onChange={handlePageChange} />
    </Container>
  );
}
