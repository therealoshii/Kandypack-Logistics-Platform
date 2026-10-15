# Rail Cargo Allocation Module - SRS Technical Specification

## 1. Timetable Architecture & Operational Assumptions
- **Fleet & Schedules:** Comprises 3 operational trains providing 12 weekly schedules across destination stores (two schedules per city).
- **Colombo Departures:** Colombo operates two departures specifically on Mondays. Other regional destination stores run on two different operating days.
- **Capacities & Journey Times:** Train capacities range from 100 to 200 units, with journey durations spanning 1.5 to 7 hours. These operational values serve as baseline system design assumptions.

## 2. Rollover Scheduling Algorithm (`sp_ship_order_line`)
The booking of one order line lives in `sp_ship_order_line`. It is used by `sp_schedule_shipment` (one line) and
`sp_schedule_order` (a whole order, section 6). When an order line quantity exceeds available capacity, it executes a multi-tier rollover allocation:
1. Allocates available space on the requested train schedule first.
2. Rolls over remaining quantity to the next train on the same day if applicable.
3. Rolls over to the next operating day that the destination city has a train, across a rolling 4-week window.
4. If the quantity cannot be fully accommodated within 4 weeks, the transaction fails and rolls back, raising the exception: *"No train capacity found within 4 weeks for this destination."*

## 3. Concurrency Control, Locking, and Transactions (SRS 4.6.3 REQ-1)
- **Atomic Transaction:** The scheduling procedure executes entirely within a single transaction boundary.
- **Row-Level Locking:** Secures exclusivity by locking the active schedule row with a `FOR UPDATE` clause to prevent race conditions during concurrent updates.
- **Order Line Locking:** The order line is locked (`FOR UPDATE`) before its remaining quantity is read, so two dispatchers cannot both book the same units. `sp_schedule_order` also locks the order row.
- **Rollback Safety:** Performs an absolute rollback of all changes upon encountering any validation error or constraint violation.

## 4. Validation Rules & Integrity Constraints
Before committing shipments, the procedure enforces strict checks:
- Verifies that the target order line exists, is **not already fully shipped**, and does not belong to a **cancelled** order.
- **Stock check:** stock leaves the warehouse when it is loaded on a train (`trg_update_stock_on_dispatch`), not when the order is placed.
  `sp_place_order` checks stock for each order, but two orders placed before either is shipped can together need more than the warehouse holds.
  The product row is therefore locked (`FOR UPDATE`) and the line is refused if stock is below its remaining units:
  *"Insufficient Stock: The warehouse does not have enough stock to ship this order line."* Nothing is booked, and for a whole order no line is booked.
- Validates that the schedule's destination store matches the order's designated delivery route.
- Ensures the requested shipment date matches the operating weekday of the train schedule.
- **Database Trigger Enforcement:** The weekday rule is also permanently enforced by the `trg_shipment_weekday_check` trigger on direct table insertions and updates.

## 5. Data Model Refinements
- **Foreign Key Relationships:** `Shipment` records correctly reference `OrderDetailID` (rather than `OrderID` as stated in legacy SRS data dictionaries).
- **Store Mapping:** `TrainSchedule.StoreID` acts as a foreign key that replaced the legacy Destination text column. Unique constraints ensure a single train cannot be timetabled twice in the same slot.

## 6. Shipping a Whole Order (`sp_schedule_order`)
- An order usually has several lines (one per product). The Train Cargo page lists **orders**, and books every line that is still waiting in one call.
- All lines start from the same train run and date; each line's overflow rolls over on its own (section 2).
- **All or nothing:** the procedure opens one transaction for the whole order. If any line cannot be booked within 4 weeks, nothing is saved for any line.
- A single line can still be booked on its own (`sp_schedule_shipment`), for example to send part of an order early.
- API: `POST /api/shipments/schedule-order` with `orderId`, `scheduleId` and `shipmentDate`.

## 7. Order Status After Booking
- After each line is booked, the order moves forward: **Processing** while some lines are still waiting, **Shipped** once every line is on a train.
- Orders already further on (Shipped, In Transit, Delivered) are not changed. The change is audited with the dispatcher's username.
- A **Shipped** order can then be assigned to a truck trip (see the roster and delivery specification, section 5).