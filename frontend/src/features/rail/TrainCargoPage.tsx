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
  const [orderDetailId, setOrderDetailId] = useState('');
  const [scheduleId, setScheduleId] = useState('');

  const selectedLine = pendingLines.find((line) => String(line.orderDetailId) === orderDetailId);
  // A shipment can only go on a train to the order's own destination store
  const matchingSchedules = selectedLine ? schedules.filter((schedule) => schedule.destination === selectedLine.destination) : schedules;
  // True when an order line is chosen but no train goes to its city on the chosen date
  const noTrainThatDay = Boolean(selectedLine) && !loading && matchingSchedules.length === 0;

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

  // Drop a chosen schedule that no longer fits the selected order line or date
  useEffect(() => {
    if (scheduleId && !matchingSchedules.some((schedule) => String(schedule.scheduleId) === scheduleId)) setScheduleId('');
  }, [orderDetailId, schedules]);

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
    if (!selectedLine) return;
    setSubmitting(true);
    try {
      // The procedure ships everything still waiting on the line; overflow rolls to the next run
      const result = await post<{ message?: string }>('/api/shipments/schedule', {
        orderDetailId: selectedLine.orderDetailId, scheduleId: Number(scheduleId),
        shipmentDate: date, quantity: selectedLine.remainingQuantity,
      });
      setNotice({ kind: 'success', text: result.message || 'Shipment scheduled successfully.' });
      setOrderDetailId(''); setScheduleId('');
      await Promise.all([loadSchedules(date), loadPendingLines()]);
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Shipment could not be scheduled.' });
    } finally { setSubmitting(false); }
  }

  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="WIDUSHI / RAIL CARGO & SHIPMENTS" title="Train cargo dispatch" description="Review train capacity for a shipment date and assign order lines to a schedule." action={<span className="rule-chip"><TrainFront size={15} /> Kandy origin</span>} />
    <div className="rail-grid"><section className="panel table-panel rail-schedule-panel"><div className="panel-heading"><div><p className="eyebrow">AVAILABLE CAPACITY</p><h2>Train schedules</h2></div><form className="date-filter" onSubmit={searchSchedules}><input aria-label="Shipment date" type="date" value={date} onChange={(event) => changeShipmentDate(event.target.value)} /><button className="button button-primary button-small"><Search size={15} /> Search</button></form></div>
      {loading ? <div className="table-loading"><span className="spinner" /> Checking schedules</div> : schedules.length ? <div className="schedule-cards">{schedules.map((schedule) => {
        const used = schedule.maxCapacity ? Math.max(0, Math.min(100, (schedule.maxCapacity - schedule.availableCapacity) / schedule.maxCapacity * 100)) : 0;
        const capacityClass = used >= 100 ? 'capacity-full' : used >= 70 ? 'capacity-busy' : 'capacity-open';
        return <article className="schedule-card" key={schedule.scheduleId}><div className="train-symbol"><TrainFront size={19} /></div><div className="schedule-main"><strong>{schedule.trainName}</strong><span>Schedule #{schedule.scheduleId} · Departs {schedule.departureTime}</span><span className="schedule-destination" style={{ display: 'block', fontSize: '0.82rem', color: 'var(--text-secondary, #666)' }}>Destination: <strong>{schedule.destination || 'Unknown'}</strong></span></div><div className="capacity-block"><span>{Math.round(used)}% ALLOCATED</span><strong>{schedule.availableCapacity.toLocaleString()}<small> / {schedule.maxCapacity.toLocaleString()} free</small></strong><div className={`capacity-track ${capacityClass}`}><i style={{ width: `${used}%` }} /></div></div><button className="icon-button" aria-label={`Select schedule ${schedule.scheduleId}`} title="Use this schedule" onClick={() => setScheduleId(String(schedule.scheduleId))}><ArrowRight size={17} /></button></article>;
      })}</div> : <EmptyState icon={TrainFront} title="No schedules for this date" text="Try another shipment date to see train availability." />}</section>
      <form className="panel form-panel shipment-form" onSubmit={scheduleShipment}><div className="panel-heading"><div><p className="eyebrow">ALLOCATE CARGO</p><h2>Schedule shipment</h2></div><div className="form-icon"><Send size={17} /></div></div>
        <label className="field-label">Order line<select required value={orderDetailId} onChange={(event) => setOrderDetailId(event.target.value)}><option value="">{linesLoading ? 'Loading order lines…' : pendingLines.length ? 'Select an order line' : 'No order lines are waiting'}</option>{pendingLines.map((line) => <option key={line.orderDetailId} value={line.orderDetailId}>Order #{line.orderId} · {line.customerName} · {line.productName} · {line.remainingQuantity} units to {line.destination}</option>)}</select>
          {selectedLine && <small>Line #{selectedLine.orderDetailId}: {selectedLine.remainingQuantity} of {selectedLine.orderedQuantity} units still to ship, needing {selectedLine.spaceRequired.toLocaleString()} space units. Trains to {selectedLine.destination} run on {selectedLine.trainDays || 'no scheduled day'}.</small>}</label>
        <label className="field-label">Shipment date<input type="date" required value={date} onChange={(event) => changeShipmentDate(event.target.value)} /></label>
        <label className="field-label">Train schedule<select required disabled={noTrainThatDay} value={scheduleId} onChange={(event) => setScheduleId(event.target.value)}><option value="">{noTrainThatDay && selectedLine ? `No train to ${selectedLine.destination} on this date` : 'Select a schedule'}</option>{matchingSchedules.map((schedule) => <option key={schedule.scheduleId} value={schedule.scheduleId}>{schedule.trainName} · #{schedule.scheduleId} ({schedule.destination || 'Unknown'}) · {schedule.availableCapacity.toLocaleString()} free</option>)}</select></label>
        {noTrainThatDay && selectedLine && <div className="inline-feedback" role="alert" style={{ display: 'block' }}>Trains to {selectedLine.destination} run on {selectedLine.trainDays || 'no scheduled day'}. Pick one of the next dates:<div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px', marginTop: '8px' }}>{nextTrainDates(date, selectedLine.trainDays).map((next) => <button type="button" key={next} className="button button-small button-secondary" onClick={() => changeShipmentDate(next)}>{WEEKDAYS[new Date(`${next}T00:00:00Z`).getUTCDay()].slice(0, 3)} · {formatDate(next)}</button>)}</div></div>}
        <label className="field-label">Quantity to ship<input type="text" readOnly value={selectedLine ? `${selectedLine.remainingQuantity} units` : 'Select an order line'} /><small>The whole remaining quantity is booked. Anything that does not fit rolls over to the next train to the same city.</small></label>
        <button className="button button-primary button-full" disabled={submitting || !selectedLine}><Send size={16} /> {submitting ? 'Scheduling…' : 'Schedule shipment'}</button></form>
    </div>
    <p className="capacity-legend"><span className="capacity-open-dot" /> Under 70% allocated <span className="capacity-busy-dot" /> 70–99% <span className="capacity-full-dot" /> Full</p>
    <section className="panel table-panel" style={{ marginTop: '14px' }}><div className="panel-heading"><div><p className="eyebrow">AWAITING A TRAIN</p><h2>Order lines to ship</h2></div><span className="count-chip"><PackageSearch size={15} /> {pendingLines.length} lines</span></div>
      {linesLoading ? <div className="table-loading"><span className="spinner" /> Loading order lines</div> : pendingLines.length ? <div className="table-scroll"><table><thead><tr><th>Order</th><th>Customer</th><th>Product</th><th className="align-right">To ship</th><th className="align-right">Space</th><th>Destination</th><th>Trains run on</th><th /></tr></thead><tbody>{pendingLines.map((line) => <tr key={line.orderDetailId}><td><span className="primary-cell">#{line.orderId}</span><span className="sub-cell">Line #{line.orderDetailId} · {formatDate(line.orderDate)}</span></td><td>{line.customerName}<span className="sub-cell">{line.orderStatus}</span></td><td>{line.productName}</td><td className="align-right">{line.remainingQuantity.toLocaleString()}<span className="sub-cell">of {line.orderedQuantity.toLocaleString()}</span></td><td className="align-right">{line.spaceRequired.toLocaleString()}</td><td>{line.destination}</td><td>{line.trainDays}</td><td><button type="button" className="button button-small button-quiet" onClick={() => { setOrderDetailId(String(line.orderDetailId)); window.scrollTo({ top: 0, behavior: 'smooth' }); }}>Select</button></td></tr>)}</tbody></table></div> : <EmptyState icon={PackageSearch} title="Nothing is waiting for a train" text="New order lines appear here as soon as an order is placed." />}</section>
  </>;
}
