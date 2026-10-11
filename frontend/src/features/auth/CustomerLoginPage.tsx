
import { useState } from 'react';
import { ArrowRight, Boxes, CircleAlert, LockKeyhole } from 'lucide-react';
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { ApiError } from '../../api';
import { useCustomerAuth } from '../../shared/customerAuth';

export default function CustomerLoginPage() {
  const { customer, loading, login } = useCustomerAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const successMessage =
    typeof location.state?.message === 'string' ? location.state.message : '';

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && customer) return <Navigate to="/portal" replace />;

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSubmitting(true);

    try {
      await login(username.trim(), password);
      navigate('/portal', { replace: true });
    } catch (failure) {
      setError(
        failure instanceof ApiError && failure.status === 401
          ? 'Incorrect username or password.'
          : failure instanceof Error
            ? failure.message
            : 'Sign-in failed. Please try again.',
      );
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-page">
      <div className="auth-side">
        <div className="auth-brand">
          <span className="auth-mark"><Boxes size={23} /></span>
          <span>KANDYPACK <small>LOGISTICS / LK</small></span>
        </div>
        <div className="auth-copy">
          <p className="eyebrow">CUSTOMER PORTAL</p>
          <h1>Your orders,<br />all in one place.</h1>
          <p>Sign in to access your Kandypack customer account.</p>
        </div>
        <div className="auth-side-foot">
          <span>CUSTOMER ACCESS</span><span>COLOMBO · SRI LANKA</span>
        </div>
      </div>

      <section className="auth-main">
        <form className="login-panel" onSubmit={submit}>
          <div className="login-icon"><LockKeyhole size={19} /></div>
          <p className="eyebrow">CUSTOMER ACCESS</p>
          <h2>Welcome back</h2>
          <p className="login-description">Sign in with your registered username and password.</p>

          {successMessage && <p className="login-success" role="status">{successMessage}</p>}
          {error && <div className="login-error"><CircleAlert size={16} />{error}</div>}

          <label className="field-label">
            Username
            <input autoComplete="username" autoFocus required value={username}
              onChange={(event) => setUsername(event.target.value)} placeholder="Your username" />
          </label>

          <label className="field-label">
            Password
            <input autoComplete="current-password" type="password" required value={password}
              onChange={(event) => setPassword(event.target.value)} placeholder="Your password" />
          </label>

          <button className="button button-primary login-submit" disabled={submitting || loading}>
            {submitting ? 'Signing in…' : 'Sign in'} <ArrowRight size={16} />
          </button>

          <p className="login-help">New to Kandypack? <Link to="/portal/register">Create an account</Link></p>
          <p className="login-help">Staff member? <Link to="/login">Staff sign in</Link></p>
        </form>
      </section>
    </main>
  );
}
