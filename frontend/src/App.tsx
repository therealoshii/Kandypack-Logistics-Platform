import { useState } from 'react';
import { BrowserRouter, Link, Navigate, NavLink, Outlet, Route, Routes, useLocation } from 'react-router-dom';
import {
  Activity, ArrowRight, BarChart3, Boxes, CalendarDays, ChevronDown, ClipboardList,
  LayoutDashboard, Menu, PackageCheck, Search, Settings2, TrainFront, Warehouse, X,
} from 'lucide-react';
import AnalyticsDashboardPage from './features/analytics/AnalyticsDashboardPage';
import ReportsPage from './features/analytics/ReportsPage';
import CatalogPage from './features/orders/CatalogPage';
import OrderPlacementPage from './features/orders/OrderPlacementPage';
import TrainCargoPage from './features/rail/TrainCargoPage';
import RosterDispatchPage from './features/roster/RosterDispatchPage';
import FleetOverviewPage from './features/fleet/FleetOverviewPage'; 

const navGroups = [
  { label: 'Workspace', items: [{ to: '/', label: 'Analytics dashboard', icon: LayoutDashboard, end: true }] },
  { label: 'Customer & orders', items: [
    { to: '/orders/new', label: 'Order placement', icon: ClipboardList },
    { to: '/orders/catalog', label: 'Customers & products', icon: Boxes },
  ] },
  { label: 'Logistics', items: [
    { to: '/cargo/dispatch', label: 'Rail cargo dispatch', icon: TrainFront },
    { to: '/fleet/overview', label: 'Store & fleet hub', icon: Warehouse },
    { to: '/roster/dispatch', label: 'Roster & dispatch', icon: PackageCheck },
  ] },
  { label: 'Insights', items: [{ to: '/analytics/reports', label: 'Reports', icon: BarChart3 }] },
];

const routeTitles: Record<string, string> = {
  '/': 'Analytics dashboard',
  '/orders/new': 'Order placement',
  '/orders/catalog': 'Customers & products',
  '/cargo/dispatch': 'Rail cargo dispatch',
  '/fleet/overview': 'Store & fleet hub',
  '/roster/dispatch': 'Roster & dispatch',
  '/analytics/reports': 'Reports',
};

/*function PlaceholderPage({ title }: { title: string }) {
  return (
    <div style={{ padding: '2rem', textAlign: 'center', opacity: 0.7 }}>
      <h2>{title}</h2>
      <p>This module is currently under development.</p>
    </div>
  );
}*/

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AppLayout />}>
          <Route index element={<AnalyticsDashboardPage />} />
          <Route path="orders/new" element={<OrderPlacementPage />} />
          <Route path="orders/catalog" element={<CatalogPage />} />
          <Route path="cargo/dispatch" element={<TrainCargoPage />} />
          <Route path="fleet/overview" element={<FleetOverviewPage />} />
          <Route path="roster/dispatch" element={<RosterDispatchPage />} />
          <Route path="analytics/reports" element={<ReportsPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

function AppLayout() {
  const [menuOpen, setMenuOpen] = useState(false);
  const location = useLocation();
  const title = routeTitles[location.pathname] ?? 'Analytics dashboard';

  return (
    <div className="app-shell">
      <aside className={`sidebar ${menuOpen ? 'sidebar-open' : ''}`}>
        <div className="brand-lockup">
          <div className="brand-mark">
            <Boxes size={21} strokeWidth={2.2} />
          </div>
          <div>
            <strong>KANDYPACK</strong>
            <span>LOGISTICS / LK</span>
          </div>
          <button className="icon-button sidebar-close" aria-label="Close navigation" onClick={() => setMenuOpen(false)}>
            <X size={18} />
          </button>
        </div>
        <div className="workspace-switch">
          <div className="workspace-avatar">K</div>
          <div>
            <span>Operations team</span>
            <strong>Kandy distribution</strong>
          </div>
          <ChevronDown size={15} />
        </div>
        <nav className="side-nav" aria-label="Main navigation">
          {navGroups.map((group) => (
            <div className="nav-group" key={group.label}>
              <p className="nav-label">{group.label}</p>
              {group.items.map((item) => {
                const Icon = item.icon;
                return (
                  <NavLink
                    key={item.to}
                    end={'end' in item ? item.end : false}
                    to={item.to}
                    className={({ isActive }) => `nav-item ${isActive ? 'nav-item-active' : ''}`}
                    onClick={() => setMenuOpen(false)}
                  >
                    <Icon size={17} strokeWidth={1.8} />
                    <span>{item.label}</span>
                  </NavLink>
                );
              })}
            </div>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <div className="service-card">
            <div className="service-dot" />
            <div>
              <strong>API connection</strong>
              <span>Spring Boot · localhost:8080</span>
            </div>
            <Activity size={15} />
          </div>
          <div className="profile-row">
            <div className="profile-avatar">OP</div>
            <div>
              <strong>Operations</strong>
              <span>Workspace account</span>
            </div>
            <Settings2 size={17} />
          </div>
        </div>
      </aside>
      {menuOpen && <button className="sidebar-scrim" aria-label="Close navigation" onClick={() => setMenuOpen(false)} />}
      <main className="main-area">
        <header className="topbar">
          <button className="icon-button mobile-menu" aria-label="Open navigation" onClick={() => setMenuOpen(true)}>
            <Menu size={20} />
          </button>
          <div className="breadcrumb">
            <span>Kandypack</span>
            <span className="crumb-slash">/</span>
            <strong>{title}</strong>
          </div>
          <div className="topbar-actions">
            <label className="global-search">
              <Search size={16} />
              <input aria-label="Search" placeholder="Search this workspace" />
              <kbd>⌘ K</kbd>
            </label>
            <Link className="icon-button refresh-button" title="Go to dashboard" aria-label="Go to dashboard" to="/">
              <ArrowRight size={17} />
            </Link>
            <div className="topbar-date">
              <CalendarDays size={15} />
              <span>{new Intl.DateTimeFormat('en', { weekday: 'short', day: '2-digit', month: 'short' }).format(new Date())}</span>
            </div>
          </div>
        </header>
        <div className="page-wrap">
          <Outlet />
        </div>
        <footer className="footer">
          <span>Kandypack Logistics Platform</span>
          <span>React feature routes <i /></span>
        </footer>
      </main>
    </div>
  );
}