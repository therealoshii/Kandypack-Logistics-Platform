import { useEffect, useState } from 'react';
import { Plus, ShieldCheck, UserRound, UserRoundX } from 'lucide-react';
import { get, patch, post } from '../../api';
import type { Notice } from '../../shared/ui';
import { EmptyState, Modal, NoticeBanner, PageHeading } from '../../shared/ui';
import { useAuth } from '../../shared/auth';

const roleInfo = [
  ['ORDER_MANAGER', 'Order manager'], ['RAIL_DISPATCHER', 'Rail dispatcher'],
  ['FLEET_MANAGER', 'Fleet manager'], ['ROSTER_DISPATCHER', 'Roster and delivery dispatcher'],
  ['ANALYST', 'Analytics viewer'], ['ADMIN', 'Administrator'],
] as const;

type Staff = { id: number; name: string; username: string; email: string; enabled: boolean; roles: string[] };

export default function StaffUsersPage() {
  const { user } = useAuth();
  const [staff, setStaff] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState<Notice>(null);
  const [adding, setAdding] = useState(false);
  const [editing, setEditing] = useState<Staff | null>(null);
  const [saving, setSaving] = useState(false);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    get<Staff[]>('/api/admin/staff').then(setStaff)
      .catch((error: unknown) => setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Staff directory failed to load.' }))
      .finally(() => setLoading(false));
  }, [reloadKey]);

  async function createStaff(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setSaving(true); setNotice(null);
    const form = new FormData(event.currentTarget);
    const roles = form.getAll('roles').map(String);
    try {
      await post('/api/admin/staff', {
        name: String(form.get('name')), username: String(form.get('username')),
        email: String(form.get('email')), password: String(form.get('password')), roles,
      });
      setAdding(false); setReloadKey((value) => value + 1);
      setNotice({ kind: 'success', text: 'Staff account created.' });
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Account could not be created.' });
    } finally { setSaving(false); }
  }

  async function setEnabled(account: Staff) {
    setNotice(null);
    try {
      const updated = await patch<Staff>(`/api/admin/staff/${account.id}/enabled`, { enabled: !account.enabled });
      setStaff((current) => current.map((item) => item.id === updated.id ? updated : item));
      setNotice({ kind: 'success', text: `${account.name}'s account ${updated.enabled ? 'enabled' : 'disabled'}.` });
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Account status could not be changed.' });
    }
  }

  async function updateRoles(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!editing) return;
    setSaving(true); setNotice(null);
    const roles = new FormData(event.currentTarget).getAll('roles').map(String);
    try {
      const updated = await patch<Staff>(`/api/admin/staff/${editing.id}/roles`, { roles });
      setStaff((current) => current.map((item) => item.id === updated.id ? updated : item));
      setEditing(null);
      setNotice({ kind: 'success', text: `Roles updated for ${updated.name}.` });
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Roles could not be updated.' });
    } finally { setSaving(false); }
  }

  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="ADMINISTRATION / ACCESS CONTROL" title="Staff & roles" description="Create staff accounts and assign the operational sections each person can access." action={<button className="button button-primary" onClick={() => setAdding(true)}><Plus size={16} /> Add staff member</button>} />
    <section className="role-info-grid">{roleInfo.filter(([code]) => code !== 'ADMIN').map(([code, label]) => <article className="role-info" key={code}><ShieldCheck size={17} /><div><strong>{label}</strong><span>{code.replaceAll('_', ' ')}</span></div></article>)}</section>
    <section className="panel table-panel staff-table-panel"><div className="panel-heading"><div><p className="eyebrow">STAFF DIRECTORY</p><h2>Accounts & assigned access</h2></div><span className="count-chip"><UserRound size={15} /> {staff.length} accounts</span></div>{loading ? <div className="table-loading"><span className="spinner" /> Loading staff</div> : staff.length ? <div className="table-scroll"><table><thead><tr><th>Staff member</th><th>Username</th><th>Roles</th><th>Status</th><th className="align-right">Account access</th></tr></thead><tbody>{staff.map((account) => <tr key={account.id}><td><span className="primary-cell">{account.name}</span><span className="sub-cell">{account.email}</span></td><td>{account.username}</td><td><div className="staff-role-chips">{account.roles.map((role) => <span className="category-tag" key={role}>{roleInfo.find(([code]) => code === role)?.[1] ?? role}</span>)}</div></td><td><span className={`status-badge ${account.enabled ? 'status-delivered' : 'status-cancelled'}`}><i />{account.enabled ? 'Enabled' : 'Disabled'}</span></td><td className="align-right"><button className="button button-small button-secondary" onClick={() => setEditing(account)}>Edit roles</button> <button className="button button-small button-secondary" disabled={account.id === user?.id} title={account.id === user?.id ? 'You cannot disable your own account' : ''} onClick={() => void setEnabled(account)}>{account.enabled ? <><UserRoundX size={14} /> Disable</> : <><UserRound size={14} /> Enable</>}</button></td></tr>)}</tbody></table></div> : <EmptyState icon={UserRound} title="No staff accounts" text="Bootstrap an initial administrator, then create team accounts here." />}</section>
    {adding && <Modal title="Create staff account" onClose={() => setAdding(false)}><form className="modal-form" onSubmit={createStaff}><label className="field-label">Full name<input name="name" required maxLength={100} /></label><div className="field-row"><label className="field-label">Username<input name="username" required maxLength={50} autoComplete="off" /></label><label className="field-label">Email<input name="email" type="email" required maxLength={100} /></label></div><label className="field-label">Temporary password<input name="password" type="password" minLength={12} required autoComplete="new-password" /><small>Minimum 12 characters. Share it securely and ask the teammate to change it after first sign-in.</small></label><fieldset className="role-fieldset"><legend>Assign roles</legend>{roleInfo.map(([code, label]) => <label className="role-option" key={code}><input type="checkbox" name="roles" value={code} /> <span><strong>{label}</strong><small>{code.replaceAll('_', ' ')}</small></span></label>)}</fieldset><div className="modal-actions"><button type="button" className="button button-secondary" onClick={() => setAdding(false)}>Cancel</button><button className="button button-primary" disabled={saving}>{saving ? 'Creating…' : 'Create account'}</button></div></form></Modal>}
    {editing && <Modal title={`Edit roles · ${editing.name}`} onClose={() => setEditing(null)}><form className="modal-form" onSubmit={updateRoles}><fieldset className="role-fieldset"><legend>Assigned roles</legend>{roleInfo.map(([code, label]) => <label className="role-option" key={code}><input type="checkbox" name="roles" value={code} defaultChecked={editing.roles.includes(code)} /> <span><strong>{label}</strong><small>{code.replaceAll('_', ' ')}</small></span></label>)}</fieldset><p className="form-hint">Assign only the access this staff member needs. The backend prevents removing your own administrator role.</p><div className="modal-actions"><button type="button" className="button button-secondary" onClick={() => setEditing(null)}>Cancel</button><button className="button button-primary" disabled={saving}>{saving ? 'Saving…' : 'Save roles'}</button></div></form></Modal>}
  </>;
}
