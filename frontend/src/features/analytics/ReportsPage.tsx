import { useEffect, useState } from 'react';
import { Download, FileText } from 'lucide-react';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { get } from '../../api';
import { EmptyState, LoadingState, money, PageHeading } from '../../shared/ui';

type ReportKind = 'quarterly' | 'top-items' | 'geographic' | 'staff' | 'fleet';
type ReportRow = Record<string, string | number | null>;
const reportTabs: { key: ReportKind; label: string }[] = [
  { key: 'quarterly', label: 'Quarterly sales' }, { key: 'top-items', label: 'Top items' },
  { key: 'geographic', label: 'By region' }, { key: 'staff', label: 'Staff hours' }, { key: 'fleet', label: 'Fleet use' },
];

function humanize(value: string) {
  return value.replace(/([a-z])([A-Z])/g, '$1 $2').replaceAll('_', ' ').replace(/^./, (letter) => letter.toUpperCase());
}

export default function ReportsPage() {
  const now = new Date();
  const [kind, setKind] = useState<ReportKind>('quarterly');
  const [year, setYear] = useState(String(now.getFullYear()));
  const [quarter, setQuarter] = useState(String(Math.floor(now.getMonth() / 3) + 1));
  const [startDate, setStartDate] = useState(new Date(now.getFullYear(), 0, 1).toISOString().slice(0, 10));
  const [endDate, setEndDate] = useState(now.toISOString().slice(0, 10));
  const [rows, setRows] = useState<ReportRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function loadReport(event?: React.FormEvent) {
    event?.preventDefault(); setLoading(true); setError('');
    let path = '';
    if (kind === 'quarterly') path = `/api/reports/quarterly-sales?year=${year}&quarter=${quarter}`;
    if (kind === 'top-items') path = `/api/reports/top-items?year=${year}&quarter=${quarter}&limit=10`;
    if (kind === 'geographic') path = `/api/reports/geographic-sales?startDate=${startDate}&endDate=${endDate}`;
    if (kind === 'staff') path = `/api/reports/staff-hours?startDate=${startDate}&endDate=${endDate}`;
    if (kind === 'fleet') path = `/api/reports/fleet-usage?year=${year}&month=${now.getMonth() + 1}`;
    try { setRows(await get<ReportRow[]>(path)); }
    catch (failure) { setRows([]); setError(failure instanceof Error ? failure.message : 'Report could not be loaded.'); }
    finally { setLoading(false); }
  }

  useEffect(() => { void loadReport(); }, [kind]);

  function exportRows() {
    if (!rows.length) return;
    const headers = Object.keys(rows[0]);
    const content = [headers.join(','), ...rows.map((row) => headers.map((header) => `"${String(row[header] ?? '').replaceAll('"', '""')}"`).join(','))].join('\n');
    const url = URL.createObjectURL(new Blob([content], { type: 'text/csv' }));
    const link = document.createElement('a'); link.href = url; link.download = `kandypack-${kind}-${new Date().toISOString().slice(0, 10)}.csv`; link.click(); URL.revokeObjectURL(url);
  }

  const chartData = rows.map((row) => ({
    label: String(row.productName ?? row.city ?? row.weekStartDate ?? row.registrationNumber ?? row.quarter ?? ''),
    value: Number(row.totalRevenueGenerated ?? row.totalSales ?? row.totalRevenue ?? row.totalHoursWorked ?? row.operatingHours ?? row.totalTrips ?? 0),
  })).filter((row) => row.label);
  const isChartReport = ['top-items', 'geographic', 'quarterly'].includes(kind);

  return <>
    <PageHeading eyebrow="AATHITHAN / ARCHITECTURE & ANALYTICS" title="Reports & analytics" description="Explore quarterly sales, product demand, regional performance, crew hours and fleet usage." action={<button className="button button-secondary" onClick={exportRows} disabled={!rows.length}><Download size={16} /> Export CSV</button>} />
    <div className="segmented-control report-tabs" role="tablist" aria-label="Report type">{reportTabs.map((tab) => <button role="tab" aria-selected={kind === tab.key} className={kind === tab.key ? 'segment-active' : ''} key={tab.key} onClick={() => setKind(tab.key)}>{tab.label}</button>)}</div>
    <section className="panel report-panel"><div className="report-toolbar"><div><p className="eyebrow">{kind.replace('-', ' ').toUpperCase()} REPORT</p><h2>{reportTabs.find((tab) => tab.key === kind)?.label}</h2></div><form className="report-filters" onSubmit={loadReport}>{['quarterly', 'top-items', 'fleet'].includes(kind) ? <><label>Year<input type="number" min="2000" max="2100" value={year} onChange={(event) => setYear(event.target.value)} /></label>{kind !== 'fleet' && <label>Quarter<select value={quarter} onChange={(event) => setQuarter(event.target.value)}><option value="1">Q1</option><option value="2">Q2</option><option value="3">Q3</option><option value="4">Q4</option></select></label>}</> : <><label>From<input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} /></label><label>To<input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} /></label></>}<button className="button button-primary button-small" disabled={loading}>{loading ? 'Loading…' : 'Run report'}</button></form></div>
      {error && <div className="inline-feedback">{error}</div>}
      {loading ? <LoadingState label="Building report" /> : rows.length ? <>{kind === 'quarterly' && <div className="report-stat-grid">{[['Quarter revenue', rows[0].totalRevenue], ['Orders processed', rows[0].totalOrders], ['Units sold', rows[0].totalUnitsSold]].map(([label, value]) => <div className="report-stat" key={String(label)}><span>{label}</span><strong>{label === 'Quarter revenue' ? money(Number(value)) : Number(value ?? 0).toLocaleString()}</strong><small>{quarter}Q {year}</small></div>)}</div>}{kind !== 'quarterly' && isChartReport && <div className="report-chart"><ResponsiveContainer width="100%" height="100%"><BarChart data={chartData} margin={{ top: 8, right: 12, left: 0, bottom: 8 }}><CartesianGrid strokeDasharray="3 4" vertical={false} stroke="#e9ede8" /><XAxis dataKey="label" axisLine={false} tickLine={false} tick={{ fill: '#77817c', fontSize: 10 }} /><YAxis axisLine={false} tickLine={false} tick={{ fill: '#a0a8a3', fontSize: 10 }} /><Tooltip formatter={(value) => kind === 'top-items' || kind === 'geographic' ? money(Number(value)) : Number(value)} contentStyle={{ borderRadius: 6, border: '1px solid #e6ebe5', fontSize: 12 }} /><Bar dataKey="value" name="Value" fill="#43846f" radius={[4, 4, 0, 0]} maxBarSize={42} /></BarChart></ResponsiveContainer></div>}<div className="table-scroll"><table><thead><tr>{Object.keys(rows[0]).map((key) => <th key={key}>{humanize(key)}</th>)}</tr></thead><tbody>{rows.map((row, index) => <tr key={index}>{Object.keys(rows[0]).map((key) => <td key={key}>{String(row[key] ?? '—')}</td>)}</tr>)}</tbody></table></div></> : <EmptyState icon={FileText} title={error ? 'Report unavailable' : 'No rows for this period'} text={error ? 'Check that the backend report endpoint and database are available.' : 'Try another reporting period or verify that source data exists.'} />}
    </section>
  </>;
}
