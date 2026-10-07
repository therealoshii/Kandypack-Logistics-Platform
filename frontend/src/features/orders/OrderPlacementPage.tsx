import { useEffect, useState } from 'react';
import { ArrowRight, Boxes, Clock3, Plus, Route, X } from 'lucide-react';
import { get, post } from '../../api';
import type { Customer, Product } from '../../types';
import { dateString, formatDate, money, NoticeBanner, PageHeading } from '../../shared/ui';
import { Link } from 'react-router-dom';

export default function OrderPlacementPage() {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [customerId, setCustomerId] = useState('');
  const [deliveryDate, setDeliveryDate] = useState(dateString(new Date(Date.now() + 7 * 86_400_000)));
  const [items, setItems] = useState([{ productId: '', quantity: 1 }]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const minDate = dateString(new Date(Date.now() + 7 * 86_400_000));

  useEffect(() => {
    Promise.all([get<Customer[]>('/api/customers'), get<Product[]>('/api/products')])
      .then(([customerRows, productRows]) => { setCustomers(customerRows); setProducts(productRows); })
      .catch((error: unknown) => setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Could not load customers and products.' }))
      .finally(() => setLoading(false));
  }, []);

  const total = items.reduce((sum, item) => sum + (products.find((product) => String(product.productID) === item.productId)?.unitPrice ?? 0) * item.quantity, 0);

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitting(true);
    setNotice(null);
    const payload = {
      customerID: Number(customerId),
      deliveryDate,
      items: items.filter((item) => item.productId && item.quantity > 0).map((item) => ({ productId: Number(item.productId), quantity: Number(item.quantity) })),
    };
    try {
      const response = await post<{ message?: string; orderId?: number }>('/api/orders', payload);
      setNotice({ kind: 'success', text: response.message || `Order #${response.orderId ?? ''} placed successfully.` });
      setItems([{ productId: '', quantity: 1 }]);
    } catch (error) {
      setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Order could not be placed.' });
    } finally {
      setSubmitting(false);
    }
  }

  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <PageHeading eyebrow="HANEEF / CUSTOMER & ORDERS" title="Order placement" description="Create an order for a registered customer. Route assignment and inventory checks are handled by the order procedure." action={<span className="rule-chip"><Clock3 size={15} /> 7-day lead time</span>} />
    <div className="order-layout">
      <form className="panel form-panel order-form" onSubmit={submit}>
        <div className="panel-heading"><div><p className="eyebrow">NEW CUSTOMER ORDER</p><h2>Order details</h2></div><span className="step-number">01 <i>/ 02</i></span></div>
        <label className="field-label">Customer <span>Required</span><select required value={customerId} onChange={(event) => setCustomerId(event.target.value)}><option value="">Select a registered customer</option>{customers.map((customer) => <option key={customer.customerID} value={customer.customerID}>{customer.fullName} · {customer.city}</option>)}</select></label>
        <label className="field-label">Requested delivery date <span>7+ days ahead</span><input type="date" min={minDate} required value={deliveryDate} onChange={(event) => setDeliveryDate(event.target.value)} /></label>
        <div className="line-items-heading"><div><strong>Order items</strong><span>Choose products and quantities</span></div><button className="button button-small button-quiet" type="button" onClick={() => setItems((current) => [...current, { productId: '', quantity: 1 }])}><Plus size={15} /> Add item</button></div>
        <div className="order-lines">{items.map((item, index) => {
          const product = products.find((entry) => String(entry.productID) === item.productId);
          return <div className="order-line" key={`line-${index}`}><span className="line-index">{String(index + 1).padStart(2, '0')}</span><select required aria-label={`Product for line ${index + 1}`} value={item.productId} onChange={(event) => setItems((current) => current.map((line, lineIndex) => lineIndex === index ? { ...line, productId: event.target.value } : line))}><option value="">Select product</option>{products.map((entry) => <option key={entry.productID} value={entry.productID}>{entry.productName} · {entry.stockQuantity.toLocaleString()} in stock</option>)}</select><input aria-label={`Quantity for line ${index + 1}`} type="number" min="1" max={product?.stockQuantity || undefined} value={item.quantity} onChange={(event) => setItems((current) => current.map((line, lineIndex) => lineIndex === index ? { ...line, quantity: Number(event.target.value) } : line))} /><button type="button" className="icon-button remove-line" aria-label="Remove order line" disabled={items.length === 1} onClick={() => setItems((current) => current.filter((_, lineIndex) => lineIndex !== index))}><X size={16} /></button></div>;
        })}</div>
        <div className="form-footer"><span>Estimated order value<strong>{money(total)}</strong></span><button className="button button-primary" type="submit" disabled={submitting || loading || !customers.length || !products.length}>{submitting ? 'Submitting…' : 'Submit order'}<ArrowRight size={16} /></button></div>
      </form>
      <aside className="order-aside"><div className="order-note"><div className="note-icon"><Route size={19} /></div><p className="eyebrow">ROUTE MATCHING</p><h3>Handled automatically</h3><p>The registered customer city determines the route. No manual hub selection is needed.</p><div className="note-rule">✓ City-based route allocation</div></div><div className="order-note order-note-light"><div className="note-icon note-icon-coral"><Clock3 size={19} /></div><p className="eyebrow">DELIVERY WINDOW</p><h3>Plan a week ahead</h3><p>Orders must be placed at least seven days before the requested delivery date.</p><span className="date-preview">Earliest date <strong>{formatDate(minDate)}</strong></span></div><Link className="text-button" to="/orders/catalog"><Boxes size={15} /> Manage customers & products <ArrowRight size={14} /></Link><div className="muted-callout">Order history is not exposed by the current backend API.</div></aside>
    </div>
  </>;
}
