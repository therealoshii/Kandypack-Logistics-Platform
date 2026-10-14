import { useEffect, useState } from 'react';
import { ArrowRight, PackageSearch, Search, Send, TrainFront } from 'lucide-react';
import { get, post } from '../../api';
import type { RailSchedule } from '../../types';
import { EmptyState, formatDate, NoticeBanner, PageHeading } from '../../shared/ui';

type Schedule = RailSchedule & { destination?: string };

// An order line that still has units waiting for a train (GET /api/shipments/pending-lines)
interface PendingLine {
  orderDetailId: number;
  orderId: number;
  orderDate: string;
  orderStatus: string;
  customerName: string;
  productName: string;
  orderedQuantity: number;
  remainingQuantity: number;
  spaceRequired: number;
  destination: string;
  trainDays: string;
}

// The waiting lines of one order, shown and shipped together
interface PendingOrder {
  orderId: number;
  orderDate: string;
  orderStatus: string;
  customerName: string;
  destination: string;
  trainDays: string;
  lines: PendingLine[];
  unitsWaiting: number;
  spaceRequired: number;
}

// Booking choice in the form: every waiting line of the order, or one line by its ID
const WHOLE_ORDER = 'all';

function normalizeSchedule(record: Record<string, unknown>): Schedule {
  return {
    scheduleId: Number(record.scheduleId ?? record.ScheduleID ?? record.scheduleID),
    trainName: String(record.trainName ?? record.TrainName ?? ''),
    departureTime: String(record.departureTime ?? record.DepartureTime ?? ''),
    maxCapacity: Number(record.maxCapacity ?? record.MaxCapacity ?? 0),
    availableCapacity: Number(record.availableCapacity ?? record.AvailableCapacity ?? 0),
    destination: String(record.destination ?? record.Destination ?? record.StoreName ?? record.storeName ?? 'Unknown'),
  };
}

function normalizeLine(record: Record<string, unknown>): PendingLine {
  return {
    orderDetailId: Number(record.orderDetailId),
    orderId: Number(record.orderId),
    orderDate: String(record.orderDate ?? ''),
    orderStatus: String(record.orderStatus ?? ''),
    customerName: String(record.customerName ?? ''),
    productName: String(record.productName ?? ''),
    orderedQuantity: Number(record.orderedQuantity ?? 0),
    remainingQuantity: Number(record.remainingQuantity ?? 0),
    spaceRequired: Number(record.spaceRequired ?? 0),
    destination: String(record.destination ?? ''),
    trainDays: String(record.trainDays ?? ''),
  };
}

// Lines arrive oldest order first, so the orders keep that order
function groupByOrder(lines: PendingLine[]): PendingOrder[] {
  const orders = new Map<number, PendingOrder>();
  for (const line of lines) {
    const order = orders.get(line.orderId) ?? {
      orderId: line.orderId, orderDate: line.orderDate, orderStatus: line.orderStatus, customerName: line.customerName,
      destination: line.destination, trainDays: line.trainDays, lines: [], unitsWaiting: 0, spaceRequired: 0,
    };
    order.lines.push(line);
    order.unitsWaiting += line.remainingQuantity;
    order.spaceRequired += line.spaceRequired;
    orders.set(line.orderId, order);
  }
  return [...orders.values()];
}

const plural = (count: number, word: string) => `${count.toLocaleString()} ${word}${count === 1 ? '' : 's'}`;

const WEEKDAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

// The next few dates, after the given one, that fall on one of the train's running days
function nextTrainDates(fromDate: string, trainDays: string, count = 3): string[] {
  const days = trainDays.split(',').map((day) => day.trim());
  const start = new Date(`${fromDate}T00:00:00Z`);
  const dates: string[] = [];
  if (Number.isNaN(start.getTime())) return dates;
  for (let offset = 1; offset <= 14 && dates.length < count; offset += 1) {
    const next = new Date(start.getTime() + offset * 86400000);
    if (days.includes(WEEKDAYS[next.getUTCDay()])) dates.push(next.toISOString().slice(0, 10));
  }
  return dates;
}

