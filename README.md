# Kandypack Logistics Platform

## Rail and Road-based Supply Chain Distribution System

A database-driven logistics management system for managing
Kandypack's rail and road-based supply chain distribution process.

## Project Overview

The system manages the complete logistics process from customer
order placement to final delivery.

The main areas of the system are:

- Customer and Order Management
- Railway and Shipment Management
- Store and Truck Management
- Driver, Assistant and Delivery Management
- Reports and Administration

## Technologies

- Java
- Spring Boot
- MySQL 8+
- REST APIs
- HTML / CSS / JavaScript
- Git & GitHub

## Team

| Member | Responsibility |
|---|---|
| Haneef | Customer & Order Management |
| Widushi | Railway & Shipment Management |
| Shameera | Store & Truck Management |
| Oshan | Driver, Assistant & Delivery Management |
| Aathiththan | Reports & Administration |

## Main Modules

### 1. Customer & Order Management
- Customer registration and login
- Customer details
- Product viewing
- Order creation
- Order details
- Order status

### 2. Railway & Shipment Management
- Train management
- Train schedules
- Shipment management
- Shipment quantity calculation
- Train capacity and overflow handling

### 3. Store & Truck Management
- Store management
- Truck management
- Route management
- Truck assignment
- Truck trips
- Truck scheduling

### 4. Driver, Assistant & Delivery Management
- Driver management
- Assistant management
- Delivery management
- Driver and assistant assignment
- Working-hour restrictions
- Schedule conflict handling
- Delivery status

### 5. Reports & Administration
- Administrator management
- Quarterly sales report
- Most ordered products report
- City/route sales report
- Driver/assistant working hours report
- Truck usage report
- Customer order history
- Dashboard

## Database

The system uses MySQL 8+ as the relational database.

The database is based on the project's ER diagram and includes
the required entities, relationships, primary keys and foreign keys.

## Git Workflow

Each team member works on a separate feature branch.

```text
main
│
├── feature/customer-order
├── feature/railway-shipment
├── feature/store-truck
├── feature/driver-delivery
└── feature/reports-admin
