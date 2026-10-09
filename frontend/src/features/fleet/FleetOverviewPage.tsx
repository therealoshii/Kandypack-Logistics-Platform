import { useEffect, useState } from 'react';
import { MapPin, Route, Truck, Warehouse } from 'lucide-react';
import { get } from '../../api';
import type { Store, TruckUtilization } from '../../types';
import { EmptyState, LoadingState, PageHeading } from '../../shared/ui.tsx';

export default function FleetOverviewPage() {
  const [stores, setStores] = useState<Store[]>([]);
  const [trucks, setTrucks] = useState<TruckUtilization[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([get<Store[]>('/api/stores'), get<TruckUtilization[]>('/api/trucks/utilization')])
      .then(([storeRows, truckRows]) => { setStores(storeRows); setTrucks(truckRows); })
      .catch((failure: unknown) => setError(failure instanceof Error ? failure.message : 'Fleet data could not be loaded.'))
      .finally(() => setLoading(false));
  }, []);

  return <>
    <PageHeading eyebrow="SHAMEERA / WAREHOUSES & FLEET" title="Store & fleet hub" description="Regional warehouses, connected routes and truck performance across the distribution network." action={<span className="count-chip"><Warehouse size={15} /> {stores.length} hubs</span>} />
    {error && <div className="inline-feedback">{error}</div>}
    <section className="metric-grid"><article className="metric-card"><div className="metric-top"><span>Regional hubs</span><span className="metric-icon metric-mint"><Warehouse size={18} /></span></div><strong className="metric-value">{loading ? '—' : stores.length}</strong><div className="metric-foot">Stores with delivery routes</div></article><article className="metric-card"><div className="metric-top"><span>Fleet units</span><span className="metric-icon metric-coral"><Truck size={18} /></span></div><strong className="metric-value">{loading ? '—' : trucks.length}</strong><div className="metric-foot">Tracked in utilization</div></article><article className="metric-card"><div className="metric-top"><span>Trips dispatched</span><span className="metric-icon metric-blue"><Route size={18} /></span></div><strong className="metric-value">{loading ? '—' : trucks.reduce((sum, truck) => sum + truck.totalDispatchedTrips, 0)}</strong><div className="metric-foot">Across the reporting period</div></article><article className="metric-card"><div className="metric-top"><span>Deliveries complete</span><span className="metric-icon metric-yellow"><MapPin size={18} /></span></div><strong className="metric-value">{loading ? '—' : trucks.reduce((sum, truck) => sum + truck.totalDeliveriesCompleted, 0)}</strong><div className="metric-foot">Recorded by fleet reports</div></article></section>
    <section className="store-grid">{loading ? <LoadingState label="Loading store network" /> : stores.map((store) => {
      const assigned = trucks.filter((truck) => truck.storeID === store.storeID);
      return <article className="panel store-card" key={store.storeID}><div className="store-card-top"><div className="store-mark"><Warehouse size={18} /></div><span className="category-tag">HUB {String(store.storeID).padStart(2, '0')}</span></div><p className="eyebrow">{store.city}</p><h2>{store.storeName}</h2><div className="store-stats"><span>Capacity<strong>{store.capacity.toLocaleString()} kg</strong></span><span>Fleet<strong>{assigned.length} trucks</strong></span><span>Routes<strong>{store.routes?.length ?? 0}</strong></span></div><div className="store-routes"><strong>Connected routes</strong>{store.routes?.length ? store.routes.map((route) => <div key={route.routeID}><span>{route.routeName}</span><small>{route.distance} km</small></div>) : <small>No route records returned.</small>}</div></article>;
    })}{!loading && !stores.length && <EmptyState icon={Warehouse} title="No regional stores" text="Store records will appear when the backend returns the network." />}</section>
    <section className="panel table-panel"><div className="panel-heading"><div><p className="eyebrow">VEHICLE PERFORMANCE</p><h2>Truck utilization</h2></div><span className="count-chip"><Truck size={15} /> {trucks.length} units</span></div>{loading ? <LoadingState /> : trucks.length ? <div className="table-scroll"><table><thead><tr><th>Vehicle</th><th>Hub</th><th>Capacity</th><th>Trips</th><th>Operating hours</th><th>Completed</th></tr></thead><tbody>{trucks.map((truck) => <tr key={truck.truckID}><td><span className="primary-cell">{truck.registrationNumber}</span></td><td>{truck.storeName}<span className="sub-cell">{truck.stationCity}</span></td><td>{truck.cargoCapacity.toLocaleString()} kg</td><td>{truck.totalDispatchedTrips}</td><td>{truck.totalOperatingHours.toFixed(1)} hrs</td><td><span className="completion-cell">{truck.totalDeliveriesCompleted}</span></td></tr>)}</tbody></table></div> : <EmptyState icon={Truck} title="No utilization data" text="Vehicle utilization appears once the report has trip data." />}</section>
  </>;
}
