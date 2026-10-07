import { useEffect, useState } from 'react';
import { ArrowRight, Boxes, CalendarDays, CheckCircle2, PackageCheck, Route, TrainFront, Truck, Users, Warehouse } from 'lucide-react';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { Link } from 'react-router-dom';
import { get } from '../../api';
import type { Delivery, Driver, Product, QuarterlyReport, Store, TruckTrip } from '../../types';
import { EmptyState, LoadingState, MetricCard, money, PageHeading } from '../../shared/ui';

type Summary = { deliveries: Delivery[]; trips: TruckTrip[]; drivers: Driver[]; stores: Store[]; products: Product[]; quarter: QuarterlyReport[] };
const blank: Summary = { deliveries: [], trips: [], drivers: [], stores: [], products: [], quarter: [] };

async function safe<T>(path: string, fallback: T) { try { return await get<T>(path); } catch { return fallback; } }

export default function AnalyticsDashboardPage() {
  const [data, setData] = useState(blank);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [reload, setReload] = useState(0);
  const now = new Date();
  const year = now.getFullYear();
  const quarter = Math.floor(now.getMonth() / 3) + 1;

  useEffect(() => {
    let active = true;
    Promise.all([
      safe('/api/deliveries', [] as Delivery[]), safe('/api/truck-trips', [] as TruckTrip[]),
      safe('/api/drivers', [] as Driver[]), safe('/api/stores', [] as Store[]),
      safe('/api/products', [] as Product[]), safe(`/api/reports/quarterly-sales?year=${year}&quarter=${quarter}`, [] as QuarterlyReport[]),
    ]).then(([deliveries, trips, drivers, stores, products, quarterly]) => {
      if (active) setData({ deliveries, trips, drivers, stores, products, quarter: quarterly });
    }).catch((failure: unknown) => { if (active) setError(failure instanceof Error ? failure.message : 'Dashboard data could not be loaded.'); })
      .finally(() => { if (active) setLoading(false); });
    return () => { active = false; };
  }, [reload]);

  const open = data.deliveries.filter((delivery) => !['Delivered', 'Cancelled'].includes(delivery.status)).length;
  const totalStock = data.products.reduce((sum, product) => sum + product.stockQuantity, 0);
  const revenue = data.quarter[0]?.totalRevenue ?? 0;
  const chartRows = data.stores.map((store) => ({ city: store.city, routes: store.routes?.length ?? 0 }));

  return <>
    <PageHeading eyebrow="AATHITHAN / SYSTEM ANALYTICS" title="Kandypack operations" description="Daily visibility across customer orders, regional hubs, trip dispatch and delivery performance." action={<button className="button button-secondary" onClick={() => setReload((value) => value + 1)}><CalendarDays size={15} /> Refresh data</button>} />
    {error && <div className="api-warning">{error}</div>}
    <section className="metric-grid"><MetricCard label="Open deliveries" value={loading ? '—' : open} foot="Awaiting final handoff" icon={PackageCheck} accent="mint" /><MetricCard label="Trips today" value={loading ? '—' : data.trips.filter((trip) => trip.tripDate === new Date().toISOString().slice(0, 10)).length} foot={`${data.trips.length} total scheduled`} icon={Truck} accent="coral" /><MetricCard label="Drivers" value={loading ? '—' : data.drivers.length} foot="In active roster" icon={Users} accent="blue" /><MetricCard label="Stock units" value={loading ? '—' : totalStock.toLocaleString()} foot={`${data.products.length} catalog items`} icon={Boxes} accent="yellow" /></section>
    <section className="overview-grid"><article className="panel pulse-panel"><div className="panel-heading"><div><p className="eyebrow">SALES / QUARTER {quarter} {year}</p><h2>Quarterly performance</h2></div><Link className="text-button" to="/analytics/reports">Reports <ArrowRight size={15} /></Link></div>{loading ? <LoadingState label="Loading analytics" /> : data.quarter.length ? <div className="report-stat-grid"><div className="report-stat"><span>Quarter revenue</span><strong>{money(revenue)}</strong><small>{quarter}Q {year}</small></div><div className="report-stat"><span>Orders</span><strong>{data.quarter[0].totalOrders.toLocaleString()}</strong><small>Recorded this quarter</small></div><div className="report-stat"><span>Units sold</span><strong>{data.quarter[0].totalUnitsSold.toLocaleString()}</strong><small>All catalog items</small></div></div> : <EmptyState icon={CheckCircle2} title="No quarterly sales yet" text="Sales analytics appear when the database has order data." />}</article><article className="panel pulse-panel"><div className="panel-heading"><div><p className="eyebrow">DISTRIBUTION FOOTPRINT</p><h2>Regional hubs</h2></div><Warehouse size={18} color="#54836b" /></div>{loading ? <LoadingState /> : chartRows.length ? <div className="region-chart"><ResponsiveContainer width="100%" height="100%"><BarChart data={chartRows} margin={{ top: 8, right: 4, left: -26, bottom: 0 }}><CartesianGrid strokeDasharray="3 4" vertical={false} stroke="#e9ede8" /><XAxis dataKey="city" axisLine={false} tickLine={false} tick={{ fill: '#77817c', fontSize: 9 }} /><YAxis allowDecimals={false} axisLine={false} tickLine={false} tick={{ fill: '#a0a8a3', fontSize: 10 }} /><Tooltip contentStyle={{ borderRadius: 6, border: '1px solid #e6ebe5', fontSize: 12 }} /><Bar dataKey="routes" name="Routes" fill="#43846f" radius={[4, 4, 0, 0]} maxBarSize={36} /></BarChart></ResponsiveContainer></div> : <EmptyState icon={Route} title="Network data unavailable" text="Regional coverage is loaded from the stores API." />}</article></section>
    <section className="panel activity-panel"><div className="panel-heading"><div><p className="eyebrow">WORKSPACE SHORTCUTS</p><h2>Feature domains</h2></div></div><div className="shortcut-grid"><Link to="/orders/new"><ClipboardIcon /><span><strong>Customer & orders</strong><small>Place an order and manage products</small></span><ArrowRight size={16} /></Link><Link to="/cargo/dispatch"><TrainFront size={19} /><span><strong>Rail cargo</strong><small>Check schedules and allocate shipments</small></span><ArrowRight size={16} /></Link><Link to="/fleet/overview"><Warehouse size={19} /><span><strong>Warehouses & fleet</strong><small>View stores, routes and truck use</small></span><ArrowRight size={16} /></Link><Link to="/roster/dispatch"><Truck size={19} /><span><strong>Roster & dispatch</strong><small>Assign trips and update delivery state</small></span><ArrowRight size={16} /></Link></div></section>
  </>;
}
//--

function ClipboardIcon() { return <PackageCheck size={19} />; }
