import { Mission } from "./api";

export interface MissionWithId extends Mission {
  id: string;
}
