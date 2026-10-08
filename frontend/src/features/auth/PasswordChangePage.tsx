import { useState } from 'react';
import { KeyRound } from 'lucide-react';
import { post } from '../../api';
import { NoticeBanner, PageHeading } from '../../shared/ui';

export default function PasswordChangePage() {
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const [saving, setSaving] = useState(false);
  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setSaving(true); setNotice(null);
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const currentPassword = String(form.get('currentPassword'));
    const newPassword = String(form.get('newPassword'));
    if (newPassword !== String(form.get('confirmPassword'))) {
      setNotice({ kind: 'error', text: 'New password and confirmation do not match.' }); setSaving(false); return;
    }
    try {
      await post<void>('/api/auth/password', { currentPassword, newPassword });
      formElement.reset();
      setNotice({ kind: 'success', text: 'Password changed.' });
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Password could not be changed.' });
    } finally { setSaving(false); }
  }
  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="ACCOUNT / SECURITY" title="Change password" description="Choose a unique password with at least 12 characters." />
    <form className="panel form-panel password-form" onSubmit={submit}><div className="form-icon"><KeyRound size={18} /></div><label className="field-label">Current password<input name="currentPassword" type="password" autoComplete="current-password" required /></label><label className="field-label">New password<input name="newPassword" type="password" minLength={12} maxLength={72} autoComplete="new-password" required /></label><label className="field-label">Confirm new password<input name="confirmPassword" type="password" minLength={12} maxLength={72} autoComplete="new-password" required /></label><button className="button button-primary" disabled={saving}>{saving ? 'Updating…' : 'Update password'}</button></form>
  </>;
}
