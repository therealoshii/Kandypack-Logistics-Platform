import { createContext, useContext, useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { api, ApiError } from '../api';

export interface StaffProfile {
  id: number;
  name: string;
  username: string;
  email: string;
  roles: string[];
}

type AuthContextValue = {
  user: StaffProfile | null;
  loading: boolean;
  login: (username: string, password: string) => Promise<StaffProfile>;
  logout: () => Promise<void>;
  hasRole: (...roles: string[]) => boolean;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<StaffProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api<StaffProfile>('/api/auth/me')
      .then(setUser)
      .catch((error: unknown) => {
        if (!(error instanceof ApiError) || error.status !== 401) console.error('Could not restore staff session', error);
        setUser(null);
      })
      .finally(() => setLoading(false));
  }, []);

  async function login(username: string, password: string) {
    const profile = await api<StaffProfile>('/api/auth/login', {
      method: 'POST', body: JSON.stringify({ username, password }),
    });
    setUser(profile);
    return profile;
  }

  async function logout() {
    try { await api<void>('/api/auth/logout', { method: 'POST' }); }
    finally { setUser(null); }
  }

  const value: AuthContextValue = {
    user,
    loading,
    login,
    logout,
    hasRole: (...roles) => Boolean(user && roles.some((role) => user.roles.includes(role))),
  };
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used inside AuthProvider.');
  return context;
}
