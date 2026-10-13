import { useEffect, useState } from 'react';
import { ArrowLeft, Package, ShieldAlert, Truck } from 'lucide-react';
import { Link, useParams } from 'react-router-dom';
import { ApiError, get } from '../../api';
import { EmptyState, formatDate, LoadingState, money, NoticeBanner } from '../../shared/ui';

interface PortalOrderItem {
  orderDetailID: number;
  orderDetailId?: number;
  productID: number;
  productId?: number;
  productName: string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
}

interface PortalDeliveryProgress {
  deliveryID: number;
  deliveryId?: number;
  status: string;
  deliveryDate?: string;
  tripID?: number;
  tripId?: number;
  dispatchTime?: string;
  returnTime?: string;
  driverName?: string;
  assistantName?: string;
  truckRegistration?: string;
}

interface PortalOrderDetails {
  orderID: number;
  orderId?: number;
  customerID: number;
  customerId?: number;
  orderDate: string;
  requestedDeliveryDate: string;
  status: string;
  totalAmount: number;
  deliveryStatus: string;
  deliveryDate?: string;
  routeName?: string;
  destinationCity?: string;
  items: PortalOrderItem[];
  delivery?: PortalDeliveryProgress;
}

export default function CustomerOrderDetailsPage() {
  const { id } = useParams<{ id: string }>();
  const [order, setOrder] = useState<PortalOrderDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    setNotFound(false);
    setNotice(null);

    get<PortalOrderDetails>(`/api/portal/orders/${id}`)
      .then((data) => {
        setOrder(data);
      })
      .catch((error: unknown) => {
        if (error instanceof ApiError && error.status === 404) {
          setNotFound(true);
        } else {
          setNotice({
            kind: 'error',
            text: error instanceof Error ? error.message : 'Could not load order details.',
          });
        }
      })
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) {
    return (
      <section>
        <LoadingState label={`Loading details for order #${id}…`} />
      </section>
    );
  }

  if (notFound) {
    return (
      <section>
        <EmptyState
          icon={ShieldAlert}
          title="Order Not Found (404)"
          text={`Order #${id} does not exist or does not belong to your account.`}
        />
        <div style={{ textAlign: 'center', marginTop: '20px' }}>
          <Link className="button button-primary" to="/portal">
            <ArrowLeft size={16} /> Back to My Orders
          </Link>
        </div>
      </section>
    );
  }

  if (!order) {
    return (
      <section>
        <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
        <p>Order details could not be retrieved.</p>
        <Link className="button" to="/portal">
          <ArrowLeft size={16} /> Back to My Orders
        </Link>
      </section>
    );
  }

  const orderId = order.orderID ?? order.orderId;
  const isDelivered = order.status === 'Delivered' || order.deliveryStatus === 'Delivered';
  const isInTransit = order.status === 'In Transit' || order.deliveryStatus === 'In Transit';
  const isScheduled = order.deliveryStatus === 'Scheduled';
  const isCancelled = order.status === 'Cancelled' || order.deliveryStatus === 'Cancelled';

  return (
    <section>
      <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '16px', marginBottom: '24px' }}>
        <div>
          <Link to="/portal" style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: 'var(--muted)', marginBottom: '8px' }}>
            <ArrowLeft size={14} /> Back to My Orders
          </Link>
          <p className="eyebrow">ORDER DETAILS</p>
          <h1>Order #{orderId}</h1>
          <p>Placed on {formatDate(order.orderDate)} · Requested delivery: {formatDate(order.requestedDeliveryDate)}</p>
        </div>
        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <span className="category-tag" style={{ fontSize: '13px', padding: '6px 12px' }}>
            Order: {order.status}
          </span>
          <span className="category-tag" style={{ fontSize: '13px', padding: '6px 12px' }}>
            Delivery: {order.deliveryStatus}
          </span>
        </div>
      </div>

      {/* Delivery Progress Card */}
      <div className="panel" style={{ padding: '24px', marginBottom: '24px', background: 'var(--surface)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
          <Truck size={20} color="var(--brand)" />
          <h2 style={{ fontSize: '17px', margin: 0 }}>Delivery Progress</h2>
        </div>

        {/* Status Stepper */}
        <div style={{ display: 'flex', justifyContent: 'space-between', position: 'relative', margin: '24px 0 28px', maxWidth: '700px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', zIndex: 1 }}>
            <span style={{ width: '28px', height: '28px', borderRadius: '50%', background: 'var(--brand)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '13px', fontWeight: 600 }}>✓</span>
            <span style={{ fontSize: '12px', fontWeight: 500 }}>Placed</span>
            <small style={{ color: 'var(--muted)', fontSize: '11px' }}>{formatDate(order.orderDate)}</small>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', zIndex: 1 }}>
            <span style={{ width: '28px', height: '28px', borderRadius: '50%', background: isCancelled ? 'var(--danger)' : (!isCancelled ? 'var(--brand)' : 'var(--line)'), color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '13px', fontWeight: 600 }}>
              {isCancelled ? '✕' : (order.status !== 'Placed' ? '✓' : '2')}
            </span>
            <span style={{ fontSize: '12px', fontWeight: 500 }}>Processing</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', zIndex: 1 }}>
            <span style={{ width: '28px', height: '28px', borderRadius: '50%', background: (isInTransit || isDelivered) ? 'var(--brand)' : (isScheduled ? 'var(--surface-active, #c5d2e8)' : 'var(--line)'), color: (isInTransit || isDelivered) ? '#fff' : 'var(--ink)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '13px', fontWeight: 600 }}>
              {isDelivered ? '✓' : (isInTransit ? '➔' : (isScheduled ? '•' : '3'))}
            </span>
            <span style={{ fontSize: '12px', fontWeight: 500 }}>In Transit</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '6px', zIndex: 1 }}>
            <span style={{ width: '28px', height: '28px', borderRadius: '50%', background: isDelivered ? 'var(--brand)' : 'var(--line)', color: isDelivered ? '#fff' : 'var(--ink)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '13px', fontWeight: 600 }}>
              {isDelivered ? '✓' : '4'}
            </span>
            <span style={{ fontSize: '12px', fontWeight: 500 }}>Delivered</span>
          </div>
        </div>

        {/* Detailed Delivery Information */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', background: '#f6f8fa', padding: '16px', borderRadius: '8px' }}>
          <div>
            <span style={{ fontSize: '11px', color: 'var(--muted)', fontWeight: 600 }}>DELIVERY STATUS</span>
            <p style={{ margin: '4px 0 0', fontWeight: 600, fontSize: '14px' }}>{order.deliveryStatus}</p>
          </div>
          <div>
            <span style={{ fontSize: '11px', color: 'var(--muted)', fontWeight: 600 }}>SCHEDULED DATE</span>
            <p style={{ margin: '4px 0 0', fontWeight: 600, fontSize: '14px' }}>
              {order.deliveryDate ? formatDate(order.deliveryDate) : (order.delivery?.deliveryDate ? formatDate(order.delivery.deliveryDate) : 'Pending scheduling')}
            </p>
          </div>
          {order.delivery?.driverName && (
            <div>
              <span style={{ fontSize: '11px', color: 'var(--muted)', fontWeight: 600 }}>ASSIGNED DRIVER</span>
              <p style={{ margin: '4px 0 0', fontWeight: 600, fontSize: '14px' }}>{order.delivery.driverName}</p>
            </div>
          )}
          {order.delivery?.assistantName && (
            <div>
              <span style={{ fontSize: '11px', color: 'var(--muted)', fontWeight: 600 }}>ASSISTANT</span>
              <p style={{ margin: '4px 0 0', fontWeight: 600, fontSize: '14px' }}>{order.delivery.assistantName}</p>
            </div>
          )}
          {order.delivery?.truckRegistration && (
            <div>
              <span style={{ fontSize: '11px', color: 'var(--muted)', fontWeight: 600 }}>VEHICLE</span>
              <p style={{ margin: '4px 0 0', fontWeight: 600, fontSize: '14px' }}>{order.delivery.truckRegistration}</p>
            </div>
          )}
        </div>
      </div>

      {/* Line Items Card */}
      <div className="panel" style={{ padding: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
          <Package size={20} color="var(--brand)" />
          <h2 style={{ fontSize: '17px', margin: 0 }}>Order Line Items ({order.items.length})</h2>
        </div>

        <div className="table-scroll">
          <table>
            <thead>
              <tr>
                <th>#</th>
                <th>Product Name</th>
                <th>Unit Price</th>
                <th style={{ textAlign: 'center' }}>Quantity</th>
                <th className="align-right">Line Total</th>
              </tr>
            </thead>
            <tbody>
              {order.items.map((item, index) => (
                <tr key={item.orderDetailID ?? item.orderDetailId ?? index}>
                  <td>{index + 1}</td>
                  <td style={{ fontWeight: 600 }}>{item.productName}</td>
                  <td>{money(item.unitPrice)}</td>
                  <td style={{ textAlign: 'center' }}>{item.quantity.toLocaleString()}</td>
                  <td className="align-right" style={{ fontWeight: 600 }}>{money(item.lineTotal)}</td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr style={{ borderTop: '2px solid var(--line)' }}>
                <td colSpan={4} style={{ textAlign: 'right', fontWeight: 700, fontSize: '15px' }}>
                  Total Order Amount:
                </td>
                <td className="align-right" style={{ fontWeight: 700, fontSize: '16px', color: 'var(--brand)' }}>
                  {money(order.totalAmount)}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </section>
  );
}
