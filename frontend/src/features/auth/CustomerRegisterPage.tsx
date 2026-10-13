
import { useEffect, useState } from 'react';
import { ArrowRight, CircleAlert, UserRoundPlus } from 'lucide-react';
import BrandMark from '../../shared/BrandMark';
import { Link, useNavigate } from 'react-router-dom';
import { api, ApiError, get } from '../../api';

interface DeliveryArea {
  areaID: number;
  areaName: string;
  routeID: number;
}

interface RegistrationRequest {
  fullName: string;
  email: string;
  contactNumber: string;
  address: string;
  areaId: number;
  username: string;
  password: string;
}

export default function CustomerRegisterPage() {
  const navigate = useNavigate();
  const [areas, setAreas] = useState<DeliveryArea[]>([]);
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [contactNumber, setContactNumber] = useState('');
  const [address, setAddress] = useState('');
  const [areaId, setAreaId] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [loadingAreas, setLoadingAreas] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    get<DeliveryArea[]>('/api/public/delivery-areas')
      .then((data) => {
        setAreas(data);
        if (data.length) setAreaId(String(data[0].areaID));
      })
      .catch((failure: unknown) => {
        setError(failure instanceof Error ? failure.message : 'Could not load delivery areas.');
      })
      .finally(() => setLoadingAreas(false));
  }, []);

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');

    if (password.length < 12) {
      setError('Password must be at least 12 characters.');
      return;
    }

    if (password !== confirmPassword) {
      setError('The passwords do not match.');
      return;
    }

    if (!areaId || areas.length === 0) {
      setError('Please select a delivery area.');
      return;
    }

    setSubmitting(true);

    const payload: RegistrationRequest = {
      fullName: fullName.trim(),
      email: email.trim(),
      contactNumber: contactNumber.trim(),
      address: address.trim(),
      areaId: Number(areaId),
      username: username.trim(),
      password,
    };

    try {
      await api('/api/customers', {
        method: 'POST',
        body: JSON.stringify(payload),
      });

      navigate('/portal/login', {
        replace: true,
        state: { message: 'Account created. Please sign in.' },
      });
    } catch (failure) {
      if (failure instanceof ApiError && failure.status === 409) {
        setError(failure.message);
      } else {
        setError(failure instanceof Error ? failure.message : 'Registration failed. Please try again.');
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-page">
      <div className="auth-side">
        <div className="auth-brand">
          <span className="auth-mark"><BrandMark size={26} /></span>
          <span>KANDYPACK <small>LOGISTICS / LK</small></span>
        </div>
        <div className="auth-copy">
          <p className="eyebrow">CREATE AN ACCOUNT</p>
          <h1>Start with<br />Kandypack.</h1>
          <p>Create your customer account to get started.</p>
        </div>
        <div className="auth-side-foot">
          <span>CUSTOMER REGISTRATION</span><span>COLOMBO · SRI LANKA</span>
        </div>
      </div>

      <section className="auth-main">
        <form className="login-panel" onSubmit={submit}>
          <div className="login-icon"><UserRoundPlus size={19} /></div>
          <p className="eyebrow">CUSTOMER REGISTRATION</p>
          <h2>Create account</h2>
          <p className="login-description">Enter your details to register with Kandypack.</p>

          {error && <div className="login-error"><CircleAlert size={16} />{error}</div>}

          <label className="field-label">Full name
            <input required maxLength={100} autoComplete="name" value={fullName}
              onChange={(event) => setFullName(event.target.value)} />
          </label>

          <label className="field-label">Email
            <input required type="email" maxLength={100} autoComplete="email" value={email}
              onChange={(event) => setEmail(event.target.value)} />
          </label>

          <label className="field-label">Contact number
            <input required maxLength={15} autoComplete="tel" value={contactNumber}
              onChange={(event) => setContactNumber(event.target.value)} />
          </label>

          <label className="field-label">Address
            <input required maxLength={255} autoComplete="street-address" value={address}
              onChange={(event) => setAddress(event.target.value)} />
          </label>

          <label className="field-label">Delivery area
            <select required value={areaId} disabled={loadingAreas || areas.length === 0}
              onChange={(event) => setAreaId(event.target.value)}>
              {loadingAreas && <option value="">Loading areas…</option>}
              {!loadingAreas && areas.length === 0 && <option value="">No delivery areas available</option>}
              {areas.map((area) => (
                <option key={area.areaID} value={area.areaID}>{area.areaName}</option>
              ))}
            </select>
          </label>

          <label className="field-label">Username
            <input required minLength={3} maxLength={50} autoComplete="username" value={username}
              onChange={(event) => setUsername(event.target.value)} />
          </label>

          <label className="field-label">Password
            <input required minLength={12} autoComplete="new-password" type="password"
              value={password} onChange={(event) => setPassword(event.target.value)} />
            <small>Use at least 12 characters.</small>
          </label>

          <label className="field-label">Confirm password
            <input required minLength={12} autoComplete="new-password" type="password"
              value={confirmPassword} onChange={(event) => setConfirmPassword(event.target.value)} />
            <small>Must match your password and contain at least 12 characters.</small>
          </label>

          <button className="button button-primary login-submit"
            disabled={submitting || loadingAreas || areas.length === 0}>
            {submitting ? 'Creating account…' : 'Create account'} <ArrowRight size={16} />
          </button>

          <p className="login-help">Already registered? <Link to="/portal/login">Sign in</Link></p>
        </form>
      </section>
    </main>
  );
}
