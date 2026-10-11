
import { UserRound } from 'lucide-react';
import { useCustomerAuth } from '../../shared/customerAuth';

export default function CustomerProfilePage() {
  const { customer } = useCustomerAuth();

  if (!customer) {
    return <p>Customer information is unavailable.</p>;
  }

  return (
    <section className="login-panel">
      <div className="login-icon"><UserRound size={19} /></div>
      <p className="eyebrow">YOUR ACCOUNT</p>
      <h1>Profile</h1>
      <p className="login-description">Your customer account information.</p>

      <div className="field-label">Customer ID<p>{customer.customerID}</p></div>
      <div className="field-label">Full name<p>{customer.fullName}</p></div>
      <div className="field-label">Username<p>{customer.username}</p></div>
      <div className="field-label">Email<p>{customer.email}</p></div>
    </section>
  );
}
