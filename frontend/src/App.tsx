import { useState } from 'react';
import { BrowserRouter, Link, Navigate, NavLink, Outlet, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import {
  Activity, ArrowRight, BarChart3, Boxes, CalendarDays, ChevronDown, ClipboardList,
  KeyRound, LayoutDashboard, LogOut, Menu, PackageCheck, Search, ShieldCheck,
  TrainFront, Warehouse, X,
} from 'lucide-react';
import AnalyticsDashboardPage from './features/analytics/AnalyticsDashboardPage';
import ReportsPage from './features/analytics/ReportsPage';
import FleetOverviewPage from './features/fleet/FleetOverviewPage';
import LoginPage from './features/auth/LoginPage';
import StaffUsersPage from './features/auth/StaffUsersPage';
import PasswordChangePage from './features/auth/PasswordChangePage';
import CatalogPage from './features/orders/CatalogPage';
import OrderPlacementPage from './features/orders/OrderPlacementPage';
import TrainCargoPage from './features/rail/TrainCargoPage';
import RosterDispatchPage from './features/roster/RosterDispatchPage';
import { AuthProvider, useAuth } from './shared/auth';

const navGroups = [
  { label: 'Workspace', items: [{ to: '/', label: 'Analytics dashboard', icon: LayoutDashboard, roles: ['ADMIN', 'ANALYST'], end: true }] },
  { label: 'Customer & orders', items: [
    { to: '/orders/new', label: 'Order placement', icon: ClipboardList, roles: ['ADMIN', 'ORDER_MANAGER'] },
    { to: '/orders/catalog', label: 'Customers & products', icon: Boxes, roles: ['ADMIN', 'ORDER_MANAGER'] },
  ] },
  { label: 'Logistics', items: [
    { to: '/cargo/dispatch', label: 'Rail cargo dispatch', icon: TrainFront, roles: ['ADMIN', 'RAIL_DISPATCHER'] },
    { to: '/fleet/overview', label: 'Store & fleet hub', icon: Warehouse, roles: ['ADMIN', 'FLEET_MANAGER'] },
    { to: '/roster/dispatch', label: 'Roster & dispatch', icon: PackageCheck, roles: ['ADMIN', 'ROSTER_DISPATCHER'] },
  ] },
  { label: 'Insights', items: [{ to: '/analytics/reports', label: 'Reports', icon: BarChart3, roles: ['ADMIN', 'ANALYST'] }] },
  { label: 'Administration', items: [{ to: '/admin/staff', label: 'Staff & roles', icon: ShieldCheck, roles: ['ADMIN'] }] },
];

const routeTitles: Record<string, string> = {
  '/': 'Analytics dashboard', '/orders/new': 'Order placement', '/orders/catalog': 'Customers & products',
  '/cargo/dispatch': 'Rail cargo dispatch', '/fleet/overview': 'Store & fleet hub',
  '/roster/dispatch': 'Roster & dispatch', '/analytics/reports': 'Reports', '/admin/staff': 'Staff & roles',
  '/account/password': 'Change password',
};

export default function App() {
  return <AuthProvider><BrowserRouter><Routes>
    <Route path="/login" element={<LoginPage />} />
    <Route element={<RequireAuth><AppLayout /></RequireAuth>}>
      <Route index element={<HomeRedirect />} />
      <Route path="orders/new" element={<RoleRoute roles={['ADMIN', 'ORDER_MANAGER']}><OrderPlacementPage /></RoleRoute>} />
      <Route path="orders/catalog" element={<RoleRoute roles={['ADMIN', 'ORDER_MANAGER']}><CatalogPage /></RoleRoute>} />
      <Route path="cargo/dispatch" element={<RoleRoute roles={['ADMIN', 'RAIL_DISPATCHER']}><TrainCargoPage /></RoleRoute>} />
      <Route path="fleet/overview" element={<RoleRoute roles={['ADMIN', 'FLEET_MANAGER']}><FleetOverviewPage /></RoleRoute>} />
      <Route path="roster/dispatch" element={<RoleRoute roles={['ADMIN', 'ROSTER_DISPATCHER']}><RosterDispatchPage /></RoleRoute>} />
      <Route path="analytics/reports" element={<RoleRoute roles={['ADMIN', 'ANALYST']}><ReportsPage /></RoleRoute>} />
      <Route path="admin/staff" element={<RoleRoute roles={['ADMIN']}><StaffUsersPage /></RoleRoute>} />
      <Route path="account/password" element={<PasswordChangePage />} />
      <Route path="forbidden" element={<ForbiddenPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Route>
  </Routes></BrowserRouter></AuthProvider>;
}

function RequireAuth({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const location = useLocation();
  if (loading) return <div className="auth-loading"><span className="spinner" />Checking staff session</div>;
  if (!user) return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  return children;
}

function RoleRoute({ roles, children }: { roles: string[]; children: React.ReactNode }) {
  const { hasRole } = useAuth();
  return hasRole(...roles) ? children : <Navigate to="/forbidden" replace />;
}

function HomeRedirect() {
  const { hasRole } = useAuth();
  if (hasRole('ADMIN', 'ANALYST')) return <AnalyticsDashboardPage />;
  if (hasRole('ORDER_MANAGER')) return <Navigate to="/orders/new" replace />;
  if (hasRole('RAIL_DISPATCHER')) return <Navigate to="/cargo/dispatch" replace />;
  if (hasRole('FLEET_MANAGER')) return <Navigate to="/fleet/overview" replace />;
  if (hasRole('ROSTER_DISPATCHER')) return <Navigate to="/roster/dispatch" replace />;
  return <Navigate to="/forbidden" replace />;
}

function ForbiddenPage() {
  return <div className="forbidden-page"><ShieldCheck size={28} /><p className="eyebrow">ACCESS CONTROL</p><h1>This section isn’t assigned to your role.</h1><p>Ask a Kandypack administrator if you need access.</p></div>;
}

function AppLayout() {
  const [menuOpen, setMenuOpen] = useState(false);
  const { user, hasRole, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const title = routeTitles[location.pathname] ?? 'Operations';

  async function signOut() {
    await logout();
    navigate('/login', { replace: true });
  }

  return <div className="app-shell">
    <aside className={`sidebar ${menuOpen ? 'sidebar-open' : ''}`}>
      <div className="brand-lockup"><div className="brand-mark"><Boxes size={21} strokeWidth={2.2} /></div><div><strong>KANDYPACK</strong><span>LOGISTICS / LK</span></div><button className="icon-button sidebar-close" aria-label="Close navigation" onClick={() => setMenuOpen(false)}><X size={18} /></button></div>
      <div className="workspace-switch"><div className="workspace-avatar">K</div><div><span>Staff workspace</span><strong>{user?.name}</strong></div><ChevronDown size={15} /></div>
      <nav className="side-nav" aria-label="Main navigation">{navGroups.map((group) => {
        const visibleItems = group.items.filter((item) => hasRole(...item.roles));
        if (!visibleItems.length) return null;
        return <div className="nav-group" key={group.label}><p className="nav-label">{group.label}</p>{visibleItems.map((item) => { const Icon = item.icon; return <NavLink key={item.to} end={item.to === '/'} to={item.to} className={({ isActive }) => `nav-item ${isActive ? 'nav-item-active' : ''}`} onClick={() => setMenuOpen(false)}><Icon size={17} strokeWidth={1.8} /><span>{item.label}</span></NavLink>; })}</div>;
      })}</nav>
      <div className="sidebar-bottom"><div className="service-card"><div className="service-dot" /><div><strong>Signed in</strong><span>{user?.roles.map((role) => role.replaceAll('_', ' ')).join(' · ')}</span></div><Activity size={15} /></div><div className="profile-row"><div className="profile-avatar">{user?.name.split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase()}</div><div><strong>{user?.username}</strong><span>Staff account</span></div><Link className="icon-button" to="/account/password" aria-label="Change password" title="Change password"><KeyRound size={15} /></Link><button className="icon-button" aria-label="Sign out" title="Sign out" onClick={() => void signOut()}><LogOut size={16} /></button></div></div>
    </aside>
    {menuOpen && <button className="sidebar-scrim" aria-label="Close navigation" onClick={() => setMenuOpen(false)} />}
    <main className="main-area"><header className="topbar"><button className="icon-button mobile-menu" aria-label="Open navigation" onClick={() => setMenuOpen(true)}><Menu size={20} /></button><div className="breadcrumb"><span>Kandypack</span><span className="crumb-slash">/</span><strong>{title}</strong></div><div className="topbar-actions"><label className="global-search"><Search size={16} /><input aria-label="Search" placeholder="Search this workspace" /><kbd>⌘ K</kbd></label><Link className="icon-button refresh-button" title="Go to your workspace" aria-label="Go to your workspace" to="/"><ArrowRight size={17} /></Link><div className="topbar-date"><CalendarDays size={15} /><span>{new Intl.DateTimeFormat('en', { weekday: 'short', day: '2-digit', month: 'short' }).format(new Date())}</span></div></div></header><div className="page-wrap"><Outlet /></div><footer className="footer"><span>Kandypack Logistics Platform</span><span>Authenticated staff workspace <i /></span></footer></main>
  </div>;
}
