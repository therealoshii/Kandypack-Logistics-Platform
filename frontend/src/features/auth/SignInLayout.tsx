import { useEffect, useRef, useState } from 'react';
import type { ReactNode } from 'react';
import { ArrowRight, Eye, EyeOff } from 'lucide-react';
import BrandMark from '../../shared/BrandMark';
import { Link } from 'react-router-dom';
import { HUB, NETWORK_STORES } from './networkStores';

// Shared page for the two sign-in routes (/login for staff, /portal/login for customers):
// the distribution network map on the left, the tabs and the page's own form on the right.

type Audience = 'staff' | 'customer';

const COPY: Record<Audience, { eyebrow: string; text: string }> = {
  staff: { eyebrow: 'STAFF OPERATIONS', text: 'One workspace for orders, train cargo, truck rosters and deliveries.' },
  customer: { eyebrow: 'CUSTOMER PORTAL', text: 'Place an order seven days ahead and follow it to your door.' },
};

export default function SignInLayout({ audience, children }: { audience: Audience; children: ReactNode }) {
  return (
    <main className="signin">
      <section className="signin-map" aria-label="Kandypack distribution network">
        <div className="signin-brand">
          <span className="signin-mark"><BrandMark size={28} /></span>
          <span>KANDYPACK <small>LOGISTICS / LK</small></span>
        </div>
        <div className="signin-headline">
          <p className="signin-eyebrow">{COPY[audience].eyebrow}</p>
          <h1>From Kandy to the customer's door.</h1>
          <p>{COPY[audience].text}</p>
        </div>
        <NetworkMap />
      </section>

      <section className="signin-panel">
        <nav className="signin-tabs" aria-label="Who is signing in">
          <Link to="/login" aria-current={audience === 'staff' ? 'page' : undefined}>Staff</Link>
          <Link to="/portal/login" aria-current={audience === 'customer' ? 'page' : undefined}>Customer</Link>
        </nav>
        {children}
      </section>
    </main>
  );
}

// Username and password inputs with the submit button, used by both sign-in forms
export function SignInFields({ username, password, onUsername, onPassword, submitting, disabled }: {
  username: string;
  password: string;
  onUsername: (value: string) => void;
  onPassword: (value: string) => void;
  submitting: boolean;
  disabled: boolean;
}) {
  const [passwordVisible, setPasswordVisible] = useState(false);

  return (
    <>
      <label className="signin-field">Username
        <input autoComplete="username" autoFocus required value={username}
          onChange={(event) => onUsername(event.target.value)} placeholder="Your username" />
      </label>

      <label className="signin-field">Password
        <span className="signin-password">
          <input autoComplete="current-password" type={passwordVisible ? 'text' : 'password'} required value={password}
            onChange={(event) => onPassword(event.target.value)} placeholder="Your password" />
          <button type="button" aria-label={passwordVisible ? 'Hide password' : 'Show password'} aria-pressed={passwordVisible}
            onClick={() => setPasswordVisible((visible) => !visible)}>
            {passwordVisible ? <EyeOff size={17} /> : <Eye size={17} />}
          </button>
        </span>
      </label>

      <button className="signin-submit" disabled={disabled}>
        {submitting ? 'Signing in…' : 'Sign in'} <ArrowRight size={17} />
      </button>
    </>
  );
}

