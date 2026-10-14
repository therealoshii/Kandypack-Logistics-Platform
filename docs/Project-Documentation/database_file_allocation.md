# Database Responsibilities and File Commit Allocation (Version 3)

Task A8. This replaces "Database Responsibilities and File Commit Allocation 2" (25 September 2026).
Every path below exists in the repository under `database/` as of 11 October 2026.
The last section lists what changed from Version 2 and the one correction needed in the
Task Distribution document.

Deployment order (`run_all.sql`): schema, functions, procedures, reports, triggers, indexes,
views, seed. A procedure called by a trigger is loaded before that trigger.

## 1. Haneef - Customer and Order Management

Core focus: customer accounts, product catalog, 7-day advance order placement, route matching
by delivery area, and the customer portal.

| Type | File | Contents |
|---|---|---|
| Schema | `schema/01_tables_core.sql` | `Customer` (with `AreaID`), `Product` |
| Schema | `schema/02_tables_order.sql` | `Orders` (with `RequestedDeliveryDate` and the lead-time CHECK), `OrderDetail` |
| Function | `functions/fn_get_route_for_address.sql` | Route of the customer's delivery area |
| Procedure | `procedures/sp_place_order.sql` | Validates lead time, products and stock; saves the order and its lines in one transaction |
| Seed | `seed/01_seed_core.sql` | 12 customers (BCrypt password hashes), 10 products |
| Test | `tests/test_lead_time.sql` | Orders under 7 days are refused; a Nugegoda customer gets route 2 |

Application slice: `OrderController`, `ProductController`, `CustomerController`,
`PortalController` (`/api/portal/**`), and the portal pages (My orders, New order, Order details,
Profile).

## 2. Widushi - Railway and Shipment Management

Core focus: train timetable, cargo capacity, overbooking prevention, and overflow rollover.

| Type | File | Contents |
|---|---|---|
| Schema | `schema/03_tables_rail.sql` | `Train`, `TrainSchedule` (with `StoreID` and the unique timetable slot), `Shipment` |
| Function | `functions/fn_calculate_total_space.sql` | Space needed: quantity x space rate |
| Function | `functions/fn_get_available_capacity.sql` | Remaining space on a run on a date |
| Procedure | `procedures/sp_ship_order_line.sql` | Books an order line onto runs, splitting and rolling over overflow, with row locking; moves the order to Processing or Shipped |
| Procedure | `procedures/sp_schedule_shipment.sql` | Books one order line in its own transaction |
| Procedure | `procedures/sp_schedule_order.sql` | Books every waiting line of an order in one transaction (all or nothing) |
| Trigger | `triggers/trg_check_cargo_capacity.sql` | Prevents train overbooking |
| Trigger | `triggers/trg_shipment_weekday_check.sql` | Shipment date must fall on the schedule's day (insert and update) |
| Trigger | `triggers/trg_update_stock_on_dispatch.sql` | Reduces stock when cargo is dispatched |
| Seed | `seed/02_seed_rail.sql` | 3 trains, 12 weekly schedules (two per city) |
| Test | `tests/test_capacity_overflow.sql` | 700 units split 300 / 300 / 100 across three runs |

Application slice: `TrainController`, `ShipmentController`, Train Cargo page.

## 3. Shameera - Store and Truck Management

Core focus: regional stores, last-mile routes and their delivery areas, trucks, and fleet reports.

| Type | File | Contents |
|---|---|---|
| Schema | `schema/01_tables_core.sql` | `Store`, `Route`, `DeliveryArea` |
| Schema | `schema/04_tables_delivery.sql` | `Truck` |
| View | `views/vw_truck_utilization.sql` | Trips, operating hours and completed deliveries per truck |
| Report | `reports/sp_fleet_usage_report.sql` | Monthly trips, hours and distance per truck |
| Report | `reports/sp_geographic_sales_report.sql` | City-wise and route-wise sales |
| Seed | `seed/01_seed_core.sql` | 6 stores, 12 routes, 36 delivery areas |
| Seed | `seed/03_seed_delivery.sql` | 12 trucks assigned to stores |

Application slice: `StoreController`, `FleetController`, Store and Fleet page.

## 4. Oshan - Driver, Assistant and Delivery Management

Core focus: drivers and assistants, truck trips, roster rules, delivery checks, and delivery
status tracking.

