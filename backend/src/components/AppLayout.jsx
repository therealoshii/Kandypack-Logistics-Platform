import React from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';

const AppLayout = () => {
  const location = useLocation();

  const navItems = [
    { label: 'Analytics Dashboard', path: '/' },
    { label: 'Order Placement', path: '/orders' },
    { label: 'Train & Rail Cargo', path: '/rail' },
    { label: 'Fleet Management', path: '/fleet' },
    { label: 'Roster & Dispatch', path: '/roster' },
  ];

  return (
    <div style={{ display: 'flex', minHeight: '100vh', fontFamily: 'Segoe UI, sans-serif' }}>
      {/* Sidebar */}
      <aside style={{ width: '250px', backgroundColor: '#1e293b', color: '#fff', padding: '20px' }}>
        <h2 style={{ fontSize: '1.2rem', marginBottom: '2rem', color: '#38bdf8' }}>
          Kandypack Logistics
        </h2>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {navItems.map((item) => {
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                style={{
                  padding: '10px 14px',
                  borderRadius: '6px',
                  textDecoration: 'none',
                  color: isActive ? '#fff' : '#94a3b8',
                  backgroundColor: isActive ? '#0284c7' : 'transparent',
                  fontWeight: isActive ? '600' : '400',
                }}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </aside>

      {/* Main Content Body */}
      <main style={{ flex: 1, backgroundColor: '#f8fafc', padding: '32px' }}>
        <Outlet />
      </main>
    </div>
  );
};

export default AppLayout;