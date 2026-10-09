import { useEffect, useState } from 'react';
import { Download, FileDown, FileText } from 'lucide-react';
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { downloadReportPdf, get } from '../../api';
import type { Customer } from '../../types';
import { EmptyState, LoadingState, money, PageHeading } from '../../shared/ui';

type ReportKind = 'quarterly' | 'top-items' | 'geographic' | 'working-hours' | 'fleet' | 'customer-history';
type ReportRow = Record<string, string | number | null>;

const reportTabs: { key: ReportKind; label: string; eyebrow: string; description: string }[] = [
  {
    key: 'quarterly',
    label: '1. Quarterly sales',
    eyebrow: 'SALES PERFORMANCE',
    description: 'Quarterly sales revenue, unit counts, and rail/cargo space volume consumption.',
  },
  {
    key: 'top-items',
    label: '2. Top ordered items',
    eyebrow: 'PRODUCT DEMAND',
    description: 'Most frequently ordered products and high-revenue catalog items in a given quarter.',
  },
  {
    key: 'geographic',
    label: '3. City & route breakdown',
    eyebrow: 'GEOGRAPHIC LOGISTICS',
    description: 'Sales volumes and order totals broken down by destination city and delivery route.',
  },
  {
    key: 'working-hours',
    label: '4. Staff working hours',
    eyebrow: 'CREW COMPLIANCE',
    description: 'Trips completed and duty hours worked for drivers (40h limit) and assistants (60h limit).',
  },
  {
    key: 'fleet',
    label: '5. Truck usage analysis',
    eyebrow: 'FLEET UTILIZATION',
    description: 'Monthly vehicle trips, engine operating hours, and odometer mileage by store hub.',
  },
  {
    key: 'customer-history',
    label: '6. Customer order history',
    eyebrow: 'CUSTOMER FULFILLMENT',
    description: 'End-to-end customer order history with delivery statuses, assigned crew, and truck details.',
  },
];

function humanize(value: string) {
  return value
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .replaceAll('_', ' ')
    .replace(/^./, (letter) => letter.toUpperCase());
}

function formatCell(key: string, value: string | number | null): string {
  if (value === null || value === undefined || value === '') return '—';
  if (typeof value === 'number') {
    const lowerKey = key.toLowerCase();
    if (lowerKey.includes('revenue') || lowerKey.includes('sales') || lowerKey.includes('amount') || lowerKey.includes('price') || lowerKey.includes('totallkr')) {
      return money(value);
    }
    if (lowerKey.includes('hours')) {
      return `${value.toFixed(2)} hrs`;
    }
    if (lowerKey.includes('mileage') || lowerKey.includes('distance')) {
      return `${value.toFixed(1)} km`;
    }
    if (lowerKey.includes('volumespace')) {
      return `${value.toFixed(2)} m³`;
    }
    return value.toLocaleString();
  }
  return String(value);
}

