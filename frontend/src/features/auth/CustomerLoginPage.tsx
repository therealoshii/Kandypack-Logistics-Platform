
import { useState } from 'react';
import { CircleAlert } from 'lucide-react';
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { ApiError } from '../../api';
import { useCustomerAuth } from '../../shared/customerAuth';
import SignInLayout, { SignInFields } from './SignInLayout';

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
    <SignInLayout audience="customer">
      <form className="signin-form" onSubmit={submit}>
        <h2>Welcome back</h2>
        <p className="signin-lead">Sign in with your registered username and password.</p>

        {successMessage && <p className="login-success" role="status">{successMessage}</p>}
        {error && <div className="login-error"><CircleAlert size={16} />{error}</div>}

        <SignInFields username={username} password={password} onUsername={setUsername} onPassword={setPassword}
          submitting={submitting} disabled={submitting || loading} />

        <p className="signin-note">New to Kandypack? <Link to="/portal/register">Create an account</Link></p>
      </form>
    </SignInLayout>
  );
}
