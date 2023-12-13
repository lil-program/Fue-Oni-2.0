import { Configuration, MissionsApiFactory } from "./api";

export const BASE_PATH =
  import.meta.env.VITE_SERVER_URL || "http://localhost:8003";

const missionsApi = MissionsApiFactory(
  new Configuration({ basePath: BASE_PATH })
);

const apiClient = {
  ...missionsApi,
};

export default apiClient;