// The network as a transit map. Pointing at a city (or moving to it with the keyboard)
// highlights its rail line and shows its details; a click keeps it open.
function NetworkMap() {
  const [pointedId, setPointedId] = useState<string | null>(null);
  const [pinnedId, setPinnedId] = useState<string | null>(null);
  const svgRef = useRef<SVGSVGElement>(null);

  const activeId = pointedId ?? pinnedId;
  const active = NETWORK_STORES.find((store) => store.id === activeId);

  // The moving trains are SVG animations, which CSS cannot switch off
  useEffect(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) svgRef.current?.pauseAnimations();
  }, []);

  function togglePin(id: string) {
    setPinnedId((current) => (current === id ? null : id));
  }

  return (
    <div className="signin-network-area" onClick={() => setPinnedId(null)}>
      <svg ref={svgRef} className={`signin-network${active ? ' has-active' : ''}`} viewBox="0 0 720 900"
        preserveAspectRatio="xMaxYMid meet">
        {NETWORK_STORES.map((store, index) => {
          const [x, y] = store.stop;
          return (
            <g key={store.id} className={`signin-city${store.id === activeId ? ' is-active' : ''}`}
              tabIndex={0} role="button" aria-pressed={store.id === pinnedId}
              aria-label={`${store.city} ${store.storeName}`}
              onMouseEnter={() => setPointedId(store.id)} onMouseLeave={() => setPointedId(null)}
              onFocus={() => setPointedId(store.id)} onBlur={() => setPointedId(null)}
              onClick={(event) => { event.stopPropagation(); togglePin(store.id); }}
              onKeyDown={(event) => {
                if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); togglePin(store.id); }
              }}>
              {store.truckEnds.map(([endX, endY]) => (
                <g key={`${endX}-${endY}`}>
                  <path className="signin-road" d={`M${x} ${y} L${endX} ${endY}`} />
                  <circle className="signin-drop" cx={endX} cy={endY} r={4} />
                </g>
              ))}
              <path className="signin-rail" id={`signin-line-${store.id}`} d={store.railPath} />
              <path className="signin-hit" d={store.railPath} />
              <circle className="signin-train" r={5.5}>
                <animateMotion dur={`${7 + index * 0.8}s`} begin={`${index * 1.1}s`} repeatCount="indefinite"
                  keyPoints="0;1;1" keyTimes="0;0.8;1" calcMode="linear">
                  <mpath href={`#signin-line-${store.id}`} />
                </animateMotion>
              </circle>
              <circle className="signin-stop" cx={x} cy={y} r={9} />
              <text className="signin-city-name" x={store.label.x} y={store.label.y} textAnchor={store.label.anchor}>
                {store.city.toUpperCase()}
              </text>
              <text className="signin-city-store" x={store.label.x} y={store.label.y + 17} textAnchor={store.label.anchor}>
                {store.storeName}
              </text>
            </g>
          );
        })}
        <circle className="signin-hub-ring" cx={HUB[0]} cy={HUB[1]} r={26} />
        <circle className="signin-hub-ring signin-hub-ring-late" cx={HUB[0]} cy={HUB[1]} r={26} />
        <circle className="signin-hub" cx={HUB[0]} cy={HUB[1]} r={13} />
        <text className="signin-hub-name" x={HUB[0] + 46} y={HUB[1] - 4}>Kandy</text>
        <text className="signin-hub-role" x={HUB[0] + 46} y={HUB[1] + 13}>FACTORY</text>
      </svg>

      <div className="signin-detail" aria-live="polite" onClick={(event) => event.stopPropagation()}>
        {active ? (
          <div className="signin-card" key={active.id}>
            <p className="signin-eyebrow">KANDY TO {active.city.toUpperCase()}</p>
            <h3>{active.city} {active.storeName}</h3>
            <dl>
              <div><dt>Train</dt><dd>{active.train}<small>{active.cargoSpace} units of cargo space per run</small></dd></div>
              <div><dt>Runs</dt><dd>{active.runningDays}<small>Leaves Kandy at {active.departure}</small></dd></div>
              <div><dt>Trucks</dt><dd>{active.truckRoutes[0]} route<br />{active.truckRoutes[1]} route</dd></div>
            </dl>
            <p className="signin-card-foot">
              {pinnedId === active.id ? 'Pinned. Click the city again to release it.' : 'Click the city to keep this open.'}
            </p>
          </div>
        ) : (
          <div className="signin-totals">
            <p className="signin-hint"><i />Point at a city to see its train. Click to keep it open.</p>
            <div className="signin-stats">
              <div><b>6</b><span>Regional stores</span></div>
              <div><b>12</b><span>Truck routes</span></div>
              <div><b>36</b><span>Delivery areas</span></div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
