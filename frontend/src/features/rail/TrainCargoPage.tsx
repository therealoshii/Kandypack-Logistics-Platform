import { useEffect, useState } from 'react';
import { ArrowRight, Search, Send, TrainFront } from 'lucide-react';
import { get, post } from '../../api';
import type { RailSchedule } from '../../types';
import { EmptyState, NoticeBanner, PageHeading } from '../../shared/ui';

function normalizeSchedule(record: Record<string, unknown>): RailSchedule {
  return {
    scheduleId: Number(record.scheduleId ?? record.ScheduleID ?? record.scheduleID),
    trainName: String(record.trainName ?? record.TrainName ?? ''),
    departureTime: String(record.departureTime ?? record.DepartureTime ?? ''),
    maxCapacity: Number(record.maxCapacity ?? record.MaxCapacity ?? 0),
    availableCapacity: Number(record.availableCapacity ?? record.AvailableCapacity ?? 0),
  };
}

export default function TrainCargoPage() {
  const [date, setDate] = useState(new Date().toISOString().slice(0, 10));
  const [schedules, setSchedules] = useState<RailSchedule[]>([]);
  const [loading, setLoading] = useState(false);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const [shipment, setShipment] = useState({ orderDetailId: '', scheduleId: '', quantity: '1', shipmentDate: new Date().toISOString().slice(0, 10) });

  async function searchSchedules(event?: React.FormEvent) {
    event?.preventDefault(); setLoading(true); setNotice(null);
    try {
      const rows = await get<Record<string, unknown>[]>(`/api/trains/schedules?date=${encodeURIComponent(date)}`);
      setSchedules(rows.map(normalizeSchedule));
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Train schedules could not be loaded.' });
    } finally { setLoading(false); }
  }

  useEffect(() => { void searchSchedules(); }, []);

  async function scheduleShipment(event: React.FormEvent) {
    event.preventDefault(); setNotice(null);
    try {
      const result = await post<{ message?: string }>('/api/shipments/schedule', {
        orderDetailId: Number(shipment.orderDetailId), scheduleId: Number(shipment.scheduleId),
        shipmentDate: shipment.shipmentDate, quantity: Number(shipment.quantity),
      });
      setNotice({ kind: 'success', text: result.message || 'Shipment scheduled successfully.' });
      await searchSchedules();
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Shipment could not be scheduled.' });
    }
  }

  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="WIDUSHI / RAIL CARGO & SHIPMENTS" title="Train cargo dispatch" description="Review train capacity for a shipment date and assign order lines to a schedule." action={<span className="rule-chip"><TrainFront size={15} /> Kandy origin</span>} />
    <div className="rail-grid"><section className="panel table-panel rail-schedule-panel"><div className="panel-heading"><div><p className="eyebrow">AVAILABLE CAPACITY</p><h2>Train schedules</h2></div><form className="date-filter" onSubmit={searchSchedules}><input aria-label="Shipment date" type="date" value={date} onChange={(event) => setDate(event.target.value)} /><button className="button button-primary button-small"><Search size={15} /> Search</button></form></div>
      {loading ? <div className="table-loading"><span className="spinner" /> Checking schedules</div> : schedules.length ? <div className="schedule-cards">{schedules.map((schedule) => {
        const used = schedule.maxCapacity ? Math.max(0, Math.min(100, (schedule.maxCapacity - schedule.availableCapacity) / schedule.maxCapacity * 100)) : 0;
        const capacityClass = used >= 100 ? 'capacity-full' : used >= 70 ? 'capacity-busy' : 'capacity-open';
        return <article className="schedule-card" key={schedule.scheduleId}><div className="train-symbol"><TrainFront size={19} /></div><div className="schedule-main"><strong>{schedule.trainName}</strong><span>Schedule #{schedule.scheduleId} · Departs {schedule.departureTime}</span></div><div className="capacity-block"><span>{Math.round(used)}% ALLOCATED</span><strong>{schedule.availableCapacity.toLocaleString()}<small> / {schedule.maxCapacity.toLocaleString()} free</small></strong><div className={`capacity-track ${capacityClass}`}><i style={{ width: `${used}%` }} /></div></div><button className="icon-button" aria-label={`Select schedule ${schedule.scheduleId}`} title="Use this schedule" onClick={() => setShipment((current) => ({ ...current, scheduleId: String(schedule.scheduleId), shipmentDate: date }))}><ArrowRight size={17} /></button></article>;
      })}</div> : <EmptyState icon={TrainFront} title="No schedules for this date" text="Try another shipment date to see train availability." />}</section>
      <form className="panel form-panel shipment-form" onSubmit={scheduleShipment}><div className="panel-heading"><div><p className="eyebrow">ALLOCATE CARGO</p><h2>Schedule shipment</h2></div><div className="form-icon"><Send size={17} /></div></div><label className="field-label">Order detail ID<input type="number" min="1" required value={shipment.orderDetailId} onChange={(event) => setShipment({ ...shipment, orderDetailId: event.target.value })} placeholder="Enter order line ID" /><small>The current API does not expose order detail lookup.</small></label><label className="field-label">Train schedule<select required value={shipment.scheduleId} onChange={(event) => setShipment({ ...shipment, scheduleId: event.target.value })}><option value="">Select a schedule</option>{schedules.map((schedule) => <option key={schedule.scheduleId} value={schedule.scheduleId}>{schedule.trainName} · #{schedule.scheduleId}</option>)}</select></label><div className="field-row"><label className="field-label">Quantity<input type="number" min="1" required value={shipment.quantity} onChange={(event) => setShipment({ ...shipment, quantity: event.target.value })} /></label><label className="field-label">Shipment date<input type="date" required value={shipment.shipmentDate} onChange={(event) => setShipment({ ...shipment, shipmentDate: event.target.value })} /></label></div><button className="button button-primary button-full"><Send size={16} /> Schedule shipment</button></form>
    </div>
    <p className="capacity-legend"><span className="capacity-open-dot" /> Under 70% allocated <span className="capacity-busy-dot" /> 70–99% <span className="capacity-full-dot" /> Full</p>
  </>;
}
