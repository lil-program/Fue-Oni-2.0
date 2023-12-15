import Container from "@mui/material/Container";
import Grid from "@mui/material/Grid";
import Pagination from "@mui/material/Pagination";
import { useEffect, useState } from "react";
import apiClient from "../../apiClient";
import MissionCard from "../../components/MissionCard";
import { MissionWithId } from "../../types";
import CircularProgress from "@mui/material/CircularProgress";
import Box from "@mui/material/Box";

export default function MissionList() {
  const [missions, setMissions] = useState<MissionWithId[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [isLoading, setIsLoading] = useState(false);

  const limit = 10;

  useEffect(() => {
    const fetchMissions = async () => {
      setIsLoading(true);
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
      } finally {
        setIsLoading(false);
      }
    };

    fetchMissions();
  }, [page]);

  const handlePageChange = (_: unknown, value: number) => {
    setPage(value);
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      {isLoading ? (
        <Box
          sx={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "100vh",
          }}
        >
          <CircularProgress />
        </Box>
      ) : (
        <>
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
        </>
      )}
    </Container>
  );
}