export default function TrainCargoPage() {
  // One date drives both the schedule list and the shipment being booked
  const [date, setDate] = useState(new Date().toISOString().slice(0, 10));
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [pendingLines, setPendingLines] = useState<PendingLine[]>([]);
  const [loading, setLoading] = useState(false);
  const [linesLoading, setLinesLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const [orderId, setOrderId] = useState('');
  const [lineChoice, setLineChoice] = useState(WHOLE_ORDER);
  const [scheduleId, setScheduleId] = useState('');

  const pendingOrders = groupByOrder(pendingLines);
  const selectedOrder = pendingOrders.find((order) => String(order.orderId) === orderId);
  const selectedLine = selectedOrder?.lines.find((line) => String(line.orderDetailId) === lineChoice);
  // What the button books: the chosen line, or every waiting line of the order
  const unitsToShip = selectedLine ? selectedLine.remainingQuantity : selectedOrder?.unitsWaiting ?? 0;
  const spaceToShip = selectedLine ? selectedLine.spaceRequired : selectedOrder?.spaceRequired ?? 0;
  // A shipment can only go on a train to the order's own destination store
  const matchingSchedules = selectedOrder ? schedules.filter((schedule) => schedule.destination === selectedOrder.destination) : schedules;
  // True when an order is chosen but no train goes to its city on the chosen date
  const noTrainThatDay = Boolean(selectedOrder) && !loading && matchingSchedules.length === 0;

  async function loadSchedules(forDate: string) {
    setLoading(true);
    try {
      const rows = await get<Record<string, unknown>[]>(`/api/trains/schedules?date=${encodeURIComponent(forDate)}`);
      setSchedules(rows.map(normalizeSchedule));
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Train schedules could not be loaded.' });
    } finally { setLoading(false); }
  }

  async function loadPendingLines() {
    setLinesLoading(true);
    try {
      const rows = await get<Record<string, unknown>[]>('/api/shipments/pending-lines');
      setPendingLines(rows.map(normalizeLine));
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Order lines could not be loaded.' });
    } finally { setLinesLoading(false); }
  }

  useEffect(() => { void loadSchedules(date); void loadPendingLines(); }, []);

  // Drop a chosen schedule that no longer fits the selected order or date
  useEffect(() => {
    if (scheduleId && !matchingSchedules.some((schedule) => String(schedule.scheduleId) === scheduleId)) setScheduleId('');
  }, [orderId, schedules]);

  function selectOrder(value: string) {
    setOrderId(value);
    setLineChoice(WHOLE_ORDER);
  }

  function searchSchedules(event: React.FormEvent) {
    event.preventDefault(); setNotice(null);
    void loadSchedules(date);
  }

  function changeShipmentDate(value: string) {
    setDate(value);
    if (value) void loadSchedules(value);
  }

  async function scheduleShipment(event: React.FormEvent) {
    event.preventDefault(); setNotice(null);
    if (!selectedOrder) return;
    setSubmitting(true);
    try {
      // Everything still waiting is booked; overflow rolls over to the next run to the same city
      const result = selectedLine
        ? await post<{ message?: string }>('/api/shipments/schedule', {
          orderDetailId: selectedLine.orderDetailId, scheduleId: Number(scheduleId),
          shipmentDate: date, quantity: selectedLine.remainingQuantity,
        })
        : await post<{ message?: string }>('/api/shipments/schedule-order', {
          orderId: selectedOrder.orderId, scheduleId: Number(scheduleId), shipmentDate: date,
        });
      setNotice({ kind: 'success', text: result.message || 'Shipment scheduled successfully.' });
      selectOrder(''); setScheduleId('');
      await Promise.all([loadSchedules(date), loadPendingLines()]);
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Shipment could not be scheduled.' });
    } finally { setSubmitting(false); }
  }

  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="WIDUSHI / RAIL CARGO & SHIPMENTS" title="Train cargo dispatch" description="Review train capacity for a shipment date and book orders onto a schedule." action={<span className="rule-chip"><TrainFront size={15} /> Kandy origin</span>} />
    <div className="rail-grid"><section className="panel table-panel rail-schedule-panel"><div className="panel-heading"><div><p className="eyebrow">AVAILABLE CAPACITY</p><h2>Train schedules</h2></div><form className="date-filter" onSubmit={searchSchedules}><input aria-label="Shipment date" type="date" value={date} onChange={(event) => changeShipmentDate(event.target.value)} /><button className="button button-primary button-small"><Search size={15} /> Search</button></form></div>
      {loading ? <div className="table-loading"><span className="spinner" /> Checking schedules</div> : schedules.length ? <div className="schedule-cards">{schedules.map((schedule) => {
        const used = schedule.maxCapacity ? Math.max(0, Math.min(100, (schedule.maxCapacity - schedule.availableCapacity) / schedule.maxCapacity * 100)) : 0;
        const capacityClass = used >= 100 ? 'capacity-full' : used >= 70 ? 'capacity-busy' : 'capacity-open';
        return <article className="schedule-card" key={schedule.scheduleId}><div className="train-symbol"><TrainFront size={19} /></div><div className="schedule-main"><strong>{schedule.trainName}</strong><span>Schedule #{schedule.scheduleId} · Departs {schedule.departureTime}</span><span className="schedule-destination" style={{ display: 'block', fontSize: '0.82rem', color: 'var(--text-secondary, #666)' }}>Destination: <strong>{schedule.destination || 'Unknown'}</strong></span></div><div className="capacity-block"><span>{Math.round(used)}% ALLOCATED</span><strong>{schedule.availableCapacity.toLocaleString()}<small> / {schedule.maxCapacity.toLocaleString()} free</small></strong><div className={`capacity-track ${capacityClass}`}><i style={{ width: `${used}%` }} /></div></div><button className="icon-button" aria-label={`Select schedule ${schedule.scheduleId}`} title="Use this schedule" onClick={() => setScheduleId(String(schedule.scheduleId))}><ArrowRight size={17} /></button></article>;
      })}</div> : <EmptyState icon={TrainFront} title="No schedules for this date" text="Try another shipment date to see train availability." />}</section>
      <form className="panel form-panel shipment-form" onSubmit={scheduleShipment}><div className="panel-heading"><div><p className="eyebrow">ALLOCATE CARGO</p><h2>Schedule shipment</h2></div><div className="form-icon"><Send size={17} /></div></div>
        <label className="field-label">Order<select required value={orderId} onChange={(event) => selectOrder(event.target.value)}><option value="">{linesLoading ? 'Loading orders…' : pendingOrders.length ? 'Select an order' : 'No orders are waiting'}</option>{pendingOrders.map((order) => <option key={order.orderId} value={order.orderId}>Order #{order.orderId} · {order.customerName} · {plural(order.lines.length, 'line')} to {order.destination}</option>)}</select>
          {selectedOrder && <small>{selectedOrder.lines.map((line) => `${line.productName} × ${line.remainingQuantity.toLocaleString()}`).join(' · ')}. Trains to {selectedOrder.destination} run on {selectedOrder.trainDays || 'no scheduled day'}.</small>}</label>
        {selectedOrder && selectedOrder.lines.length > 1 && <label className="field-label">What to ship<select value={lineChoice} onChange={(event) => setLineChoice(event.target.value)}><option value={WHOLE_ORDER}>Whole order · {plural(selectedOrder.lines.length, 'line')}, {plural(selectedOrder.unitsWaiting, 'unit')}</option>{selectedOrder.lines.map((line) => <option key={line.orderDetailId} value={line.orderDetailId}>Only line #{line.orderDetailId} · {line.productName} × {line.remainingQuantity.toLocaleString()}</option>)}</select><small>A whole order is booked in one step: every line goes on, or none does.</small></label>}
        <label className="field-label">Shipment date<input type="date" required value={date} onChange={(event) => changeShipmentDate(event.target.value)} /></label>
        <label className="field-label">Train schedule<select required disabled={noTrainThatDay} value={scheduleId} onChange={(event) => setScheduleId(event.target.value)}><option value="">{noTrainThatDay && selectedOrder ? `No train to ${selectedOrder.destination} on this date` : 'Select a schedule'}</option>{matchingSchedules.map((schedule) => <option key={schedule.scheduleId} value={schedule.scheduleId}>{schedule.trainName} · #{schedule.scheduleId} ({schedule.destination || 'Unknown'}) · {schedule.availableCapacity.toLocaleString()} free</option>)}</select></label>
        {noTrainThatDay && selectedOrder && <div className="inline-feedback" role="alert" style={{ display: 'block' }}>Trains to {selectedOrder.destination} run on {selectedOrder.trainDays || 'no scheduled day'}. Pick one of the next dates:<div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px', marginTop: '8px' }}>{nextTrainDates(date, selectedOrder.trainDays).map((next) => <button type="button" key={next} className="button button-small button-secondary" onClick={() => changeShipmentDate(next)}>{WEEKDAYS[new Date(`${next}T00:00:00Z`).getUTCDay()].slice(0, 3)} · {formatDate(next)}</button>)}</div></div>}
        <label className="field-label">Quantity to ship<input type="text" readOnly value={selectedOrder ? `${plural(unitsToShip, 'unit')} · ${spaceToShip.toLocaleString()} space units` : 'Select an order'} /><small>Everything still waiting is booked. Anything that does not fit rolls over to the next train to the same city.</small></label>
        <button className="button button-primary button-full" disabled={submitting || !selectedOrder}><Send size={16} /> {submitting ? 'Scheduling…' : selectedLine ? 'Ship this line' : 'Ship whole order'}</button></form>
    </div>
    <p className="capacity-legend"><span className="capacity-open-dot" /> Under 70% allocated <span className="capacity-busy-dot" /> 70–99% <span className="capacity-full-dot" /> Full</p>
    <section className="panel table-panel" style={{ marginTop: '14px' }}><div className="panel-heading"><div><p className="eyebrow">AWAITING A TRAIN</p><h2>Orders to ship</h2></div><span className="count-chip"><PackageSearch size={15} /> {plural(pendingOrders.length, 'order')} · {plural(pendingLines.length, 'line')}</span></div>
      {linesLoading ? <div className="table-loading"><span className="spinner" /> Loading orders</div> : pendingOrders.length ? <div className="table-scroll"><table><thead><tr><th>Order</th><th>Customer</th><th>Products waiting</th><th className="align-right">To ship</th><th className="align-right">Space</th><th>Destination</th><th>Trains run on</th><th /></tr></thead><tbody>{pendingOrders.map((order) => <tr key={order.orderId}><td><span className="primary-cell">#{order.orderId}</span><span className="sub-cell">{formatDate(order.orderDate)}</span></td><td>{order.customerName}<span className="sub-cell">{order.orderStatus}</span></td><td>{order.lines.map((line) => <span key={line.orderDetailId} style={{ display: 'block' }}>{line.productName} × {line.remainingQuantity.toLocaleString()}{line.remainingQuantity < line.orderedQuantity && <span className="sub-cell" style={{ display: 'inline' }}> of {line.orderedQuantity.toLocaleString()}</span>}</span>)}</td><td className="align-right">{order.unitsWaiting.toLocaleString()}<span className="sub-cell">{plural(order.lines.length, 'line')}</span></td><td className="align-right">{order.spaceRequired.toLocaleString()}</td><td>{order.destination}</td><td>{order.trainDays}</td><td><button type="button" className="button button-small button-quiet" onClick={() => { selectOrder(String(order.orderId)); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>Select</button></td></tr>)}</tbody></table></div> : <EmptyState icon={PackageSearch} title="Nothing is waiting for a train" text="New orders appear here as soon as they are placed." />}</section>
  </>;
}
