import { useEffect, useState } from 'react';
import { ArrowRight, Clock3, Plus, X } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { get, post } from '../../api';
import { dateString, formatDate, money, NoticeBanner } from '../../shared/ui';

interface PortalProduct {
  productID: number;
  productId?: number;
  productName: string;
  unitPrice: number;
  stockQuantity: number;
  stockStatus: string;
  category?: string;
}

interface OrderLine {
  productId: string;
  quantity: number;
}

export default function CustomerNewOrderPage() {
  const navigate = useNavigate();
  const [products, setProducts] = useState<PortalProduct[]>([]);
  // Default to 7 days ahead, but allow user selection
  const defaultDeliveryDate = dateString(new Date(Date.now() + 7 * 86_400_000));
  const [deliveryDate, setDeliveryDate] = useState(defaultDeliveryDate);
  const [items, setItems] = useState<OrderLine[]>([{ productId: '', quantity: 1 }]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    get<PortalProduct[]>('/api/portal/products')
      .then((data) => setProducts(data))
      .catch((error: unknown) => {
        setNotice({
          kind: 'error',
          text: error instanceof Error ? error.message : 'Could not load products catalog.',
        });
      })
      .finally(() => setLoading(false));
  }, []);

  const total = items.reduce((sum, item) => {
    const product = products.find((p) => String(p.productID ?? p.productId) === item.productId);
    return sum + (product?.unitPrice ?? 0) * (item.quantity || 0);
  }, 0);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitting(true);
    setNotice(null);

    const validItems = items
      .filter((line) => line.productId && line.quantity > 0)
      .map((line) => ({
        productId: Number(line.productId),
        quantity: Number(line.quantity),
      }));

    if (validItems.length === 0) {
      setNotice({ kind: 'error', text: 'Please add at least one product with a valid quantity.' });
      setSubmitting(false);
      return;
    }

    const payload = {
      deliveryDate,
      items: validItems,
    };

    try {
      const response = await post<{ success?: boolean; message?: string; orderId?: number }>(
        '/api/portal/orders',
        payload
      );
      setNotice({
        kind: 'success',
        text: response.message || `Order #${response.orderId ?? ''} placed successfully!`,
      });
      // Reset form
      setItems([{ productId: '', quantity: 1 }]);
      if (response.orderId) {
        setTimeout(() => {
          navigate(`/portal/orders/${response.orderId}`);
        }, 1500);
      }
    } catch (error) {
      setNotice({
        kind: 'error',
        text: error instanceof Error ? error.message : 'Order could not be placed.',
      });
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section>
      <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />

      <div style={{ marginBottom: '24px' }}>
        <p className="eyebrow">CUSTOMER PORTAL</p>
        <h1>New order</h1>
        <p>Select products and choose your requested delivery date. Minimum lead time is 7 days.</p>
      </div>

      <div className="order-layout">
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', flex: 1 }}>
          <form className="panel form-panel order-form" onSubmit={handleSubmit}>
            <div className="panel-heading">
              <div>
                <p className="eyebrow">ORDER DETAILS</p>
                <h2>Delivery date & items</h2>
              </div>
            </div>

            <label className="field-label">
              Requested delivery date <span>7+ days lead time required</span>
              <input
                type="date"
                required
                value={deliveryDate}
                onChange={(e) => setDeliveryDate(e.target.value)}
              />
            </label>

            <div className="line-items-heading">
              <div>
                <strong>Order items</strong>
                <span>Choose products and quantities</span>
              </div>
              <button
                className="button button-small button-quiet"
                type="button"
                onClick={() => setItems((curr) => [...curr, { productId: '', quantity: 1 }])}
              >
                <Plus size={15} /> Add item
              </button>
            </div>

            <div className="order-lines">
              {items.map((item, index) => {
                const product = products.find((p) => String(p.productID ?? p.productId) === item.productId);
                return (
                  <div className="order-line" key={`portal-item-${index}`}>
                    <span className="line-index">{String(index + 1).padStart(2, '0')}</span>
                    <select
                      required
                      aria-label={`Product for line ${index + 1}`}
                      value={item.productId}
                      onChange={(e) =>
                        setItems((curr) =>
                          curr.map((line, i) => (i === index ? { ...line, productId: e.target.value } : line))
                        )
                      }
                    >
                      <option value="">Select product</option>
                      {products.map((p) => {
                        const id = p.productID ?? p.productId;
                        return (
                          <option key={id} value={id}>
                            {p.productName} · {money(p.unitPrice)} ({p.stockStatus ?? `${p.stockQuantity} in stock`})
                          </option>
                        );
                      })}
                    </select>

                    <input
                      aria-label={`Quantity for line ${index + 1}`}
                      type="number"
                      min="1"
                      max={product?.stockQuantity || undefined}
                      value={item.quantity}
                      onChange={(e) =>
                        setItems((curr) =>
                          curr.map((line, i) => (i === index ? { ...line, quantity: Number(e.target.value) } : line))
                        )
                      }
                    />

                    <button
                      type="button"
                      className="icon-button remove-line"
                      aria-label="Remove order line"
                      disabled={items.length === 1}
                      onClick={() => setItems((curr) => curr.filter((_, i) => i !== index))}
                    >
                      <X size={16} />
                    </button>
                  </div>
                );
              })}
            </div>

            <div className="form-footer">
              <span>
                Estimated order value<strong>{money(total)}</strong>
              </span>
              <button
                className="button button-primary"
                type="submit"
                disabled={submitting || loading || !products.length}
              >
                {submitting ? 'Submitting…' : 'Submit order'}
                <ArrowRight size={16} />
              </button>
            </div>
          </form>
        </div>

        <aside className="order-aside">
          <div className="order-note order-note-light">
            <div className="note-icon note-icon-coral">
              <Clock3 size={19} />
            </div>
            <p className="eyebrow">DELIVERY WINDOW</p>
            <h3>7-Day Advance Notice</h3>
            <p>Orders must be placed at least seven days before the requested delivery date.</p>
            <span className="date-preview">
              Recommended earliest date <strong>{formatDate(defaultDeliveryDate)}</strong>
            </span>
          </div>

          <Link className="text-button" to="/portal">
            <ArrowRight size={14} style={{ transform: 'rotate(180deg)' }} /> Back to My Orders
          </Link>
        </aside>
      </div>
    </section>
  );
}
