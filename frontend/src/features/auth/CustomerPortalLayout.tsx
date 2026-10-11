
import { LogOut, Package, UserRound } from 'lucide-react';
import { Navigate, useNavigate } from 'react-router-dom';
import { useCustomerAuth } from '../../shared/customerAuth';

export default function CustomerPortalLayout() {
  const { customer, loading, logout } = useCustomerAuth();
  const navigate = useNavigate();

  if (loading) {
    return (
      <div className="auth-loading">
        <span className="spinner" />
        Checking customer session
      </div>
    );
  }

  if (!customer) {
    return <Navigate to="/portal/login" replace />;
  }

  async function signOut() {
    try {
      await logout();
    } finally {
      navigate('/portal/login', { replace: true });
    }
  }

  return (
    <main className="auth-page">
      <div className="auth-side">
        <div className="auth-brand">
          <span className="auth-mark"><Package size={23} /></span>
          <span>KANDYPACK <small>LOGISTICS / LK</small></span>
        </div>

        <div className="auth-copy">
          <p className="eyebrow">CUSTOMER PORTAL</p>
          <h1>Welcome,<br />{customer.fullName}.</h1>
          <p>Your Kandypack customer account is ready.</p>
        </div>

        <div className="auth-side-foot">
          <span>CUSTOMER WORKSPACE</span>
          <span>COLOMBO · SRI LANKA</span>
        </div>
      </div>

      <section className="auth-main">
        <div className="login-panel">
          <div className="login-icon"><UserRound size={19} /></div>
          <p className="eyebrow">YOUR ACCOUNT</p>
          <h2>Customer profile</h2>
          <p className="login-description">
            You are signed in to your Kandypack customer account.
          </p>

          <div className="field-label">
            Customer ID
            <p>{customer.customerID}</p>
          </div>

          <div className="field-label">
            Full name
            <p>{customer.fullName}</p>
          </div>

          <div className="field-label">
            Username
            <p>{customer.username}</p>
          </div>

          <div className="field-label">
            Email
            <p>{customer.email}</p>
          </div>

          <button
            type="button"
            className="button button-primary login-submit"
            onClick={() => void signOut()}
          >
            Sign out <LogOut size={16} />
          </button>
        </div>
      </section>
    </main>
  );
}
