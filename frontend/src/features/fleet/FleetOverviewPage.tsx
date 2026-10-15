import { useCallback, useEffect, useState } from 'react';
import { MapPin, Route, Truck, Warehouse, Plus, X } from 'lucide-react';
import { get, post } from '../../api';
import type { Route as RouteType, Store, TruckUtilization } from '../../types';
import { EmptyState, LoadingState, PageHeading } from '../../shared/ui.tsx';

type FormMode = 'store' | 'truck' | 'route' | null;

export default function FleetOverviewPage() {
  const [stores, setStores] = useState<Store[]>([]);
  const [trucks, setTrucks] = useState<TruckUtilization[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [formMode, setFormMode] = useState<FormMode>(null);
  const [saving, setSaving] = useState(false);

  const [storeName, setStoreName] = useState('');
  const [storeCity, setStoreCity] = useState('');
  const [storeCapacity, setStoreCapacity] = useState('');

  const [registrationNumber, setRegistrationNumber] = useState('');
  const [truckCapacity, setTruckCapacity] = useState('');
  const [truckStoreID, setTruckStoreID] = useState('');

  const [routeName, setRouteName] = useState('');
  const [routeStoreID, setRouteStoreID] = useState('');
  const [routeMaxDeliveryTime, setRouteMaxDeliveryTime] = useState('');
  const [routeDistance, setRouteDistance] = useState('');

  const loadData = useCallback(async () => {
    const [storeRows, truckRows] = await Promise.all([
      get<Store[]>('/api/stores'),
      get<TruckUtilization[]>('/api/trucks/utilization'),
    ]);
    setStores(storeRows);
    setTrucks(truckRows);
  }, []);

  useEffect(() => {
    loadData()
      .catch((failure: unknown) =>
        setError(failure instanceof Error
          ? failure.message
          : 'Fleet data could not be loaded.'))
      .finally(() => setLoading(false));
  }, [loadData]);

  function closeForm() {
    setFormMode(null);
    setError('');
    setSuccess('');
  }

  async function handleCreateStore(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSuccess('');
    setSaving(true);

    try {
      await post<Store>('/api/stores', {
        storeName: storeName.trim(),
        city: storeCity.trim(),
        capacity: Number(storeCapacity),
      });

      await loadData();
      setStoreName('');
      setStoreCity('');
      setStoreCapacity('');
      setFormMode(null);
      setSuccess('Store created successfully.');
    } catch (failure) {
      setError(failure instanceof Error
        ? failure.message
        : 'Could not create the store.');
    } finally {
      setSaving(false);
    }
  }

  async function handleCreateTruck(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSuccess('');
    setSaving(true);

    try {
      await post('/api/trucks', {
        registrationNumber: registrationNumber.trim(),
        capacity: Number(truckCapacity),
        storeID: Number(truckStoreID),
      });

      await loadData();
      setRegistrationNumber('');
      setTruckCapacity('');
      setTruckStoreID('');
      setFormMode(null);
      setSuccess('Truck created successfully.');
    } catch (failure) {
      setError(failure instanceof Error
        ? failure.message
        : 'Could not create the truck.');
    } finally {
      setSaving(false);
    }
  }

  
  async function handleCreateRoute(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSuccess('');
    setSaving(true);

    try {
      await post<RouteType>('/api/routes', {
        routeName: routeName.trim(),
        storeID: Number(routeStoreID),
        maxDeliveryTime: Number(routeMaxDeliveryTime),
        distance: Number(routeDistance),
      });

      await loadData();
      setRouteName('');
      setRouteStoreID('');
      setRouteMaxDeliveryTime('');
      setRouteDistance('');
      setFormMode(null);
      setSuccess('Route created successfully.');
    } catch (failure) {
      setError(
        failure instanceof Error
          ? failure.message
          : 'Could not create the route.',
      );
    } finally {
      setSaving(false);
    }
  }


  return <>
    <PageHeading
      eyebrow="SHAMEERA / WAREHOUSES & FLEET"
      title="Store & fleet hub"
      description="Regional warehouses, connected routes and truck performance across the distribution network."
      action={
        <div className="fleet-actions">
          <span className="count-chip">
            <Warehouse size={15} /> {stores.length} hubs
          </span>
          <button type="button" onClick={() => {
            setError('');
            setSuccess('');
            setFormMode('store');
          }}>
            <Plus size={15} /> Add Store
          </button>
          <button type="button" onClick={() => {
            setError('');
            setSuccess('');
            setFormMode('truck');
          }}>
            <Plus size={15} /> Add Truck
          </button>

          <button type="button" onClick={() => {
            setError('');
            setSuccess('');
            setFormMode('route');
          }}>
            <Plus size={15} /> Add Route
          </button>
        </div>
      }
    />

    {error && <div className="inline-feedback" role="alert">{error}</div>}
    {success && <div className="notice-success" role="status">{success}</div>}

    {formMode && (
      <section className="panel fleet-form-panel">
        <div className="panel-heading">
          <div>
            <p className="eyebrow">FLEET MANAGEMENT</p>
            <h2>
              {formMode === 'store'
                ? 'Add a store'
                : formMode === 'truck'
                  ? 'Add a truck'
                  : 'Add a route'}
            </h2>
          </div>
          <button type="button" onClick={closeForm} aria-label="Close form">
            <X size={18} />
          </button>
        </div>

        {formMode === 'store' ? (
          <form onSubmit={handleCreateStore} className="fleet-form">
            <label>
              Store name
              <input
                value={storeName}
                onChange={(event) => setStoreName(event.target.value)}
                maxLength={100}
                required
                placeholder="e.g. Kandy Regional Store"
              />
            </label>
            <label>
              City
              <input
                value={storeCity}
                onChange={(event) => setStoreCity(event.target.value)}
                maxLength={50}
                required
                placeholder="e.g. Kandy"
              />
            </label>
            <label>
              Capacity (units)
              <input
                type="number"
                min="0.01"
                step="0.01"
                value={storeCapacity}
                onChange={(event) => setStoreCapacity(event.target.value)}
                required
                placeholder="Enter store capacity"
              />
            </label>
            <button type="submit" disabled={saving}>
              {saving ? 'Saving...' : 'Save Store'}
            </button>
          </form>
        ) : formMode === 'truck' ? (
          <form onSubmit={handleCreateTruck} className="fleet-form">
            <label>
              Registration number
              <input
                value={registrationNumber}
                onChange={(event) => setRegistrationNumber(event.target.value)}
                maxLength={20}
                required
                placeholder="e.g. WP-ABC-1234"
              />
            </label>
            <label>
              Capacity (units)
              <input
                type="number"
                min="0.01"
                step="0.01"
                value={truckCapacity}
                onChange={(event) => setTruckCapacity(event.target.value)}
                required
                placeholder="Enter truck capacity"
              />
            </label>
            <label>
              Assign to store
              <select
                value={truckStoreID}
                onChange={(event) => setTruckStoreID(event.target.value)}
                required
              >
                <option value="">Select a store</option>
                {stores.map((store) => (
                  <option key={store.storeID} value={store.storeID}>
                    {store.storeName} — {store.city}
                  </option>
                ))}
              </select>
            </label>
            {stores.length === 0 && (
              <p>Create a store before adding a truck.</p>
            )}
            <button type="submit" disabled={saving || stores.length === 0}>
              {saving ? 'Saving...' : 'Save Truck'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleCreateRoute} className="fleet-form">
            <label>
              Route name
              <input
                value={routeName}
                onChange={(event) => setRouteName(event.target.value)}
                maxLength={100}
                required
                placeholder="e.g. Wellawatta to Colombo Fort"
              />
            </label>

            <label>
              Assign to store
              <select
                value={routeStoreID}
                onChange={(event) => setRouteStoreID(event.target.value)}
                required
              >
                <option value="">Select a store</option>
                {stores.map((store) => (
                  <option key={store.storeID} value={store.storeID}>
                    {store.storeName} — {store.city}
                  </option>
                ))}
              </select>
            </label>

            <label>
              Maximum delivery time (hours)
              <input
                type="number"
                min="0.01"
                max="999"
                step="0.01"
                value={routeMaxDeliveryTime}
                onChange={(event) =>
                  setRouteMaxDeliveryTime(event.target.value)
                }
                required
                placeholder="e.g. 2"
              />
            </label>

            <label>
              Distance (km)
              <input
                type="number"
                min="0.01"
                step="0.01"
                value={routeDistance}
                onChange={(event) => setRouteDistance(event.target.value)}
                required
                placeholder="e.g. 15.5"
              />
            </label>

            {stores.length === 0 && (
              <p>Create a store before adding a route.</p>
            )}

            <button
              type="submit"
              disabled={saving || stores.length === 0}
            >
              {saving ? 'Saving...' : 'Save Route'}
            </button>
          </form>
        )}
      </section>
    )}

    <section className="metric-grid">
      <article className="metric-card">
        <div className="metric-top"><span>Regional hubs</span><span className="metric-icon metric-mint"><Warehouse size={18} /></span></div>
        <strong className="metric-value">{loading ? '—' : stores.length}</strong>
        <div className="metric-foot">Stores with delivery routes</div>
      </article>
      <article className="metric-card">
        <div className="metric-top"><span>Fleet units</span><span className="metric-icon metric-coral"><Truck size={18} /></span></div>
        <strong className="metric-value">{loading ? '—' : trucks.length}</strong>
        <div className="metric-foot">Tracked in utilization</div>
      </article>
      <article className="metric-card">
        <div className="metric-top"><span>Trips dispatched</span><span className="metric-icon metric-blue"><Route size={18} /></span></div>
        <strong className="metric-value">{loading ? '—' : trucks.reduce((sum, truck) => sum + truck.totalDispatchedTrips, 0)}</strong>
        <div className="metric-foot">Across the reporting period</div>
      </article>
      <article className="metric-card">
        <div className="metric-top"><span>Deliveries complete</span><span className="metric-icon metric-yellow"><MapPin size={18} /></span></div>
        <strong className="metric-value">{loading ? '—' : trucks.reduce((sum, truck) => sum + truck.totalDeliveriesCompleted, 0)}</strong>
        <div className="metric-foot">Recorded by fleet reports</div>
      </article>
    </section>

    <section className="store-grid">
      {loading ? <LoadingState label="Loading store network" /> : stores.map((store) => {
        const assigned = trucks.filter((truck) => truck.storeID === store.storeID);
        return (
          <article className="panel store-card" key={store.storeID}>
            <div className="store-card-top">
              <div className="store-mark"><Warehouse size={18} /></div>
              <span className="category-tag">HUB {String(store.storeID).padStart(2, '0')}</span>
            </div>
            <p className="eyebrow">{store.city}</p>
            <h2>{store.storeName}</h2>
            <div className="store-stats">
              <span>Capacity<strong>{store.capacity.toLocaleString()} units</strong></span>
              <span>Fleet<strong>{assigned.length} {assigned.length === 1 ? 'truck' : 'trucks'}</strong></span>
              <span>Routes<strong>{store.routes?.length ?? 0}</strong></span>
            </div>
            <div className="store-routes">
              <strong>Connected routes</strong>
              {store.routes?.length
                ? store.routes.map((route) => (
                    <div key={route.routeID}>
                      <span>{route.routeName}</span>
                      <small>{route.distance} km</small>
                    </div>
                  ))
                : <small>No route records returned.</small>}
            </div>
          </article>
        );
      })}
      {!loading && !stores.length && (
        <EmptyState icon={Warehouse} title="No regional stores" text="Store records will appear when the backend returns the network." />
      )}
    </section>

    <section className="panel table-panel">
      <div className="panel-heading">
        <div><p className="eyebrow">VEHICLE PERFORMANCE</p><h2>Truck utilization</h2></div>
        <span className="count-chip"><Truck size={15} /> {trucks.length} units</span>
      </div>
      {loading ? <LoadingState /> : trucks.length ? (
        <div className="table-scroll">
          <table>
            <thead>
              <tr><th>Vehicle</th><th>Hub</th><th>Capacity</th><th>Trips</th><th>Operating hours</th><th>Completed</th></tr>
            </thead>
            <tbody>
              {trucks.map((truck) => (
                <tr key={truck.truckID}>
                  <td><span className="primary-cell">{truck.registrationNumber}</span></td>
                  <td>{truck.storeName}<span className="sub-cell">{truck.stationCity}</span></td>
                  <td>{truck.cargoCapacity.toLocaleString()} units</td>
                  <td>{truck.totalDispatchedTrips}</td>
                  <td>{truck.totalOperatingHours.toFixed(1)} hrs</td>
                  <td><span className="completion-cell">{truck.totalDeliveriesCompleted}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <EmptyState icon={Truck} title="No utilization data" text="Vehicle utilization appears once the report has trip data." />
      )}
    </section>
  </>;
}