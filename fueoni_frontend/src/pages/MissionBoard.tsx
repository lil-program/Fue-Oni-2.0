import Container from "@mui/material/Container";
import Grid from "@mui/material/Grid";
import Pagination from "@mui/material/Pagination";
import { useEffect, useState } from "react";
import apiClient from "../apiClient";
import MissionCard from "../components/MissionCard";
import { MissionWithId } from "../types";

export default function MissionBoard() {
  const [missions, setMissions] = useState<MissionWithId[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  const limit = 10;

  useEffect(() => {
    const fetchMissions = async () => {
      try {
        const startAfter = limit * (page - 1);
        const response = await apiClient.getMissionsApiV1MissionsMissionsGet(
          limit,
          startAfter
        );
        const missionsArray = Object.entries(response.data.missions).map(
          ([id, mission]) => ({ id, ...mission })
        );
        console.log(missionsArray);
        setMissions(missionsArray);
        setTotalPages(response.data.paging_info.total_pages);
      } catch (error) {
        console.error(error);
      }
    };

    fetchMissions();
  }, [page]);

  const handlePageChange = (_: unknown, value: number) => {
    setPage(value);
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Grid container spacing={2}>
        {missions.map((mission) => (
          <MissionCard mission={mission} key={mission.id} />
        ))}
      </Grid>
      <Pagination
        count={totalPages}
        page={page}
        onChange={handlePageChange}
        style={{ justifyContent: "center", display: "flex" }}
      />
    </Container>
  );
}
