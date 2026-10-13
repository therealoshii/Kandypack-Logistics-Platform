
import { useState } from 'react';
import { CircleAlert } from 'lucide-react';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../shared/auth';
import SignInLayout, { SignInFields } from './SignInLayout';

export default function LoginPage() {
  const { user, loading, login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  if (!loading && user) {
    return <Navigate to={typeof location.state?.from === 'string' ? location.state.from : '/'} replace />;
  }

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSubmitting(true);

    try {
      await login(username.trim(), password);
      const from = location.state?.from;
      navigate(typeof from === 'string' ? from : '/', { replace: true });
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : 'Sign-in failed. Check your credentials.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <SignInLayout audience="staff">
      <form className="signin-form" onSubmit={submit}>
        <h2>Sign in</h2>
        <p className="signin-lead">Use your staff account to open your workspace.</p>

        {error && <div className="login-error"><CircleAlert size={16} />{error}</div>}

        <SignInFields username={username} password={password} onUsername={setUsername} onPassword={setPassword}
          submitting={submitting} disabled={submitting || loading} />

        <p className="signin-note">Staff accounts are provisioned by a Kandypack administrator.</p>
      </form>
    </SignInLayout>
  );
}
