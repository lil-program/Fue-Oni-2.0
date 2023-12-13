import { useState } from "react";
import { Route, Routes } from "react-router-dom";
import Layout from "./components/Layout/Layout";
import Dashboard from "./pages/Dashboard";

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
