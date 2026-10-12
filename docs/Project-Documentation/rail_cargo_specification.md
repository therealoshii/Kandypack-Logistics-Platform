# Rail Cargo Allocation Module - SRS Technical Specification

## 1. Timetable Architecture & Operational Assumptions
- **Fleet & Schedules:** Comprises 3 operational trains providing 12 weekly schedules across destination stores (two schedules per city).
- **Colombo Departures:** Colombo operates two departures specifically on Mondays. Other regional destination stores run on two different operating days.
- **Capacities & Journey Times:** Train capacities range from 100 to 200 units, with journey durations spanning 1.5 to 7 hours. These operational values serve as baseline system design assumptions.

## 2. Rollover Scheduling Algorithm (`sp_schedule_shipment`)
When an order line quantity exceeds available capacity, the procedure executes a multi-tier rollover allocation:
1. Allocates available space on the requested train schedule first.
2. Rolls over remaining quantity to the next train on the same day if applicable.
3. Rolls over to the next operating day that the destination city has a train, across a rolling 4-week window.
4. If the quantity cannot be fully accommodated within 4 weeks, the transaction fails and rolls back, raising the exception: *"No train capacity found within 4 weeks for this destination."*

## 3. Concurrency Control, Locking, and Transactions (SRS 4.6.3 REQ-1)
- **Atomic Transaction:** The scheduling procedure executes entirely within a single transaction boundary.
- **Row-Level Locking:** Secures exclusivity by locking the active schedule row with a `FOR UPDATE` clause to prevent race conditions during concurrent updates.
- **Rollback Safety:** Performs an absolute rollback of all changes upon encountering any validation error or constraint violation.

## 4. Validation Rules & Integrity Constraints
Before committing shipments, the procedure enforces strict checks:
- Verifies that the target order line exists and is **not already fully shipped**.
- Validates that the schedule's destination store matches the order's designated delivery route.
- Ensures the requested shipment date matches the operating weekday of the train schedule.
- **Database Trigger Enforcement:** The weekday rule is also permanently enforced by the `trg_shipment_weekday_check` trigger on direct table insertions and updates.

## 5. Data Model Refinements
- **Foreign Key Relationships:** `Shipment` records correctly reference `OrderDetailID` (rather than `OrderID` as stated in legacy SRS data dictionaries).
- **Store Mapping:** `TrainSchedule.StoreID` acts as a foreign key that replaced the legacy Destination text column. Unique constraints ensure a single train cannot be timetabled twice in the same slot.