import { useState } from 'react';
import { ArrowRight, Boxes, CircleAlert, LockKeyhole } from 'lucide-react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../shared/auth';

export default function LoginPage() {
  const { user, loading, login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && user) return <Navigate to={typeof location.state?.from === 'string' ? location.state.from : '/'} replace />;

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setError(''); setSubmitting(true);
    try {
      await login(username.trim(), password);
      const from = location.state?.from;
      navigate(typeof from === 'string' ? from : '/', { replace: true });
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : 'Sign-in failed. Check your credentials.');
    } finally { setSubmitting(false); }
  }

  return <main className="auth-page"><div className="auth-side"><div className="auth-brand"><span className="auth-mark"><Boxes size={23} /></span><span>KANDYPACK <small>LOGISTICS / LK</small></span></div><div className="auth-copy"><p className="eyebrow">STAFF OPERATIONS</p><h1>Good logistics<br />starts together.</h1><p>One workspace for order flow, regional dispatch and the people who keep every delivery moving.</p></div><div className="auth-side-foot"><span>INTERNAL OPERATIONS PORTAL</span><span>COLOMBO · SRI LANKA</span></div></div><section className="auth-main"><form className="login-panel" onSubmit={submit}><div className="login-icon"><LockKeyhole size={19} /></div><p className="eyebrow">STAFF ACCESS</p><h2>Sign in to Kandypack</h2><p className="login-description">Use your staff account to open your workspace.</p>{error && <div className="login-error"><CircleAlert size={16} />{error}</div>}<label className="field-label">Username<input autoComplete="username" autoFocus required value={username} onChange={(event) => setUsername(event.target.value)} placeholder="Enter your username" /></label><label className="field-label">Password<input autoComplete="current-password" type="password" required value={password} onChange={(event) => setPassword(event.target.value)} placeholder="Enter your password" /></label><button className="button button-primary login-submit" disabled={submitting || loading}>{submitting ? 'Signing in…' : 'Sign in'}<ArrowRight size={16} /></button><p className="login-help">Staff accounts are provisioned by a Kandypack administrator.</p></form></section></main>;
}
