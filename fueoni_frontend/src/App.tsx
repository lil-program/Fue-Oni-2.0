import { useState } from "react";
import { Route, Routes } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import Layout from "./components/Layout/Layout";

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
        <Route path="/missions" element={<Dashboard />} />
        <Route path="/games" element={<Dashboard />} />
        <Route path="/users" element={<Dashboard />} />
        <Route path="/reports" element={<Dashboard />} />
        <Route path="*" element={<Dashboard />} />
      </Routes>
    </Layout>
  );
}

export default App;
