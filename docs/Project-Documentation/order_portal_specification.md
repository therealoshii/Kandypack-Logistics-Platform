# Customer Order & Portal Module - SRS Technical Specification

Task H7 & H9. Covers SRS sections 4.1 (Customer Account Management), 4.2 (Order Placement & Lead Time), 4.6 (Access Control & Data Isolation), and the updates needed in the SRS data dictionary and glossary.

---

## 1. Orders.RequestedDeliveryDate & 7-Day Lead-Time Rule (SRS 4.2)

- **Schema Requirement:** The `Orders` table defines `RequestedDeliveryDate DATE NOT NULL` alongside `OrderDate DATE NOT NULL`.
- **Database CHECK Constraint:** Permanent table-level enforcement via constraint `chk_order_lead_time`:
  ```sql
  CONSTRAINT chk_order_lead_time CHECK (DATEDIFF(RequestedDeliveryDate, OrderDate) >= 7)
  ```
- **Stored Procedure Validation (`sp_place_order`):** Before initiating the order transaction, the procedure enforces:
  ```sql
  SET v_lead_time_days = DATEDIFF(p_DeliveryDate, CURDATE());
  IF v_lead_time_days < 7 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Advance Order Placement Rule Violation: Orders must be placed at least 7 days before expected delivery date.';
  END IF;
  ```
- **Error Handling:** When an order is submitted with fewer than 7 days lead time (such as a 3-day advance date), `sp_place_order` rolls back and raises `SQLSTATE '45000'`. The backend catches this in `GlobalExceptionHandler` and returns HTTP 400 Bad Request, and the Customer Portal displays the advance lead-time error banner.

---

## 2. Customer.AreaID Refactoring & Route Resolution (SRS 4.1.2 & 4.2.1)

- **Legacy Replacement:** The legacy unstructured text column `Customer.City` has been completely replaced by `Customer.AreaID INT NOT NULL`, referencing `DeliveryArea(AreaID)`.
- **Relational Route Matching:** Rather than assigning routes manually or via text matching, destination routes are resolved deterministically through the normalized hierarchy:
  $$\text{Customer} \xrightarrow{\text{AreaID}} \text{DeliveryArea} \xrightarrow{\text{RouteID}} \text{Route} \xrightarrow{\text{StoreID}} \text{Store}$$
- **Automated Routing Function (`fn_get_route_for_address`):** `sp_place_order` invokes `fn_get_route_for_address(p_CustomerID)` to assign `Orders.RouteID` automatically at placement time:
  ```sql
  SELECT da.RouteID INTO v_route_id
  FROM Customer c
  JOIN DeliveryArea da ON c.AreaID = da.AreaID
  WHERE c.CustomerID = p_customer_id;
  ```
  If no route maps to the customer's delivery area, the order transaction rolls back with `SQLSTATE '45000'`.

---

## 3. Order Lifecycle (SRS 4.2.3)

Orders progress through six standardized status states defined in `Orders.Status`:
```sql
Status ENUM('Placed', 'Processing', 'Shipped', 'In Transit', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Placed'
```

1. **Placed:** Initial state immediately after customer placement via `sp_place_order` or staff order placement.
2. **Processing:** Order line items are verified and inventory is confirmed/reserved at the source warehouse.
3. **Shipped:** Inter-city rail freight shipment scheduled/dispatched (`Shipment` allocation to train schedule).
4. **In Transit:** Final last-mile delivery scheduled and dispatched on a truck trip (`Delivery` assigned to `TruckTrip`).
5. **Delivered:** Physical drop-off confirmed at customer destination; delivery record updated to `Delivered`.
6. **Cancelled:** Order terminated prior to dispatch, releasing reserved inventory.

---

## 4. Customer Portal Architecture & Data Isolation (SRS 4.6.1 REQ-4)

- **Dedicated API Namespace:** All customer self-service actions operate under `/api/portal/**`, protected by Spring Security requiring `ROLE_CUSTOMER`.
- **Identity Isolation Rule:** The customer ID is **always extracted directly from the authenticated session context** via `currentCustomerId(authentication)`. It is **never** accepted from request path parameters, query strings, or request bodies.
  - `GET /api/portal/me`: Loads the caller's profile without exposing password hashes.
  - `PUT /api/portal/me`: Updates `fullName`, `email`, `contactNumber`, `address`, and `areaId` (username is immutable). Validates email uniqueness across customers and returns HTTP 409 Conflict on collision.
  - `POST /api/portal/me/password`: Verifies current password against stored BCrypt hash, validates 12–72 character bounds, and persists the new hash.
  - `GET /api/portal/products`: Read-only catalog exposing product name, unit price, stock quantity, and stock status.
  - `GET /api/portal/orders`: Returns the authenticated customer's own order history and linked delivery status.
  - `GET /api/portal/orders/{id}`: Resolves order details, line items, and delivery progression. **Strict isolation:** If the requested `orderId` belongs to another customer or does not exist, the API returns **HTTP 404 Not Found** (preventing user enumeration).
  - `POST /api/portal/orders`: Forces `request.setCustomerID(currentCustomerId(authentication))` before executing `sp_place_order`.

---

## 5. Password Security & Cryptography (SRS 4.1.3 & 4.6.2)

- **Hashing Algorithm:** Passwords are never stored in plaintext. They are salted and hashed using `BCryptPasswordEncoder` with strength factor 10.
- **Length Constraint:** Validated strictly at 12–72 characters:
  - Minimum 12 characters ensures resistance against brute-force attacks.
  - Maximum 72 characters respects the BCrypt truncation boundary.
- **Zero Exposure Guarantee:** Password hashes are omitted from all DTO projections (`CustomerDTO`, `CustomerProfile`, `PortalOrderDetailDTO`), Jackson serialization rules, and API response bodies.

