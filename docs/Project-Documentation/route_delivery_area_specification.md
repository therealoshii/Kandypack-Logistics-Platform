# Route and Delivery Area Module - SRS Technical Specification

Task S6. Covers the route definition, delivery areas, customer-to-area mapping and store–truck–route relationships in the SRS, data dictionary and ER diagram.

## 1. Route Definition

- **Last-mile route.** A `Route` represents a truck delivery route starting from a store. It is not a rail route. This corrects the earlier SRS Version 1.0 description of a rail route from Kandy.
- **Route origin.** `Route.StoreID` identifies the store from which the route starts. The system has 12 routes, two per store.
- **Distance.** `Route.Distance` represents the estimated round-trip road distance, measured in kilometres (km). The seeded distances range from 20 to 60 km, and the distance must be greater than zero.
- **Maximum delivery time.** `Route.MaxDeliveryTime` is the maximum permitted duration of a trip on the route, measured in hours. The seeded values range from 3 to 7.5 hours, and the value must be greater than zero. `sp_check_trip_route` rejects a trip exceeding this limit.

## 2. Delivery Areas

- **DeliveryArea table.** `DeliveryArea` contains `AreaID`, `AreaName` and `RouteID`. It represents a named locality served by a route.
- **Route relationship.** Each delivery area belongs to exactly one route. `RouteID` is a non-null foreign key referencing `Route`, and `UNIQUE (RouteID, AreaName)` prevents duplicate area names on the same route.
- **Seed data.** The database contains 36 delivery areas, with three areas per route.
- **Documentation updates.** `DeliveryArea` and its relationship with `Route` must be included in the data dictionary and ER diagram.

## 3. Customer-to-Area Mapping

- **Customer relationship.** `Customer.AreaID` references `DeliveryArea.AreaID`, assigning each customer to exactly one delivery area.
- **City information.** A customer's city is derived through the delivery-area, route and store relationships rather than being stored directly in the customer record. This avoids redundant city information and supports the database's third normal form (3NF).
- **Order route.** An order's route is determined through the customer's delivery area and its associated route. The relationship is established through foreign keys rather than matching city names as text.
- **SRS updates.** The customer-to-area relationship and the method of determining an order's route should be reflected in the SRS, data dictionary and ER diagram.

## 4. Store and Truck Relationships

- **Store assignment.** Each truck is assigned to one store through `Truck.StoreID`. The truck registration number is unique.
- **Capacity.** `Truck.Capacity` must be greater than zero.
- **Route compatibility.** A truck trip must use a truck assigned to the same store from which its route originates.
- **Validation.** `sp_check_trip_route`, called by the insert and update triggers on `TruckTrip`, enforces the store–truck–route relationship. The Roster page also offers trucks according to the selected route's store.
- **SRS updates.** The relevant last-mile delivery requirements should describe the store assignment, route origin and truck-trip validation rule.

## 5. Data Dictionary and SRS Corrections

The following documentation updates are required to keep the SRS consistent with the implemented database:

1. **Route:** Define a route as a last-mile truck route starting from a store, not a rail route.
2. **Route.Distance:** Specify estimated round-trip road distance in kilometres.
3. **Route.MaxDeliveryTime:** Specify the maximum trip duration in hours.
4. **DeliveryArea:** Document its attributes, primary key, foreign key and relationship with `Route`.
5. **Customer.AreaID:** Document its foreign-key relationship with `DeliveryArea` and the customer-to-area mapping.
6. **Truck.StoreID:** Document the truck's store assignment and the requirement that the truck and route belong to the same store.
7. **Capacity units:** Specify that `Store.Capacity` and `Truck.Capacity` are measured in cargo space units, not kilograms.