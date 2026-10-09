import { useEffect, useState } from 'react';
import { ArrowRight, BarChart3, Boxes, ClipboardList, PackageCheck, Route, TrainFront, Truck, Warehouse } from 'lucide-react';
import { Link } from 'react-router-dom';
import { get } from '../../api';
import type { QuarterlyReport } from '../../types';
import { EmptyState, LoadingState, MetricCard, money, PageHeading } from '../../shared/ui';
import { useAuth } from '../../shared/auth';

export default function AnalyticsDashboardPage() {
  const { hasRole } = useAuth();
  const now = new Date();
  const year = now.getFullYear();
  const quarter = Math.floor(now.getMonth() / 3) + 1;
  const [rows, setRows] = useState<QuarterlyReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    get<QuarterlyReport[]>(`/api/reports/quarterly-sales?year=${year}&quarter=${quarter}`)
      .then(setRows)
      .catch((failure: unknown) => setError(failure instanceof Error ? failure.message : 'Sales summary could not be loaded.'))
      .finally(() => setLoading(false));
  }, [year, quarter]);

  const report = rows[0];
  return <>
    <PageHeading eyebrow="MANAGEMENT / ANALYTICS" title="Kandypack operations" description="Quarterly business performance and authorized shortcuts for your staff role." action={<Link className="button button-secondary" to="/analytics/reports"><BarChart3 size={15} /> Open reports</Link>} />
    {error && <div className="api-warning">{error}</div>}
    {loading ? <section className="panel"><LoadingState label="Loading quarterly summary" /></section> : report ? <section className="metric-grid"><MetricCard label="Quarter revenue" value={money(report.totalRevenue)} foot={`Quarter ${report.quarter} · ${report.year}`} icon={BarChart3} accent="mint" /><MetricCard label="Orders processed" value={report.totalOrders.toLocaleString()} foot="For this quarter" icon={ClipboardList} accent="coral" /><MetricCard label="Units sold" value={report.totalUnitsSold.toLocaleString()} foot="Across all catalog items" icon={Boxes} accent="blue" /><MetricCard label="Reporting period" value={`Q${report.quarter}`} foot={String(report.year)} icon={Route} accent="yellow" /></section> : <section className="panel"><EmptyState icon={BarChart3} title="No quarterly sales data" text="The summary appears when order data exists for this period." /></section>}
    <section className="panel activity-panel"><div className="panel-heading"><div><p className="eyebrow">WORKSPACE AREAS</p><h2>Operations sections</h2></div></div><div className="shortcut-grid">{hasRole('ADMIN', 'ORDER_MANAGER') && <Link to="/orders/new"><ClipboardList size={19} /><span><strong>Customer & orders</strong><small>Order placement and customer catalog</small></span><ArrowRight size={16} /></Link>}{hasRole('ADMIN', 'RAIL_DISPATCHER') && <Link to="/cargo/dispatch"><TrainFront size={19} /><span><strong>Rail cargo</strong><small>Train schedules and shipment allocation</small></span><ArrowRight size={16} /></Link>}{hasRole('ADMIN', 'FLEET_MANAGER') && <Link to="/fleet/overview"><Warehouse size={19} /><span><strong>Warehouses & fleet</strong><small>Regional stores, routes and truck use</small></span><ArrowRight size={16} /></Link>}{hasRole('ADMIN', 'ROSTER_DISPATCHER') && <Link to="/roster/dispatch"><Truck size={19} /><span><strong>Roster & dispatch</strong><small>Trip assignments and delivery progress</small></span><ArrowRight size={16} /></Link>}{hasRole('ADMIN', 'ANALYST') && <Link to="/analytics/reports"><PackageCheck size={19} /><span><strong>Reports</strong><small>Sales, regional and fleet insights</small></span><ArrowRight size={16} /></Link>}</div></section>
  </>;
}
