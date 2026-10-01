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

