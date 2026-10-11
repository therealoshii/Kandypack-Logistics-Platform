
import { Link } from 'react-router-dom';

export default function CustomerOrdersPage() {
  return (
    <section>
      <p className="eyebrow">CUSTOMER PORTAL</p>
      <h1>My orders</h1>
      <p>Your orders will appear here.</p>
      <Link className="button button-primary" to="/portal/orders/new">Create a new order</Link>
    </section>
  );
}
