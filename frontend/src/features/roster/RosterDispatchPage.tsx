import { useEffect, useState } from 'react';
import { CalendarDays, CheckCircle2, Clock3, Plus, Truck, UserRound, Users } from 'lucide-react';
import { get, patch, post, remove } from '../../api';
import type { Assistant, Delivery, Driver, StaffHours, Store, TruckTrip, TruckUtilization } from '../../types';
import { dateString, EmptyState, formatDate, LoadingState, Modal, NoticeBanner, PageHeading, StatusBadge } from '../../shared/ui';

type RosterData = { deliveries: Delivery[]; trips: TruckTrip[]; drivers: Driver[]; assistants: Assistant[]; stores: Store[]; trucks: TruckUtilization[]; hours: StaffHours[] };
const empty: RosterData = { deliveries: [], trips: [], drivers: [], assistants: [], stores: [], trucks: [], hours: [] };

async function loadResource<T>(path: string, fallback: T): Promise<T> {
  try { return await get<T>(path); } catch { return fallback; }
}

export default function RosterDispatchPage() {
  const [view, setView] = useState<'trips' | 'deliveries' | 'crew'>('trips');
  const [data, setData] = useState(empty);
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const [modal, setModal] = useState<'trip' | 'driver' | 'assistant' | null>(null);
  const [saving, setSaving] = useState(false);
  const [reloadKey, setReloadKey] = useState(0);
  const [tripRouteId, setTripRouteId] = useState('');

  // When a form opens or closes: forget the chosen route, and drop any old error
  // so a new form does not open showing the previous form's message
  useEffect(() => {
    if (modal !== 'trip') setTripRouteId('');
    if (modal) setNotice((current) => (current?.kind === 'error' ? null : current));
  }, [modal]);

  useEffect(() => {
    let current = true;
    Promise.all([
      loadResource('/api/deliveries', [] as Delivery[]), loadResource('/api/truck-trips', [] as TruckTrip[]),
      loadResource('/api/drivers', [] as Driver[]), loadResource('/api/assistants', [] as Assistant[]),
      loadResource('/api/stores', [] as Store[]), loadResource('/api/trucks/utilization', [] as TruckUtilization[]),
      loadResource('/api/staff/roster-quota', [] as StaffHours[]),
    ]).then(([deliveries, trips, drivers, assistants, stores, trucks, hours]) => {
      if (current) setData({ deliveries, trips, drivers, assistants, stores, trucks, hours });
    }).finally(() => { if (current) setLoading(false); });
    return () => { current = false; };
  }, [reloadKey]);

  async function run<T>(operation: () => Promise<T>, success: string) {
    setNotice(null);
    try { const result = await operation(); setNotice({ kind: 'success', text: success }); setReloadKey((value) => value + 1); return result; }
    catch (error) { setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Request failed.' }); return undefined; }
  }

  async function createTrip(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setSaving(true);
    const form = new FormData(event.currentTarget);
    const payload = { truckId: Number(form.get('truckId')), routeId: Number(form.get('routeId')), driverId: Number(form.get('driverId')), assistantId: Number(form.get('assistantId')), tripDate: String(form.get('tripDate')), dispatchTime: String(form.get('dispatchTime')), returnTime: String(form.get('returnTime')) };
    const result = await run(() => post('/api/truck-trips/assign', payload), 'Trip assignment submitted.');
    setSaving(false); if (result !== undefined) setModal(null);
  }

  async function createCrew(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setSaving(true);
    const form = new FormData(event.currentTarget);
    const type = modal === 'driver' ? 'drivers' : 'assistants';
    const payload = modal === 'driver'
      ? { name: String(form.get('name')), licenceNumber: String(form.get('licenceNumber')), contactNumber: String(form.get('contactNumber')) }
      : { name: String(form.get('name')), contactNumber: String(form.get('contactNumber')) };
    const result = await run(() => post(`/api/${type}`, payload), `${modal === 'driver' ? 'Driver' : 'Assistant'} added to roster.`);
    setSaving(false); if (result !== undefined) setModal(null);
  }

  const todayTrips = data.trips.filter((trip) => trip.tripDate === dateString(new Date()));
  // Newest trips first, and deliveries that still need action above the closed ones,
  // so the rows a dispatcher works on are at the top next to the result message
  const trips = [...data.trips].sort((a, b) => b.tripDate.localeCompare(a.tripDate) || b.dispatchTime.localeCompare(a.dispatchTime));
  const isClosed = (status: string) => ['Delivered', 'Cancelled'].includes(status);
  const deliveries = [...data.deliveries].sort((a, b) => Number(isClosed(a.status)) - Number(isClosed(b.status)) || b.deliveryDate.localeCompare(a.deliveryDate));
  // Only trucks based at the selected route's store can run that route
  const tripStore = data.stores.find((store) => store.routes.some((route) => String(route.routeID) === tripRouteId));
  const routeTrucks = tripStore ? data.trucks.filter((truck) => truck.storeID === tripStore.storeID) : [];
  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="OSHAN / ROSTER & TRIP DISPATCH" title="Roster & dispatch console" description="Assign trips within roster constraints and manage delivery state transitions." action={view === 'trips' ? <button className="button button-primary" onClick={() => setModal('trip')}><Plus size={16} /> Assign trip</button> : view === 'crew' ? <button className="button button-primary" onClick={() => setModal('driver')}><Plus size={16} /> Add driver</button> : <span className="count-chip"><CheckCircle2 size={15} /> {data.deliveries.length} deliveries</span>} />
    <section className="metric-grid"><MetricCard label="Trips today" value={loading ? '—' : todayTrips.length} foot={`${data.trips.length} total scheduled`} icon={Truck} accent="coral" /><MetricCard label="Drivers" value={loading ? '—' : data.drivers.length} foot="In the roster" icon={UserRound} accent="mint" /><MetricCard label="Assistants" value={loading ? '—' : data.assistants.length} foot="Required per trip" icon={Users} accent="blue" /><MetricCard label="Active deliveries" value={loading ? '—' : data.deliveries.filter((item) => !['Delivered', 'Cancelled'].includes(item.status)).length} foot="Not yet closed" icon={CheckCircle2} accent="yellow" /></section>
    <div className="segmented-control" role="tablist" aria-label="Roster views">{([['trips', 'Trip dispatch'], ['deliveries', 'Deliveries'], ['crew', 'Crew & quotas']] as const).map(([key, label]) => <button role="tab" aria-selected={view === key} className={view === key ? 'segment-active' : ''} key={key} onClick={() => setView(key)}>{label}</button>)}</div>
    {view === 'trips' && <section className="panel table-panel"><div className="panel-heading"><div><p className="eyebrow">SCHEDULED ROAD MOVEMENT</p><h2>Trip assignments</h2></div><span className="count-chip"><CalendarDays size={15} /> {data.trips.length} trips</span></div>{loading ? <LoadingState label="Loading trips" /> : data.trips.length ? <div className="table-scroll"><table><thead><tr><th>Trip</th><th>Date</th><th>Route / truck</th><th>Assigned crew</th><th>Dispatch window</th></tr></thead><tbody>{trips.map((trip) => <tr key={trip.tripId}><td><span className="primary-cell">T-{String(trip.tripId).padStart(4, '0')}</span></td><td>{formatDate(trip.tripDate)}</td><td>Route #{trip.routeId} · Truck #{trip.truckId}</td><td>{trip.driverName || `Driver #${trip.driverId}`} · {trip.assistantName || `Assistant #${trip.assistantId}`}</td><td>{trip.dispatchTime?.slice(0, 5)} — {trip.returnTime?.slice(0, 5)}</td></tr>)}</tbody></table></div> : <EmptyState icon={Truck} title="No trips assigned" text="Assign a truck, route, driver and assistant to create a trip." />}</section>}
    {view === 'deliveries' && <section className="panel table-panel"><div className="panel-heading"><div><p className="eyebrow">CUSTOMER HANDOFF</p><h2>Delivery status</h2></div></div>{loading ? <LoadingState label="Loading deliveries" /> : data.deliveries.length ? <div className="table-scroll"><table><thead><tr><th>Delivery</th><th>Order / trip</th><th>Delivery date</th><th>Status</th><th className="align-right">Transition</th></tr></thead><tbody>{deliveries.map((delivery) => <tr key={delivery.deliveryId}><td><span className="primary-cell">D-{String(delivery.deliveryId).padStart(4, '0')}</span></td><td>Order #{delivery.orderId} · Trip #{delivery.tripId}</td><td>{formatDate(delivery.deliveryDate)}</td><td><StatusBadge status={delivery.status} /></td><td className="align-right"><select className="status-control" aria-label={`Update delivery ${delivery.deliveryId}`} value={delivery.status} onChange={(event) => void run(() => patch(`/api/deliveries/${delivery.deliveryId}/status`, { status: event.target.value }), `Delivery ${delivery.deliveryId} moved to ${event.target.value}.`)}><option>Scheduled</option><option>In Transit</option><option>Delivered</option><option>Cancelled</option></select></td></tr>)}</tbody></table></div> : <EmptyState icon={CheckCircle2} title="No delivery records" text="Scheduled deliveries appear here." />}</section>}
    {view === 'crew' && <section className="crew-grid"><CrewPanel title="Drivers" kind="driver" members={data.drivers} onAdd={() => setModal('driver')} onDelete={(id) => run(() => remove(`/api/drivers/${id}`), 'Driver removed.')} /><CrewPanel title="Assistants" kind="assistant" members={data.assistants} onAdd={() => setModal('assistant')} onDelete={(id) => run(() => remove(`/api/assistants/${id}`), 'Assistant removed.')} /><section className="panel hours-panel"><div className="panel-heading"><div><p className="eyebrow">WEEKLY ROSTER QUOTA</p><h2>Hours & limits</h2></div><span className="count-chip"><Clock3 size={14} /> {data.hours.length} staff</span></div>{data.hours.length ? <div className="hours-list">{data.hours.map((row, index) => <div className="hours-row" key={`${row.staffRole}-${row.staffId}-${row.weekStartDate}-${index}`}><span className="hours-person">{row.staffName}<small>{row.staffRole} · {row.remainingHours.toFixed(1)}h left this week</small></span><span className="hours-bar"><i style={{ width: `${Math.min(100, row.weeklyLimit ? row.totalHoursWorked / row.weeklyLimit * 100 : 0)}%` }} /></span><span className="hours-count">{row.totalHoursWorked.toFixed(1)}<small> / {row.weeklyLimit}h</small></span></div>)}</div> : <EmptyState icon={Clock3} title="Quota report unavailable" text="The backend did not return roster hour data." />}</section></section>}
    {modal && <Modal title={modal === 'trip' ? 'Assign a trip' : `Add ${modal}`} onClose={() => setModal(null)}>{notice?.kind === 'error' && <div className="login-error" role="alert">{notice.text}</div>}{modal === 'trip' ? <form className="modal-form" onSubmit={createTrip}><label className="field-label">Route<select name="routeId" required value={tripRouteId} onChange={(event) => setTripRouteId(event.target.value)}><option value="">Select route</option>{data.stores.flatMap((store) => store.routes.map((route) => <option key={route.routeID} value={route.routeID}>{route.routeName} · {store.city}</option>))}</select></label><label className="field-label">Truck<select name="truckId" required defaultValue="" key={tripRouteId} disabled={!tripRouteId}><option value="">{tripRouteId ? 'Select fleet unit' : 'Select a route first'}</option>{routeTrucks.map((truck) => <option key={truck.truckID} value={truck.truckID}>{truck.registrationNumber} · {truck.stationCity}</option>)}</select></label><div className="field-row"><label className="field-label">Driver<select name="driverId" required defaultValue=""><option value="">Assign driver</option>{data.drivers.map((driver) => <option key={driver.driverId} value={driver.driverId}>{driver.name}</option>)}</select></label><label className="field-label">Assistant<select name="assistantId" required defaultValue=""><option value="">Assign assistant</option>{data.assistants.map((assistant) => <option key={assistant.assistantId} value={assistant.assistantId}>{assistant.name}</option>)}</select></label></div><label className="field-label">Trip date<input name="tripDate" type="date" required defaultValue={dateString(new Date())} /></label><div className="field-row"><label className="field-label">Dispatch time<input name="dispatchTime" type="time" required defaultValue="08:00" /></label><label className="field-label">Return time<input name="returnTime" type="time" required defaultValue="11:00" /></label></div><p className="form-hint">Database roster rules are validated on submission; the API response is shown if a limit is exceeded.</p><div className="modal-actions"><button type="button" className="button button-secondary" onClick={() => setModal(null)}>Cancel</button><button className="button button-primary" disabled={saving}>{saving ? 'Saving…' : 'Assign trip'}</button></div></form> : <form className="modal-form" onSubmit={createCrew}><label className="field-label">Full name<input name="name" required maxLength={100} /></label>{modal === 'driver' && <label className="field-label">Licence number<input name="licenceNumber" required maxLength={30} /></label>}<label className="field-label">Contact number<input name="contactNumber" required maxLength={15} /></label><div className="modal-actions"><button type="button" className="button button-secondary" onClick={() => setModal(null)}>Cancel</button><button className="button button-primary" disabled={saving}>{saving ? 'Saving…' : 'Add to roster'}</button></div></form>}</Modal>}
  </>;
}

function MetricCard({ label, value, foot, icon: Icon, accent }: { label: string; value: number | string; foot: string; icon: typeof Truck; accent: string }) {
  return <article className="metric-card"><div className="metric-top"><span>{label}</span><span className={`metric-icon metric-${accent}`}><Icon size={18} /></span></div><strong className="metric-value">{value}</strong><div className="metric-foot">{foot}</div></article>;
}

function CrewPanel({ title, kind, members, onAdd, onDelete }: { title: string; kind: 'driver' | 'assistant'; members: (Driver | Assistant)[]; onAdd: () => void; onDelete: (id: number) => Promise<unknown> }) {
  return <section className="panel roster-panel"><div className="panel-heading"><div><p className="eyebrow">ROAD CREW</p><h2>{title}</h2></div><button className="icon-button" aria-label={`Add ${kind}`} onClick={onAdd}><Plus size={18} /></button></div><div className="roster-list">{members.map((member) => { const id = kind === 'driver' ? (member as Driver).driverId : (member as Assistant).assistantId; return <div className="roster-member" key={id}><div className={`person-mark person-${kind}`}>{member.name.split(/\s+/).slice(0, 2).map((part) => part[0]).join('').toUpperCase()}</div><div className="person-details"><strong>{member.name}</strong><span>{kind === 'driver' ? (member as Driver).licenceNumber : member.contactNumber}</span></div><button className="icon-button delete-quiet" aria-label={`Remove ${member.name}`} onClick={() => { if (window.confirm(`Remove ${member.name} from the roster?`)) void onDelete(id); }}>×</button></div>; })}{!members.length && <EmptyState icon={Users} title={`No ${title.toLowerCase()} yet`} text="Add a crew member to build the roster." />}</div><button className="text-button roster-add" onClick={onAdd}><Plus size={15} /> Add {kind}</button></section>;
}
