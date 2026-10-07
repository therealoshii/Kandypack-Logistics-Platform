import { useEffect, useState } from 'react';
import { Boxes, Package, Plus, Users, X } from 'lucide-react';
import { Link } from 'react-router-dom';
import { get, post, remove } from '../../api';
import type { Customer, Product } from '../../types';
import { EmptyState, Modal, NoticeBanner, money } from '../../shared/ui';

export default function CatalogPage() {
  const [tab, setTab] = useState<'products' | 'customers'>('products');
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [adding, setAdding] = useState(false);
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState<{ kind: 'success' | 'error'; text: string } | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    Promise.all([get<Customer[]>('/api/customers'), get<Product[]>('/api/products')])
      .then(([customerRows, productRows]) => { setCustomers(customerRows); setProducts(productRows); })
      .catch((error: unknown) => setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Catalog could not be loaded.' }));
  }, [reloadKey]);

  async function run(operation: () => Promise<unknown>, successText: string) {
    setNotice(null);
    try { await operation(); setNotice({ kind: 'success', text: successText }); setReloadKey((value) => value + 1); return true; }
    catch (error) { setNotice({ kind: 'error', text: error instanceof Error ? error.message : 'Request failed.' }); return false; }
  }

  async function createRecord(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setSaving(true);
    const form = new FormData(event.currentTarget);
    const payload = tab === 'products'
      ? { productName: String(form.get('productName')), unitPrice: Number(form.get('unitPrice')), spaceConsumption: Number(form.get('spaceConsumption')), stockQuantity: Number(form.get('stockQuantity')), category: String(form.get('category')) }
      : { fullName: String(form.get('fullName')), email: String(form.get('email')), contactNumber: String(form.get('contactNumber')), address: String(form.get('address')), city: String(form.get('city')), username: String(form.get('username')), password: String(form.get('password')) };
    const ok = await run(() => post(`/api/${tab}`, payload), `${tab === 'products' ? 'Product' : 'Customer'} created.`);
    setSaving(false); if (ok) setAdding(false);
  }

  return <>
    <NoticeBanner notice={notice} onDismiss={() => setNotice(null)} />
    <div className="page-heading"><div><p className="eyebrow">HANEEF / CUSTOMER & ORDERS</p><h1>Customers & stock</h1><p className="page-description">Maintain the customer directory and inventory catalog used in order placement.</p></div><div className="heading-action"><Link to="/orders/new" className="button button-secondary">Order placement</Link><button className="button button-primary" onClick={() => setAdding(true)}><Plus size={16} /> Add {tab === 'products' ? 'product' : 'customer'}</button></div></div>
    <div className="catalog-toolbar"><div className="segmented-control" role="tablist" aria-label="Customer and stock records"><button role="tab" aria-selected={tab === 'products'} className={tab === 'products' ? 'segment-active' : ''} onClick={() => setTab('products')}><Boxes size={15} /> Products <span>{products.length}</span></button><button role="tab" aria-selected={tab === 'customers'} className={tab === 'customers' ? 'segment-active' : ''} onClick={() => setTab('customers')}><Users size={15} /> Customers <span>{customers.length}</span></button></div></div>
    {tab === 'products' ? <section className="panel table-panel"><div className="panel-heading"><div><p className="eyebrow">INVENTORY CATALOG</p><h2>Products</h2></div><span className="count-chip"><Package size={15} /> {products.reduce((sum, product) => sum + product.stockQuantity, 0).toLocaleString()} units</span></div>{products.length ? <div className="table-scroll"><table><thead><tr><th>Product</th><th>Category</th><th>Unit price</th><th>Space / unit</th><th>Available stock</th><th /></tr></thead><tbody>{products.map((product) => <tr key={product.productID}><td><span className="primary-cell">{product.productName}</span><span className="sub-cell">SKU #{product.productID}</span></td><td><span className="category-tag">{product.category}</span></td><td>{money(product.unitPrice)}</td><td>{product.spaceConsumption}</td><td><StockLevel value={product.stockQuantity} /></td><td className="align-right"><button className="icon-button delete-quiet" aria-label={`Delete ${product.productName}`} onClick={() => { if (window.confirm(`Delete ${product.productName}?`)) void run(() => remove(`/api/products/${product.productID}`), 'Product removed.'); }}><X size={15} /></button></td></tr>)}</tbody></table></div> : <EmptyState icon={Boxes} title="No products found" text="The product catalog is empty or unavailable." />}</section> : <section className="panel table-panel"><div className="panel-heading"><div><p className="eyebrow">REGISTERED ACCOUNTS</p><h2>Customer directory</h2></div><span className="count-chip"><Users size={15} /> {customers.length} customers</span></div>{customers.length ? <div className="table-scroll"><table><thead><tr><th>Customer</th><th>Location</th><th>Contact</th><th>Account</th><th /></tr></thead><tbody>{customers.map((customer) => <tr key={customer.customerID}><td><span className="primary-cell">{customer.fullName}</span><span className="sub-cell">{customer.email}</span></td><td>{customer.city}<span className="sub-cell">{customer.address}</span></td><td>{customer.contactNumber}</td><td><span className="secondary-cell">{customer.username}</span></td><td className="align-right"><button className="icon-button delete-quiet" aria-label={`Delete ${customer.fullName}`} onClick={() => { if (window.confirm(`Delete ${customer.fullName}? Existing orders may prevent removal.`)) void run(() => remove(`/api/customers/${customer.customerID}`), 'Customer removed.'); }}><X size={15} /></button></td></tr>)}</tbody></table></div> : <EmptyState icon={Users} title="No customers found" text="Customer records will appear here when available." />}</section>}
    {adding && <Modal title={`Add ${tab === 'products' ? 'product' : 'customer'}`} onClose={() => setAdding(false)}><form className="modal-form" onSubmit={createRecord}>{tab === 'products' ? <><label className="field-label">Product name<input name="productName" required maxLength={100} /></label><div className="field-row"><label className="field-label">Unit price (LKR)<input name="unitPrice" type="number" min="0" step="0.01" required /></label><label className="field-label">Space consumption<input name="spaceConsumption" type="number" min="0.01" step="0.01" required /></label></div><div className="field-row"><label className="field-label">Opening stock<input name="stockQuantity" type="number" min="0" required /></label><label className="field-label">Category<input name="category" required maxLength={50} /></label></div></> : <><label className="field-label">Customer name<input name="fullName" required maxLength={100} /></label><div className="field-row"><label className="field-label">Email<input name="email" type="email" required maxLength={100} /></label><label className="field-label">Phone<input name="contactNumber" required maxLength={15} /></label></div><label className="field-label">Address<input name="address" required maxLength={200} /></label><div className="field-row"><label className="field-label">City<input name="city" required maxLength={50} /></label><label className="field-label">Username<input name="username" required maxLength={50} /></label></div><label className="field-label">Password<input name="password" type="password" required autoComplete="new-password" /></label></>}<div className="modal-actions"><button type="button" className="button button-secondary" onClick={() => setAdding(false)}>Cancel</button><button className="button button-primary" disabled={saving}>{saving ? 'Saving…' : 'Create record'}</button></div></form></Modal>}
  </>;
}

function StockLevel({ value }: { value: number }) {
  const state = value < 100 ? 'low' : value < 1000 ? 'watch' : 'healthy';
  return <span className={`stock-level stock-${state}`}><i />{value.toLocaleString()} <small>{state}</small></span>;
}
