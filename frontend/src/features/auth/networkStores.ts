// The six regional stores drawn on the sign-in map (SignInLayout.tsx).
// The sign-in pages are shown before login, so they cannot call the API. The names, trains,
// days and routes here are a copy of the seed data and must be updated if the seed changes:
//   database/seed/01_seed_core.sql  (Store, Route)
//   database/seed/02_seed_rail.sql  (Train, TrainSchedule)

export interface NetworkStore {
  id: string;
  city: string;
  storeName: string;
  train: string;
  runningDays: string;
  departure: string;
  cargoSpace: number;
  truckRoutes: [string, string];
  // Drawing data, in the map's 720 x 900 coordinate space
  railPath: string;
  stop: [number, number];
  label: { x: number; y: number; anchor: 'start' | 'end' };
  truckEnds: [[number, number], [number, number]];
}

// Kandy, where every rail line starts
export const HUB: [number, number] = [430, 440];

export const NETWORK_STORES: NetworkStore[] = [
  {
    id: 'jaffna', city: 'Jaffna', storeName: 'Northern Hub',
    train: 'Yal Devi Northern Line', runningDays: 'Tuesday and Friday', departure: '05:00, arrives 12:00', cargoSpace: 200,
    truckRoutes: ['Jaffna City Center', 'Chavakachcheri & Vadamarachchi'],
    railPath: 'M430 440 L430 196 L330 96', stop: [330, 96], label: { x: 306, y: 104, anchor: 'end' },
    truckEnds: [[292, 62], [374, 60]],
  },
  {
    id: 'trincomalee', city: 'Trincomalee', storeName: 'Eastern Center',
    train: 'Yal Devi Northern Line', runningDays: 'Wednesday and Sunday', departure: '05:30, arrives 12:30', cargoSpace: 150,
    truckRoutes: ['Trincomalee Town & Harbor', 'Kinniya & Nilaveli Coastal'],
    railPath: 'M430 440 L620 250', stop: [620, 250], label: { x: 560, y: 196, anchor: 'start' },
    truckEnds: [[664, 222], [668, 284]],
  },
  {
    id: 'negombo', city: 'Negombo', storeName: 'Regional Hub',
    train: 'Udarata Menike Express', runningDays: 'Tuesday and Thursday', departure: '07:00, arrives 08:30', cargoSpace: 120,
    truckRoutes: ['Negombo Town & Lagoon', 'Kochchikade & Katunayake Logistics'],
    railPath: 'M430 440 L232 440 L196 404', stop: [196, 404], label: { x: 216, y: 390, anchor: 'start' },
    truckEnds: [[150, 384], [160, 440]],
  },
  {
    id: 'colombo', city: 'Colombo', storeName: 'Central Warehouse',
    train: 'Udarata Menike Express', runningDays: 'Monday, two runs', departure: '06:00 and 14:00', cargoSpace: 150,
    truckRoutes: ['Colombo Fort & Pettah Commercial', 'Greater Colombo Suburban'],
    railPath: 'M430 440 L322 548 L196 548', stop: [196, 548], label: { x: 216, y: 518, anchor: 'start' },
    truckEnds: [[150, 530], [156, 584]],
  },
  {
    id: 'galle', city: 'Galle', storeName: 'Distribution Center',
    train: 'Ruhunu Kumari Southern Line', runningDays: 'Wednesday and Saturday', departure: '06:30, arrives 09:45', cargoSpace: 100,
    truckRoutes: ['Galle Fort & Coastal District', 'Hikkaduwa & Southern Corridor'],
    railPath: 'M430 440 L430 620 L290 760', stop: [290, 760], label: { x: 266, y: 752, anchor: 'end' },
    truckEnds: [[264, 806], [318, 808]],
  },
  {
    id: 'matara', city: 'Matara', storeName: 'Southern Depot',
    train: 'Ruhunu Kumari Southern Line', runningDays: 'Thursday and Sunday', departure: '06:00, arrives 10:30', cargoSpace: 100,
    truckRoutes: ['Matara City & Dondra Head', 'Weligama Bay Distribution'],
    railPath: 'M430 440 L430 800', stop: [430, 800], label: { x: 450, y: 790, anchor: 'start' },
    truckEnds: [[410, 846], [472, 840]],
  },
];
