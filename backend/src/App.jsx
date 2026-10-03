import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import AppLayout from './components/AppLayout';
import AnalyticsDashboardPage from './pages/AnalyticsDashboardPage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<AppLayout />}>
          <Route index element={<AnalyticsDashboardPage />} />
          {/* Placeholder routes for your teammates' modules */}
          <Route path="orders" element={<div>Order Placement View (Haneef)</div>} />
          <Route path="rail" element={<div>Rail Cargo View (Widushi)</div>} />
          <Route path="fleet" element={<div>Fleet Overview View (Shameera)</div>} />
          <Route path="roster" element={<div>Roster & Dispatch View (Oshan)</div>} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;