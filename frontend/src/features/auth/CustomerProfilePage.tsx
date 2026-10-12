import { useEffect, useState } from 'react';
import { KeyRound, Lock, Save, UserRound } from 'lucide-react';
import { ApiError, get, post, put } from '../../api';
import { LoadingState, NoticeBanner } from '../../shared/ui';

interface CustomerProfileData {
  customerID: number;
  fullName: string;
  email: string;
  contactNumber: string;
  address: string;
  areaId: number;
  areaName?: string;
  city?: string;
  username: string;
}

interface DeliveryArea {
  areaID: number;
  areaName: string;
  routeID: number;
}

export default function CustomerProfilePage() {
  const [profile, setProfile] = useState<CustomerProfileData | null>(null);
  const [areas, setAreas] = useState<DeliveryArea[]>([]);
  const [loading, setLoading] = useState(true);

  // Edit details form state
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [contactNumber, setContactNumber] = useState('');
  const [address, setAddress] = useState('');
  const [areaId, setAreaId] = useState<number | string>('');
  const [savingProfile, setSavingProfile] = useState(false);

  // Password change form state
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [changingPassword, setChangingPassword] = useState(false);

  // Notices
  const [profileNotice, setProfileNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const [passwordNotice, setPasswordNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    Promise.all([
      get<CustomerProfileData>('/api/portal/me'),
      get<DeliveryArea[]>('/api/public/delivery-areas'),
    ])
      .then(([profileData, areasData]) => {
        setProfile(profileData);
        setAreas(areasData);
        setFullName(profileData.fullName || '');
        setEmail(profileData.email || '');
        setContactNumber(profileData.contactNumber || '');
        setAddress(profileData.address || '');
        setAreaId(profileData.areaId || (areasData.length ? areasData[0].areaID : ''));
      })
      .catch((error: unknown) => {
        setProfileNotice({
          kind: 'error',
          text: error instanceof Error ? error.message : 'Could not load customer profile.',
        });
      })
      .finally(() => setLoading(false));
  }, []);

  async function handleProfileSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSavingProfile(true);
    setProfileNotice(null);

    const payload = {
      fullName,
      email,
      contactNumber,
      address,
      areaId: Number(areaId),
    };

    try {
      const updated = await put<CustomerProfileData>('/api/portal/me', payload);
      setProfile(updated);
      setProfileNotice({ kind: 'success', text: 'Profile updated successfully.' });
    } catch (error) {
      if (error instanceof ApiError && error.status === 409) {
        setProfileNotice({ kind: 'error', text: 'An account already uses that email.' });
      } else {
        setProfileNotice({
          kind: 'error',
          text: error instanceof Error ? error.message : 'Could not update profile.',
        });
      }
    } finally {
      setSavingProfile(false);
    }
  }

  async function handlePasswordSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPasswordNotice(null);

    if (newPassword.length < 12 || newPassword.length > 72) {
      setPasswordNotice({ kind: 'error', text: 'New password must be between 12 and 72 characters.' });
      return;
    }

    if (newPassword !== confirmPassword) {
      setPasswordNotice({ kind: 'error', text: 'New passwords do not match.' });
      return;
    }

    setChangingPassword(true);

    try {
      const response = await post<{ message?: string }>('/api/portal/me/password', {
        currentPassword,
        newPassword,
      });
      setPasswordNotice({
        kind: 'success',
        text: response?.message || 'Password changed successfully! Use your new password at next login.',
      });
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (error) {
      setPasswordNotice({
        kind: 'error',
        text: error instanceof Error ? error.message : 'Could not change password.',
      });
    } finally {
      setChangingPassword(false);
    }
  }

  if (loading) {
    return (
      <section>
        <LoadingState label="Loading profile information…" />
      </section>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
      {/* Profile Details Section */}
      <section className="login-panel" style={{ width: 'min(100%, 720px)' }}>
        <div className="login-icon">
          <UserRound size={19} />
        </div>
        <p className="eyebrow">YOUR ACCOUNT</p>
        <h1>Profile</h1>
        <p className="login-description">View and edit your personal information and delivery address.</p>

        <NoticeBanner notice={profileNotice} onDismiss={() => setProfileNotice(null)} />

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', margin: '20px 0 10px' }}>
          <div className="field-label" style={{ marginTop: 0 }}>
            Customer ID
            <p style={{ background: '#f0f3f0' }}>#{profile?.customerID}</p>
          </div>
          <div className="field-label" style={{ marginTop: 0 }}>
            Username (Permanent)
            <p style={{ background: '#f0f3f0' }}>{profile?.username}</p>
          </div>
        </div>

        <form onSubmit={handleProfileSubmit} style={{ marginTop: '16px' }}>
          <label className="field-label">
            Full name <span>Required</span>
            <input
              type="text"
              required
              maxLength={100}
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              placeholder="Full name"
            />
          </label>

          <label className="field-label">
            Email address <span>Required</span>
            <input
              type="email"
              required
              maxLength={100}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="name@example.com"
            />
          </label>

          <label className="field-label">
            Contact phone number
            <input
              type="tel"
              maxLength={15}
              value={contactNumber}
              onChange={(e) => setContactNumber(e.target.value)}
              placeholder="+94 77 123 4567"
            />
          </label>

          <label className="field-label">
            Delivery address
            <textarea
              rows={3}
              maxLength={200}
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              placeholder="Street address, city"
            />
          </label>

          <label className="field-label">
            Delivery Area <span>Required for route assignment</span>
            <select
              required
              value={areaId}
              onChange={(e) => setAreaId(e.target.value)}
            >
              <option value="">Select your delivery area</option>
              {areas.map((area) => (
                <option key={area.areaID} value={area.areaID}>
                  {area.areaName}
                </option>
              ))}
            </select>
          </label>

          <button
            className="button button-primary"
            type="submit"
            disabled={savingProfile}
            style={{ width: '100%', marginTop: '24px' }}
          >
            <Save size={16} />
            {savingProfile ? 'Saving changes…' : 'Save profile changes'}
          </button>
        </form>
      </section>

      {/* Change Password Section */}
      <section className="login-panel" style={{ width: 'min(100%, 720px)' }}>
        <div className="login-icon">
          <KeyRound size={19} />
        </div>
        <p className="eyebrow">SECURITY</p>
        <h2>Change password</h2>
        <p className="login-description">Enforce 12–72 characters. The changed password will take effect immediately.</p>

        <NoticeBanner notice={passwordNotice} onDismiss={() => setPasswordNotice(null)} />

        <form onSubmit={handlePasswordSubmit} style={{ marginTop: '16px' }}>
          <label className="field-label">
            Current password <span>Required</span>
            <input
              type="password"
              required
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              placeholder="Enter current password"
            />
          </label>

          <label className="field-label">
            New password <span>12–72 characters</span>
            <input
              type="password"
              required
              minLength={12}
              maxLength={72}
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="At least 12 characters"
            />
          </label>

          <label className="field-label">
            Confirm new password <span>Must match</span>
            <input
              type="password"
              required
              minLength={12}
              maxLength={72}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Re-enter new password"
            />
          </label>

          <button
            className="button button-primary"
            type="submit"
            disabled={changingPassword}
            style={{ width: '100%', marginTop: '24px' }}
          >
            <Lock size={16} />
            {changingPassword ? 'Updating password…' : 'Update password'}
          </button>
        </form>
      </section>
    </div>
  );
}
