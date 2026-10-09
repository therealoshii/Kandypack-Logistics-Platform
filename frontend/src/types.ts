export type PageKey = 'overview' | 'deliveries' | 'orders' | 'fleet' | 'rail' | 'catalog' | 'reports';

export interface Delivery {
  deliveryId: number;
  orderId: number;
  tripId: number;
  deliveryDate: string;
  status: string;
}

export interface TruckTrip {
  tripId: number;
  truckId: number;
  routeId: number;
  driverId: number;
  assistantId: number;
  tripDate: string;
  dispatchTime: string;
  returnTime: string;
  driverName?: string;
  assistantName?: string;
}

export interface Driver {
  driverId: number;
  name: string;
  licenceNumber: string;
  contactNumber: string;
}

export interface Assistant {
  assistantId: number;
  name: string;
  contactNumber: string;
}

export interface Route {
  routeID: number;
  storeID: number;
  routeName: string;
  maxDeliveryTime: number;
  distance: number;
}

export interface Store {
  storeID: number;
  storeName: string;
  capacity: number;
  city: string;
  routes: Route[];
}

export interface TruckUtilization {
  truckID: number;
  registrationNumber: string;
  cargoCapacity: number;
  storeID: number;
  storeName: string;
  stationCity: string;
  totalDispatchedTrips: number;
  totalOperatingHours: number;
  totalDeliveriesCompleted: number;
}

export interface StaffHours {
  staffRole: string;
  staffId: number;
  staffName: string;
  referenceNumber: string;
  contactNumber: string;
  weekStartDate: string;
  weekNumber: number;
  tripsInWeek: number;
  totalHoursWorked: number;
  weeklyLimit: number;
  remainingHours: number;
  limitStatus: string;
}

export interface Customer {
  customerID: number;
  fullName: string;
  email: string;
  contactNumber: string;
  address: string;
  city: string;
  username: string;
}

export interface Product {
  productID: number;
  productName: string;
  unitPrice: number;
  spaceConsumption: number;
  stockQuantity: number;
  category: string;
}

export interface RailSchedule {
  scheduleId: number;
  trainName: string;
  departureTime: string;
  maxCapacity: number;
  availableCapacity: number;
}

export interface QuarterlyReport {
  year: number;
  quarter: number;
  totalOrders: number;
  totalUnitsSold: number;
  totalVolumeSpace?: number;
  totalRevenue: number;
}

export interface TopItem {
  productId: number;
  productName: string;
  category?: string;
  unitPrice?: number;
  totalQuantitySold: number;
  totalQuantityOrdered?: number;
  totalRevenueGenerated: number;
  distinctOrdersCount?: number;
}

export interface GeographicSales {
  city: string;
  routeId?: number;
  routeName?: string;
  totalOrders: number;
  totalUnits?: number;
  totalSales: number;
}

export interface WorkingHoursReport {
  staffRole: string;
  staffId: number;
  staffName: string;
  referenceId: string;
  totalTripsCompleted: number;
  totalHoursWorked: number;
  standardWeeklyLimit: number;
}

export interface FleetUsageReport {
  truckID: number;
  registrationNumber: string;
  storeName: string;
  city: string;
  totalTrips: number;
  operatingHours: number;
  totalMileage: number;
}

export interface CustomerOrderHistory {
  orderId: number;
  customerId: number;
  customerName: string;
  orderDate: string;
  orderStatus: string;
  orderTotalLKR: number;
  routeName: string;
  destinationCity: string;
  deliveryId?: number;
  deliveryDate?: string;
  deliveryStatus?: string;
  tripId?: number;
  assignedDriver?: string;
  assignedAssistant?: string;
  assignedTruck?: string;
  totalItemLines?: number;
  totalUnitsOrdered?: number;
}

