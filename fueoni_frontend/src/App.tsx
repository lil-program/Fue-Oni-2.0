import { useState } from "react";
import { Route, Routes } from "react-router-dom";
import Layout from "./components/Layout/Layout";
import Dashboard from "./pages/Dashboard";
import MissionBoard from "./pages/mission/MissionBoard";
import MissionEdit from "./pages/mission/MissionEdit";
import MissionList from "./pages/mission/MissionList";

function App() {
  const [open, setOpen] = useState(false);

  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  return (
    <Layout
      open={open}
      handleDrawerOpen={handleDrawerOpen}
      handleDrawerClose={handleDrawerClose}
    >
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/missions" element={<MissionBoard />}>
          <Route index element={<MissionList />} />
          <Route path="edit/:id" element={<MissionEdit />} />
        </Route>
        <Route path="/games" element={<Dashboard />} />
        <Route path="/users" element={<Dashboard />} />
        <Route path="/reports" element={<Dashboard />} />
        <Route path="*" element={<Dashboard />} />
      </Routes>
    </Layout>
  );
}

export default App;