export default function ReportsPage() {
  const now = new Date();
  const [kind, setKind] = useState<ReportKind>('quarterly');
  const [year, setYear] = useState(String(now.getFullYear()));
  const [quarter, setQuarter] = useState(String(Math.floor(now.getMonth() / 3) + 1));
  const [month, setMonth] = useState(String(now.getMonth() + 1));
  const [limit, setLimit] = useState('10');
  const [customerId, setCustomerId] = useState('');
  const [startDate, setStartDate] = useState(new Date(now.getFullYear(), 0, 1).toISOString().slice(0, 10));
  const [endDate, setEndDate] = useState(now.toISOString().slice(0, 10));

  const [customers, setCustomers] = useState<Customer[]>([]);
  const [rows, setRows] = useState<ReportRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingPdf, setLoadingPdf] = useState(false);
  const [error, setError] = useState('');

  // Load customer list for dropdown
  useEffect(() => {
    get<Customer[]>('/api/customers')
      .then(setCustomers)
      .catch(() => {
        // Fallback gracefully if user role cannot read /api/customers directly
      });
  }, []);

  function getReportJsonPath(): string {
    if (kind === 'quarterly') {
      const q = quarter ? `&quarter=${quarter}` : '';
      return `/api/reports/quarterly-sales?year=${year}${q}`;
    }
    if (kind === 'top-items') {
      return `/api/reports/top-items?year=${year}&quarter=${quarter}&limit=${limit}`;
    }
    if (kind === 'geographic') {
      return `/api/reports/geographic-sales?startDate=${startDate}&endDate=${endDate}`;
    }
    if (kind === 'working-hours') {
      return `/api/reports/working-hours?startDate=${startDate}&endDate=${endDate}`;
    }
    if (kind === 'fleet') {
      return `/api/reports/fleet-usage?year=${year}&month=${month}`;
    }
    if (kind === 'customer-history') {
      const c = customerId ? `?customerId=${customerId}` : '';
      return `/api/reports/customer-order-history${c}`;
    }
    return '';
  }

  function getReportPdfPath(): string {
    if (kind === 'quarterly') {
      const q = quarter ? `&quarter=${quarter}` : '';
      return `/api/reports/quarterly-sales/pdf?year=${year}${q}`;
    }
    if (kind === 'top-items') {
      return `/api/reports/top-items/pdf?year=${year}&quarter=${quarter}&limit=${limit}`;
    }
    if (kind === 'geographic') {
      return `/api/reports/geographic-sales/pdf?startDate=${startDate}&endDate=${endDate}`;
    }
    if (kind === 'working-hours') {
      return `/api/reports/working-hours/pdf?startDate=${startDate}&endDate=${endDate}`;
    }
    if (kind === 'fleet') {
      return `/api/reports/fleet-usage/pdf?year=${year}&month=${month}`;
    }
    if (kind === 'customer-history') {
      const c = customerId ? `?customerId=${customerId}` : '';
      return `/api/reports/customer-order-history/pdf${c}`;
    }
    return '';
  }

  async function loadReport(event?: React.FormEvent) {
    event?.preventDefault();
    setLoading(true);
    setError('');
    const path = getReportJsonPath();
    try {
      setRows(await get<ReportRow[]>(path));
    } catch (failure) {
      setRows([]);
      setError(failure instanceof Error ? failure.message : 'Report could not be loaded.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadReport();
  }, [kind]);

  async function exportPdf() {
    if (!rows.length) return;
    setLoadingPdf(true);
    setError('');
    const path = getReportPdfPath();
    const filename = `kandypack-${kind}-${new Date().toISOString().slice(0, 10)}.pdf`;
    try {
      await downloadReportPdf(path, filename);
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : 'Failed to download report PDF.');
    } finally {
      setLoadingPdf(false);
    }
  }

  function exportCsv() {
    if (!rows.length) return;
    const headers = Object.keys(rows[0]);
    const content = [
      headers.join(','),
      ...rows.map((row) =>
        headers.map((header) => `"${String(row[header] ?? '').replaceAll('"', '""')}"`).join(',')
      ),
    ].join('\n');
    const url = URL.createObjectURL(new Blob([content], { type: 'text/csv' }));
    const link = document.createElement('a');
    link.href = url;
    link.download = `kandypack-${kind}-${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  }

  const activeTab = reportTabs.find((tab) => tab.key === kind);

  // Prepare chart data where applicable
  const chartData = rows.map((row) => {
    let label = '';
    let val = 0;
    if (kind === 'top-items') {
      label = String(row.productName ?? '');
      val = Number(row.totalRevenueGenerated ?? row.totalQuantitySold ?? 0);
    } else if (kind === 'geographic') {
      label = row.routeName ? `${row.city} (${row.routeName})` : String(row.city ?? '');
      val = Number(row.totalSales ?? 0);
    } else if (kind === 'fleet') {
      label = String(row.registrationNumber ?? '');
      val = Number(row.operatingHours ?? 0);
    } else if (kind === 'quarterly') {
      label = `Q${row.quarter} ${row.year}`;
      val = Number(row.totalRevenue ?? 0);
    } else if (kind === 'working-hours') {
      label = String(row.staffName ?? '');
      val = Number(row.totalHoursWorked ?? 0);
    }
    return { label, value: val };
  }).filter((item) => item.label && item.value > 0).slice(0, 12);

  const isChartReport = ['top-items', 'geographic', 'fleet', 'working-hours'].includes(kind);

  return (
    <>
      <PageHeading
        eyebrow="MANAGEMENT REPORTING & COMPLIANCE"
        title="Reports & Analytics"
        description="Comprehensive FMCG logistics management reports with official PDF and CSV export."
        action={
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              className="button button-primary"
              onClick={exportPdf}
              disabled={loadingPdf || !rows.length}
              title="Download formatted PDF report"
            >
              <FileDown size={16} /> {loadingPdf ? 'Generating PDF…' : 'Export PDF'}
            </button>
            <button
              className="button button-secondary"
              onClick={exportCsv}
              disabled={!rows.length}
              title="Download CSV spreadsheet"
            >
              <Download size={16} /> Export CSV
            </button>
          </div>
        }
      />

      <div className="segmented-control report-tabs" role="tablist" aria-label="Report type">
        {reportTabs.map((tab) => (
          <button
            role="tab"
            aria-selected={kind === tab.key}
            className={kind === tab.key ? 'segment-active' : ''}
            key={tab.key}
            onClick={() => setKind(tab.key)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <section className="panel report-panel">
        <div className="report-toolbar">
          <div>
            <p className="eyebrow">{activeTab?.eyebrow}</p>
            <h2>{activeTab?.label}</h2>
            <small style={{ color: '#7a877f', display: 'block', marginTop: '2px' }}>
              {activeTab?.description}
            </small>
          </div>

          <form className="report-filters" onSubmit={loadReport}>
            {/* Filters for Quarterly & Top Items */}
            {['quarterly', 'top-items'].includes(kind) && (
              <>
                <label>
                  Year
                  <input
                    type="number"
                    min="2000"
                    max="2100"
                    value={year}
                    onChange={(e) => setYear(e.target.value)}
                  />
                </label>
                <label>
                  Quarter
                  <select value={quarter} onChange={(e) => setQuarter(e.target.value)}>
                    {kind === 'quarterly' && <option value="">All quarters</option>}
                    <option value="1">Q1 (Jan–Mar)</option>
                    <option value="2">Q2 (Apr–Jun)</option>
                    <option value="3">Q3 (Jul–Sep)</option>
                    <option value="4">Q4 (Oct–Dec)</option>
                  </select>
                </label>
                {kind === 'top-items' && (
                  <label>
                    Limit
                    <select value={limit} onChange={(e) => setLimit(e.target.value)}>
                      <option value="5">Top 5</option>
                      <option value="10">Top 10</option>
                      <option value="20">Top 20</option>
                      <option value="50">Top 50</option>
                    </select>
                  </label>
                )}
              </>
            )}

            {/* Filters for Geographic & Working Hours */}
            {['geographic', 'working-hours'].includes(kind) && (
              <>
                <label>
                  From
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                  />
                </label>
                <label>
                  To
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                  />
                </label>
              </>
            )}

            {/* Filters for Fleet Usage */}
            {kind === 'fleet' && (
              <>
                <label>
                  Year
                  <input
                    type="number"
                    min="2000"
                    max="2100"
                    value={year}
                    onChange={(e) => setYear(e.target.value)}
                  />
                </label>
                <label>
                  Month
                  <select value={month} onChange={(e) => setMonth(e.target.value)}>
                    <option value="1">1 - January</option>
                    <option value="2">2 - February</option>
                    <option value="3">3 - March</option>
                    <option value="4">4 - April</option>
                    <option value="5">5 - May</option>
                    <option value="6">6 - June</option>
                    <option value="7">7 - July</option>
                    <option value="8">8 - August</option>
                    <option value="9">9 - September</option>
                    <option value="10">10 - October</option>
                    <option value="11">11 - November</option>
                    <option value="12">12 - December</option>
                  </select>
                </label>
              </>
            )}

            {/* Filters for Customer Order History */}
            {kind === 'customer-history' && (
              <label style={{ minWidth: '180px' }}>
                Customer
                <select value={customerId} onChange={(e) => setCustomerId(e.target.value)}>
                  <option value="">All customers</option>
                  {customers.map((c) => (
                    <option key={c.customerID} value={String(c.customerID)}>
                      #{c.customerID} - {c.fullName}
                    </option>
                  ))}
                </select>
              </label>
            )}

            <button className="button button-primary button-small" disabled={loading}>
              {loading ? 'Loading…' : 'Run report'}
            </button>
          </form>
        </div>

        {error && <div className="inline-feedback">{error}</div>}

        {loading ? (
          <LoadingState label="Building report" />
        ) : rows.length ? (
          <>
            {/* Stat Cards for Quarterly Sales */}
            {kind === 'quarterly' && (
              <div className="report-stat-grid" style={{ marginBottom: '16px' }}>
                <div className="report-stat">
                  <span>Total revenue (LKR)</span>
                  <strong>{money(rows.reduce((sum, r) => sum + Number(r.totalRevenue ?? 0), 0))}</strong>
                  <small>{rows.length} quarter period(s)</small>
                </div>
                <div className="report-stat">
                  <span>Orders processed</span>
                  <strong>{rows.reduce((sum, r) => sum + Number(r.totalOrders ?? 0), 0).toLocaleString()}</strong>
                  <small>Across FMCG network</small>
                </div>
                <div className="report-stat">
                  <span>Units & Volume space</span>
                  <strong>{rows.reduce((sum, r) => sum + Number(r.totalUnitsSold ?? 0), 0).toLocaleString()} units</strong>
                  <small>
                    Total Volume: {rows.reduce((sum, r) => sum + Number(r.totalVolumeSpace ?? 0), 0).toFixed(2)} m³
                  </small>
                </div>
              </div>
            )}

            {/* Stat Cards for Fleet Usage */}
            {kind === 'fleet' && (
              <div className="report-stat-grid" style={{ marginBottom: '16px' }}>
                <div className="report-stat">
                  <span>Fleet vehicles active</span>
                  <strong>{rows.length}</strong>
                  <small>Across regional depots</small>
                </div>
                <div className="report-stat">
                  <span>Total trips dispatched</span>
                  <strong>{rows.reduce((sum, r) => sum + Number(r.totalTrips ?? 0), 0).toLocaleString()}</strong>
                  <small>Month {month} / {year}</small>
                </div>
                <div className="report-stat">
                  <span>Operating hours & Mileage</span>
                  <strong>{rows.reduce((sum, r) => sum + Number(r.operatingHours ?? 0), 0).toFixed(1)} hrs</strong>
                  <small>
                    Total Mileage: {rows.reduce((sum, r) => sum + Number(r.totalMileage ?? 0), 0).toFixed(1)} km
                  </small>
                </div>
              </div>
            )}

            {/* Stat Cards for Staff Hours */}
            {kind === 'working-hours' && (
              <div className="report-stat-grid" style={{ marginBottom: '16px' }}>
                <div className="report-stat">
                  <span>Staff members</span>
                  <strong>{rows.length}</strong>
                  <small>Drivers and assistants</small>
                </div>
                <div className="report-stat">
                  <span>Trips completed</span>
                  <strong>{rows.reduce((sum, r) => sum + Number(r.totalTripsCompleted ?? 0), 0).toLocaleString()}</strong>
                  <small>Reporting timeframe</small>
                </div>
                <div className="report-stat">
                  <span>Total hours worked</span>
                  <strong>{rows.reduce((sum, r) => sum + Number(r.totalHoursWorked ?? 0), 0).toFixed(2)} hrs</strong>
                  <small>Driver limit: 40h · Assistant: 60h</small>
                </div>
              </div>
            )}

            {/* Visual Chart if applicable */}
            {isChartReport && chartData.length > 0 && (
              <div className="report-chart" style={{ marginBottom: '20px' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData} margin={{ top: 8, right: 12, left: 0, bottom: 24 }}>
                    <CartesianGrid strokeDasharray="3 4" vertical={false} stroke="#e9ede8" />
                    <XAxis
                      dataKey="label"
                      axisLine={false}
                      tickLine={false}
                      tick={{ fill: '#77817c', fontSize: 10 }}
                      interval={0}
                      angle={-20}
                      textAnchor="end"
                    />
                    <YAxis
                      axisLine={false}
                      tickLine={false}
                      tick={{ fill: '#a0a8a3', fontSize: 10 }}
                    />
                    <Tooltip
                      formatter={(val) =>
                        ['top-items', 'geographic', 'quarterly'].includes(kind)
                          ? money(Number(val))
                          : `${Number(val)} hrs`
                      }
                      contentStyle={{ borderRadius: 6, border: '1px solid #e6ebe5', fontSize: 12 }}
                    />
                    <Bar
                      dataKey="value"
                      name={kind === 'fleet' || kind === 'working-hours' ? 'Hours' : 'Revenue (LKR)'}
                      fill="#43846f"
                      radius={[4, 4, 0, 0]}
                      maxBarSize={42}
                    />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}

            {/* Tabular Data */}
            <div className="table-scroll">
              <table>
                <thead>
                  <tr>
                    {Object.keys(rows[0]).map((key) => (
                      <th key={key}>{humanize(key)}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {rows.map((row, index) => (
                    <tr key={index}>
                      {Object.keys(rows[0]).map((key) => (
                        <td key={key}>{formatCell(key, row[key])}</td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        ) : (
          <EmptyState
            icon={FileText}
            title={error ? 'Report unavailable' : 'No rows for this period'}
            text={
              error
                ? 'Check that the backend report endpoint and database are available.'
                : 'Try adjusting the filters or verify that test/seed data exists for this period.'
            }
          />
        )}
      </section>
    </>
  );
}