| Type | File | Contents |
|---|---|---|
| Schema | `schema/04_tables_delivery.sql` | `Driver`, `Assistant`, `TruckTrip`, `Delivery` |
| Function | `functions/fn_calculate_weekly_hours.sql` | Weekly hours for drivers and assistants |
| Procedure | `procedures/sp_assign_truck_trip.sql` | Saves a trip and its audit entry in one transaction |
| Procedure | `procedures/sp_update_delivery_status.sql` | Changes delivery status and the order status together |
| Procedure | `procedures/sp_assign_delivery.sql` | Assigns a whole order to a truck trip and writes its audit entry in one transaction |
| Procedure | `procedures/sp_check_trip_route.sql` | Truck from the route's store; trip within the route's maximum time |
| Procedure | `procedures/sp_check_schedule_conflict.sql` | No overlapping truck, driver or assistant bookings |
| Procedure | `procedures/sp_check_driver_consecutive.sql` | Driver: no two consecutive trips |
| Procedure | `procedures/sp_check_assistant_consecutive.sql` | Assistant: at most two consecutive trips |
| Procedure | `procedures/sp_check_weekly_hours.sql` | Driver 40 hours, assistant 60 hours per week |
| Procedure | `procedures/sp_check_delivery.sql` | Delivery on the order's route, on the trip's date, 7 or more days after the order, after its last train arrives |
| Procedure | `procedures/sp_staff_weekly_hours_report.sql` | Week-by-week hours for the staff hours report |
| Trigger | `triggers/trg_before_insert_trucktrip.sql` | Insert and update triggers on `TruckTrip`; call the five trip rules |
| Trigger | `triggers/trg_validate_delivery.sql` | Insert and update triggers on `Delivery`; call `sp_check_delivery` |
| View | `views/vw_staff_weekly_hours.sql` | Current-week hours and remaining quota |
| Seed | `seed/03_seed_delivery.sql` | 10 drivers, 10 assistants |
| Test | `tests/test_roster_violations.sql` | 11 negative cases, one per rule |

Application slice: `TruckTripController`, `DeliveryController`, `DriverController`,
`AssistantController`, `StaffReportController`, Roster and Dispatch page.

## 5. Aathiththan - Reports and Administration

Core focus: management reports, staff accounts and roles, customer and staff login, audit log,
indexes, order seed data, and deployment.

| Type | File | Contents |
|---|---|---|
| Schema | `schema/02_tables_order.sql` | `Administrator`, `StaffRole`, `AdministratorRole`, `AuditLog` |
| Trigger | `triggers/trg_audit_log.sql` | Audit entries for order status, delivery status and trip changes |
| Report | `reports/sp_quarterly_sales_report.sql` | Sales by value and volume per quarter |
| Report | `reports/sp_top_items_report.sql` | Most ordered products in a quarter |
| Report | `reports/sp_working_hours_report.sql` | Driver and assistant hours summary |
| Report | `reports/sp_customer_order_history.sql` | Customer order and delivery history |
| View | `views/vw_order_summary.sql` | Order summary with delivery status |
| Indexes | `indexes/01_indexes.sql` | B-tree indexes for filtering and reports |
| Seed | `seed/04_seed_orders.sql` | 55 orders (22 in Q2, 26 in Q3, 7 in October), trips, shipments, deliveries, one rollover order |
| Test | `tests/test_seed_integrity.sql` | 20 checks that the data breaks no rule |
| Deployment | `run_all.sql`, `docker-compose.yml`, `README.md` | Build order and one-command start |

Application slice: Spring Boot setup, `SecurityConfig`, `AuthController` (staff and customer
login), `GlobalExceptionHandler`, `ReportController`, `StaffAdminController`, React shell,
Analytics and Reports pages, customer login and register pages, and the portal layout.

## 6. Shared files

| File | Shared by |
|---|---|
| `schema/01_tables_core.sql` | Haneef (`Customer`, `Product`), Shameera (`Store`, `Route`, `DeliveryArea`) |
| `schema/02_tables_order.sql` | Haneef (`Orders`, `OrderDetail`), Aathiththan (`Administrator`, `StaffRole`, `AdministratorRole`, `AuditLog`) |
| `schema/04_tables_delivery.sql` | Shameera (`Truck`), Oshan (`Driver`, `Assistant`, `TruckTrip`, `Delivery`) |
| `seed/01_seed_core.sql` | Haneef (customers, products), Shameera (stores, routes, delivery areas) |
| `seed/03_seed_delivery.sql` | Shameera (trucks), Oshan (drivers, assistants) |

`migrations/staff_roles.sql` is an earlier migration script. `run_all.sql` does not load it,
because `schema/02_tables_order.sql` now creates the same tables.

## 7. Changes from Version 2

| Member | Change |
|---|---|
| Haneef | `fn_get_route_for_address` matches the customer's delivery area, not the destination city. The customer portal is added to the slice. |
| Widushi | `triggers/trg_shipment_weekday_check.sql` added. |
| Shameera | `DeliveryArea` added to `schema/01_tables_core.sql` and its seed. Report files are in `reports/`, not `procedures/reports/`. |
| Oshan | The five `sp_check_*` trip rules, `sp_check_delivery`, `sp_staff_weekly_hours_report` and `triggers/trg_validate_delivery.sql` added. `sp_assign_truck_trip` no longer validates the rules itself; the triggers do. The view is `views/vw_staff_weekly_hours.sql`, not `vw_driver_weekly_hours.sql`. |
| Aathiththan | `StaffRole` and `AdministratorRole` added to the schema. `tests/test_seed_integrity.sql` added. The order seed has 55 orders, not 42. Report files are in `reports/`. Customer login added to the slice. |

Correction for the Task Distribution document: the roster controller is `TruckTripController`,
not `TripController`.
