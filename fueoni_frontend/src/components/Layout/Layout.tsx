import { ReactNode } from "react";
import CustomAppBar from "./components/CustomAppBar";
import CustomDrawer from "./components/CustomDrawer";
import Box from "@mui/material/Box";
import Toolbar from "@mui/material/Toolbar";

interface LayoutProps {
  open: boolean;
  handleDrawerOpen: () => void;
  handleDrawerClose: () => void;
  children: ReactNode;
}

const Layout: React.FC<LayoutProps> = ({
  open,
  handleDrawerOpen,
  handleDrawerClose,
  children,
}) => {
  return (
    <div>
      <Box sx={{ display: "flex" }}>
        <CustomAppBar open={open} handleDrawerOpen={handleDrawerOpen} />
        <CustomDrawer open={open} handleDrawerClose={handleDrawerClose} />
        <Box
          component="main"
          sx={{
            backgroundColor: (theme) =>
              theme.palette.mode === "light"
                ? theme.palette.grey[100]
                : theme.palette.grey[900],
            flexGrow: 1,
            height: "100vh",
            overflow: "auto",
          }}
        >
          <Toolbar />
          {children}
        </Box>
      </Box>
    </div>
  );
};

export default Layout;
