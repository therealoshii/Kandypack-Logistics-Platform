# Roster, Truck Trip and Delivery Module - SRS Technical Specification

Task O9. Covers SRS sections 4.3.3 (last-mile delivery) and 4.4 (roster rules), and the
corrections needed in SRS 4.6.3 REQ-2, the glossary and the allocation document.

## 1. Where the Roster Rules Live

- **No `RosterDetail` table.** SRS 4.6.3 REQ-2 mentions a `RosterDetail` table. It does not exist.
  The `TruckTrip` table does that job: one row is one trip with its truck, route, driver,
  assistant, date, dispatch time and return time. The assistant is mandatory (`NOT NULL`).
- **One procedure per rule (decision D6).** Each rule is a stored procedure, so the logic exists
  in one place:

  | Order | Procedure | Rule | SRS |
  |---|---|---|---|
  | 1 | `sp_check_trip_route` | Return time after dispatch time; truck based at the route's store; trip within the route's maximum delivery time | 4.3.3 REQ-1, REQ-2 |
  | 2 | `sp_check_schedule_conflict` | A truck, driver or assistant cannot be on two trips that overlap in time on the same day | 4.4 REQ-6 |
  | 3 | `sp_check_driver_consecutive` | A driver cannot work two consecutive trips | 4.4 REQ-2 |
  | 4 | `sp_check_assistant_consecutive` | An assistant can work at most two consecutive trips | 4.4 REQ-3 |
  | 5 | `sp_check_weekly_hours` | Driver at most 40 hours a week, assistant at most 60 | 4.4 REQ-4, REQ-5 |

- **Two thin triggers call them.** `trg_before_insert_trucktrip` and `trg_before_update_trucktrip`
  (both in `triggers/trg_before_insert_trucktrip.sql`) call the five procedures in the order above.
  The rules therefore apply to every insert and every update of `TruckTrip`, whether it comes from
  the application, from `sp_assign_truck_trip` or from a direct SQL statement.
- **Updates are checked too.** The update trigger passes the trip's own `TripID`, so a trip being
  edited is never compared against its own old row. Before this, the rules ran on insert only and
  an update could move a trip into an overlap.
- **Creating a trip.** The application calls `sp_assign_truck_trip`, which inserts the trip and its
  `AuditLog` row in one transaction. The procedure does not repeat the rules. If a rule fails, the
  transaction is rolled back and the rule's message is returned.
- **Error reporting.** Every rule raises `SQLSTATE '45000'` with a readable message. The backend
  returns it as HTTP 400 and the Roster page shows the message in the trip form.

## 2. Definition of "Consecutive Trips" (decision D1)

- Two trips are **consecutive** when the next one is dispatched **less than 30 minutes** after the
  previous one returns. A gap of exactly 30 minutes counts as rested.
- **Driver:** never two consecutive trips. Every pair of a driver's trips needs at least a
  30-minute gap.
- **Assistant:** at most two consecutive trips. A third trip linked to a run of two is rejected,
  whether it would be the first, the middle or the last trip of the run.
- Both rules use the same 30-minute gap and compare trips on the same trip date.
- The glossary entry "Consecutive Trips" should be replaced with this definition.

## 3. Weekly Working Hours

- A week runs Monday to Sunday.
- Hours are the sum of (return time - dispatch time) over the person's trips in that week,
  including the trip being saved.
- The view `vw_staff_weekly_hours` shows, for the current week, the hours worked and the hours
  remaining for every driver and assistant, including those with no trips.
- `GET /api/staff/roster-quota` returns that view. The Roster page uses it to show each person's
  remaining hours before a trip is assigned. `GET /api/reports/staff-hours` returns the
  week-by-week history from `sp_staff_weekly_hours_report`.

## 4. Truck and Route Checks (SRS 4.3.3)

- **Truck belongs to a store.** Each truck is based at one store and each route starts from one
  store. A trip is rejected when the truck's store differs from the route's store. The Roster page
  only offers trucks from the selected route's store.
- **Maximum delivery time.** A trip is rejected when it is longer than the route's
  `MaxDeliveryTime` (in hours).
- **Access.** The roster dispatcher role has read-only access to stores and trucks so the Roster
  page can list them. Changing stores and trucks stays with the administrator and fleet manager.

## 5. Delivery Checks (SRS 4.3.3 REQ-4)

`sp_check_delivery`, called by `trg_before_insert_delivery` and `trg_before_update_delivery`
(both in `triggers/trg_validate_delivery.sql`), enforces:

- **Route:** the truck trip is on the same route as the order.
- **Date:** the delivery date is the trip's date.
- **Lead time:** the delivery is at least 7 days after the order date (SRS 4.2.3 REQ-1).

The update trigger runs these checks only when the order, the trip or the date changes. A status
change alone is not re-checked. `Delivery.OrderID` is unique, so an order has at most one delivery.

## 6. Delivery State Transitions

- States: `Scheduled`, `In Transit`, `Delivered`, `Cancelled`. A new delivery starts as `Scheduled`.
- Normal path: `Scheduled` -> `In Transit` -> `Delivered`.
- `Cancelled` can be reached from `Scheduled` or `In Transit`.
- `Delivered` and `Cancelled` are final. No further change is accepted.
- A delivery cannot go back from `In Transit` to `Scheduled`.
- A direct change from `Scheduled` to `Delivered` is not blocked.
- All changes go through `sp_update_delivery_status`, which updates the delivery and the order in
  one transaction. `In Transit`, `Delivered` and `Cancelled` are copied to the order's status.
- The audit trigger records each status change in `AuditLog` with the username of the staff member
  who made it.

## 7. Testing

`database/tests/test_roster_violations.sql` holds one negative case per rule (11 cases): overlap,
driver rest, driver 40 hours, assistant 60 hours, assistant third trip at the end and in the middle
of a run, truck from another store, trip over the route maximum, update into an overlap, delivery
on another route, and delivery dated differently from its trip.