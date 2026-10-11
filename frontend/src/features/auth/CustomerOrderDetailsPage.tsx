
import { useParams } from 'react-router-dom';

export default function CustomerOrderDetailsPage() {
  const { id } = useParams();

  return (
    <section>
      <p className="eyebrow">CUSTOMER PORTAL</p>
      <h1>Order details</h1>
      <p>Details for order {id} will appear here.</p>
    </section>
  );
}
