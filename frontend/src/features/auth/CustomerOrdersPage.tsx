import { useEffect, useState } from 'react';
import { ArrowRight, Package, Plus, RefreshCw } from 'lucide-react';
import { Link } from 'react-router-dom';
import { get } from '../../api';
import { EmptyState, formatDate, LoadingState, money, NoticeBanner } from '../../shared/ui';

interface PortalOrderSummary {
  orderID: number;
  orderDate: string;
  requestedDeliveryDate: string;
  status: string;
  deliveryStatus: string;
  totalAmount: number;
}

export default function CustomerOrdersPage() {
  const [orders, setOrders] = useState<PortalOrderSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);

  function loadOrders() {
    setLoading(true);
    setNotice(null);
    get<PortalOrderSummary[]>('/api/portal/orders')
      .then((data) => setOrders(data))
      .catch((error: unknown) => {
        setNotice({
          kind: 'error',
          text: error instanceof Error ? error.message : 'Could not load your orders.',
        });
      })
      .finally(() => setLoading(false));
  }

  useEffect(() => {
    loadOrders();
  }, []);

  return (
    <section>
      <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '16px', marginBottom: '24px' }}>
        <div>
          <p className="eyebrow">CUSTOMER PORTAL</p>
          <h1>My orders</h1>
          <p>Track your placed orders, requested delivery dates, and real-time delivery progress.</p>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button type="button" className="button button-quiet" onClick={loadOrders} disabled={loading} title="Refresh orders">
            <RefreshCw size={15} className={loading ? 'spin' : ''} /> Refresh
          </button>
          <Link className="button button-primary" to="/portal/orders/new">
            <Plus size={16} /> Create a new order
          </Link>
        </div>
      </div>

      {loading ? (
        <LoadingState label="Loading your orders…" />
      ) : orders.length === 0 ? (
        <EmptyState
          icon={Package}
          title="No orders yet"
          text="You have not placed any orders yet. Place your first order to get started."
        />
      ) : (
        <div className="table-scroll">
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Order Date</th>
                <th>Requested Delivery</th>
                <th>Total Amount</th>
                <th>Order Status</th>
                <th>Delivery Status</th>
                <th className="align-right">Action</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <tr key={order.orderID}>
                  <td>
                    <Link to={`/portal/orders/${order.orderID}`} style={{ fontWeight: 600, color: 'var(--brand)' }}>
                      #{order.orderID}
                    </Link>
                  </td>
                  <td>{formatDate(order.orderDate)}</td>
                  <td>{formatDate(order.requestedDeliveryDate)}</td>
                  <td style={{ fontWeight: 600 }}>{money(order.totalAmount)}</td>
                  <td>
                    <span className="category-tag">{order.status}</span>
                  </td>
                  <td>
                    <span className="category-tag">{order.deliveryStatus}</span>
                  </td>
                  <td className="align-right">
                    <Link className="button button-small" to={`/portal/orders/${order.orderID}`}>
                      View details <ArrowRight size={14} />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}
