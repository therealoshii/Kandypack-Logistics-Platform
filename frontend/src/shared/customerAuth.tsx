
import { createContext, useContext, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { api, ApiError } from '../api';

export interface CustomerProfile {
  customerID: number;
  fullName: string;
  username: string;
  email: string;
}

interface CustomerAuthValue {
  customer: CustomerProfile | null;
  loading: boolean;
  login: (username: string, password: string) => Promise<CustomerProfile>;
  logout: () => Promise<void>;
}

const CustomerAuthContext = createContext<CustomerAuthValue | null>(null);

export function CustomerAuthProvider({ children }: { children: ReactNode }) {
  const [customer, setCustomer] = useState<CustomerProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api<CustomerProfile>('/api/auth/customer/me')
      .then(setCustomer)
      .catch((error: unknown) => {
        if (!(error instanceof ApiError) ||
            (error.status !== 401 && error.status !== 403)) {
          console.error('Could not restore customer session', error);
        }
        setCustomer(null);
      })
      .finally(() => setLoading(false));
  }, []);

  async function login(username: string, password: string) {
    const profile = await api<CustomerProfile>('/api/auth/customer/login', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    });

    setCustomer(profile);
    return profile;
  }

  async function logout() {
    try {
      await api<void>('/api/auth/logout', { method: 'POST' });
    } finally {
      setCustomer(null);
    }
  }

  return (
    <CustomerAuthContext.Provider value={{ customer, loading, login, logout }}>
      {children}
    </CustomerAuthContext.Provider>
  );
}

export function useCustomerAuth() {
  const context = useContext(CustomerAuthContext);

  if (!context) {
    throw new Error('useCustomerAuth must be used inside CustomerAuthProvider.');
  }

  return context;
}
