## How directories are divided among members

```text
com/kandypack/logistics/               <--- SHARED ROOT (For the entire group)
│
├── delivery/                          <--- 🟢 Oshan's Directory
│   ├── entity/                        -- Driver, Assistant, TruckTrip, Delivery
│   ├── dto/                           -- DriverDTO, TruckTripDTO, etc.
│   ├── repository/                    -- DriverRepository, etc.
│   ├── service/                       -- DriverService, TruckTripService, etc.
│   └── controller/                    -- DriverController, DeliveryController, etc.
│
├── order/                             <--- 🔵 Haneef's Directory
│   ├── entity/                        -- Customer, Order, OrderDetail, Product
│   ├── dto/                           -- OrderDTO, ProductDTO, CustomerDTO
│   ├── repository/                    -- OrderRepository, ProductRepository
│   ├── service/                       -- OrderService, ProductService
│   └── controller/                    -- OrderController, ProductController
│
├── rail/                              <--- 🟣 Widushi's Directory
│   ├── entity/                        -- Train, TrainSchedule, Shipment
│   ├── dto/                           -- TrainScheduleDTO, ShipmentDTO
│   ├── repository/                    -- TrainRepository, ShipmentRepository
│   ├── service/                       -- TrainService, ShipmentService
│   └── controller/                    -- TrainController, ShipmentController
│
├── fleet/                             <--- 🟠 Shammera's Directory
│   ├── entity/                        -- Store, Truck, Route
│   ├── dto/                           -- StoreDTO, TruckDTO, RouteDTO
│   ├── repository/                    -- StoreRepository, TruckRepository
│   ├── service/                       -- StoreService, FleetService
│   └── controller/                    -- StoreController, FleetController
│
└── report/                            <--- 🔴 Aathiththan's Directory
    ├── dto/                           -- QuarterlyReportDTO, TopItemsDTO
    ├── service/                       -- ReportService
    └── controller/                    -- ReportController
```

### In a standard Spring Boot architecture, code is separated into dedicated concerns:

- `controller/`: Handles incoming HTTP requests and responses.

- `dto/`: Carries data transfer contracts between API clients and our server.

- `service/`: Holds core business logic, validations, and workflow orchestrations.

- `entity/`: Models the relational database tables.

- `repository/`: Directly talks to the database. It isolates all database operations (queries, insertions, updates, deletions) so the business logic in `service/` never has to execute raw SQL or manage database connections directly.