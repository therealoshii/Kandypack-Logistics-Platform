
import { useState } from 'react';
import { LogOut, Package, UserRound } from 'lucide-react';
import BrandMark from '../../shared/BrandMark';
import { Link, NavLink, Navigate, Outlet, useNavigate } from 'react-router-dom';
import { useCustomerAuth } from '../../shared/customerAuth';

export default function CustomerPortalLayout() {
  const { customer, loading, logout } = useCustomerAuth();
  const navigate = useNavigate();
  const [signingOut, setSigningOut] = useState(false);
  const [logoutError, setLogoutError] = useState('');

  if (loading) {
    return <div className="auth-loading"><span className="spinner" />Checking customer session</div>;
  }

  if (!customer) {
    return <Navigate to="/portal/login" replace />;
  }

  async function signOut() {
    setSigningOut(true);
    setLogoutError('');

    try {
      await logout();
      navigate('/portal/login', { replace: true });
    } catch {
      setLogoutError('Sign out failed. Please try again.');
    } finally {
      setSigningOut(false);
    }
  }

  return (
    <div className="customer-portal">
      <header className="customer-portal-header">
        <Link to="/portal" className="customer-portal-brand">
          <span className="auth-mark"><BrandMark size={28} /></span>
          <span><strong>KANDYPACK</strong><small>CUSTOMER PORTAL</small></span>
        </Link>

        <nav className="customer-portal-nav" aria-label="Customer navigation">
          <NavLink to="/portal" end><Package size={16} /> My orders</NavLink>
          <NavLink to="/portal/orders/new">New order</NavLink>
          <NavLink to="/portal/profile"><UserRound size={16} /> Profile</NavLink>
        </nav>

        <div className="customer-portal-account">
          <span>{customer.fullName}</span>
          <button type="button" className="button" disabled={signingOut} onClick={() => void signOut()}>
            <LogOut size={16} /> {signingOut ? 'Signing out…' : 'Sign out'}
          </button>
        </div>
      </header>

      {logoutError && <p className="login-error" role="alert">{logoutError}</p>}

      <main className="customer-portal-content">
        <Outlet />
      </main>
    </div>
  );
}
