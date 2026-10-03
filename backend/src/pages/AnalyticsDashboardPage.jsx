import React, { useState, useEffect } from 'react';

const AnalyticsDashboardPage = () => {
  const [year, setYear] = useState(2026);
  const [quarter, setQuarter] = useState(1);
  const [quarterlyData, setQuarterlyData] = useState([]);
  const [topItems, setTopItems] = useState([]);
  const [geoSales, setGeoSales] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchReports = async () => {
    setLoading(true);
    try {
      const [qRes, topRes, geoRes] = await Promise.all([
        fetch(`http://localhost:8080/api/reports/quarterly-sales?year=${year}&quarter=${quarter}`),
        fetch(`http://localhost:8080/api/reports/top-items?year=${year}&quarter=${quarter}&limit=5`),
        fetch(`http://localhost:8080/api/reports/geographic-sales`),
      ]);

      setQuarterlyData(await qRes.json());
      setTopItems(await topRes.json());
      setGeoSales(await geoRes.json());
    } catch (err) {
      console.error('Error fetching reporting analytics:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReports();
  }, [year, quarter]);

  return (
    <div>
      <header style={{ marginBottom: '24px' }}>
        <h1 style={{ margin: 0, fontSize: '1.8rem', color: '#0f172a' }}>Executive Analytics Dashboard</h1>
        <p style={{ color: '#64748b' }}>High-level quarterly reports and operational analytics summary.</p>
      </header>

      {/* Filter Selector Bar */}
      <div style={{ display: 'flex', gap: '16px', marginBottom: '24px', background: '#fff', padding: '16px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
        <label>
          <strong>Select Year: </strong>
          <select value={year} onChange={(e) => setYear(Number(e.target.value))} style={{ padding: '6px 12px', marginLeft: '8px' }}>
            <option value={2025}>2025</option>
            <option value={2026}>2026</option>
          </select>
        </label>

        <label>
          <strong>Select Quarter: </strong>
          <select value={quarter} onChange={(e) => setQuarter(Number(e.target.value))} style={{ padding: '6px 12px', marginLeft: '8px' }}>
            <option value={1}>Quarter 1 (Q1)</option>
            <option value={2}>Quarter 2 (Q2)</option>
            <option value={3}>Quarter 3 (Q3)</option>
            <option value={4}>Quarter 4 (Q4)</option>
          </select>
        </label>
      </div>

      {loading ? (
        <p>Loading reports data...</p>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px' }}>
          {/* Quarterly Summary */}
          <div style={{ background: '#fff', padding: '20px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
            <h3 style={{ marginTop: 0, color: '#0369a1' }}>Quarterly Summary</h3>
            {quarterlyData.length === 0 ? (
              <p>No quarterly data available.</p>
            ) : (
              quarterlyData.map((item, idx) => (
                <div key={idx}>
                  <p><strong>Total Revenue:</strong> LKR {item.totalRevenue?.toLocaleString() || '0'}</p>
                  <p><strong>Orders Completed:</strong> {item.totalOrders || 0}</p>
                  <p><strong>Total Units Sold:</strong> {item.totalUnitsSold || 0}</p>
                </div>
              ))
            )}
          </div>

          {/* Top Selling Products */}
          <div style={{ background: '#fff', padding: '20px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
            <h3 style={{ marginTop: 0, color: '#0369a1' }}>Top Selling Products</h3>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid #e2e8f0' }}>
                  <th style={{ padding: '8px' }}>Product</th>
                  <th style={{ padding: '8px' }}>Quantity</th>
                  <th style={{ padding: '8px' }}>Revenue (LKR)</th>
                </tr>
              </thead>
              <tbody>
                {topItems.map((item) => (
                  <tr key={item.productId} style={{ borderBottom: '1px solid #f1f5f9' }}>
                    <td style={{ padding: '8px' }}>{item.productName}</td>
                    <td style={{ padding: '8px' }}>{item.totalQuantitySold}</td>
                    <td style={{ padding: '8px' }}>{item.totalRevenueGenerated?.toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Geographic Revenue Distribution */}
          <div style={{ background: '#fff', padding: '20px', borderRadius: '8px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', gridColumn: '1 / -1' }}>
            <h3 style={{ marginTop: 0, color: '#0369a1' }}>Geographic Sales Summary</h3>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '2px solid #e2e8f0' }}>
                  <th style={{ padding: '8px' }}>City / Region</th>
                  <th style={{ padding: '8px' }}>Delivered Orders</th>
                  <th style={{ padding: '8px' }}>Total Sales Value (LKR)</th>
                </tr>
              </thead>
              <tbody>
                {geoSales.map((item, idx) => (
                  <tr key={idx} style={{ borderBottom: '1px solid #f1f5f9' }}>
                    <td style={{ padding: '8px' }}>{item.city}</td>
                    <td style={{ padding: '8px' }}>{item.totalOrdersDelivered}</td>
                    <td style={{ padding: '8px' }}>{item.totalSalesValue?.toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default AnalyticsDashboardPage;