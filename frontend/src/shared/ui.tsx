import type { ReactNode } from 'react';
import { CircleAlert, X } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';

export type Notice = { kind: 'success' | 'error'; text: string } | null;
export type Perform = <T>(operation: () => Promise<T>, successText: string) => Promise<T | undefined>;

export function PageHeading({ eyebrow, title, description, action }: { eyebrow: string; title: string; description: string; action?: ReactNode }) {
  return <div className="page-heading"><div><p className="eyebrow">{eyebrow}</p><h1>{title}</h1><p className="page-description">{description}</p></div>{action && <div className="heading-action">{action}</div>}</div>;
}

export function MetricCard({ label, value, foot, icon: Icon, accent = 'mint' }: { label: string; value: string | number; foot: string; icon: LucideIcon; accent?: string }) {
  return <article className="metric-card"><div className="metric-top"><span>{label}</span><span className={`metric-icon metric-${accent}`}><Icon size={18} /></span></div><strong className="metric-value">{value}</strong><div className="metric-foot"><span>{foot}</span></div></article>;
}

export function EmptyState({ icon: Icon, title, text }: { icon: LucideIcon; title: string; text: string }) {
  return <div className="empty-state"><div className="empty-icon"><Icon size={20} /></div><strong>{title}</strong><p>{text}</p></div>;
}

export function StatusBadge({ status }: { status: string }) {
  const className = status.toLowerCase().replaceAll(' ', '-');
  return <span className={`status-badge status-${className}`}><i />{status}</span>;
}

export function NoticeBanner({ notice, onDismiss }: { notice: Notice; onDismiss: () => void }) {
  if (!notice) return null;
  return <div className={`notice notice-${notice.kind}`} role="status"><span>{notice.kind === 'success' ? '✓' : <CircleAlert size={17} />}</span><p>{notice.text}</p><button className="icon-button" aria-label="Dismiss notification" onClick={onDismiss}><X size={16} /></button></div>;
}

export function Modal({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) {
  return <div className="modal-backdrop" onMouseDown={(event) => { if (event.target === event.currentTarget) onClose(); }}><section className="modal" role="dialog" aria-modal="true" aria-label={title}><div className="modal-heading"><div><p className="eyebrow">KANDYPACK / OPERATIONS</p><h2>{title}</h2></div><button className="icon-button" aria-label="Close dialog" onClick={onClose}><X size={18} /></button></div>{children}</section></div>;
}

export function LoadingState({ label = 'Loading live data' }: { label?: string }) {
  return <div className="table-loading"><span className="spinner" />{label}</div>;
}

export function dateString(date: Date) {
  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60_000);
  return local.toISOString().slice(0, 10);
}

export function formatDate(value: string) {
  if (!value) return '—';
  const date = new Date(`${value.slice(0, 10)}T00:00:00`);
  return new Intl.DateTimeFormat('en', { day: '2-digit', month: 'short', year: 'numeric' }).format(date);
}


//---
export function money(value: number) {
  return new Intl.NumberFormat('en-LK', { style: 'currency', currency: 'LKR', maximumFractionDigits: 0 }).format(value || 0);
}
