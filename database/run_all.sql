-- ====================================================================
-- Kandypack Logistics Platform - Master Database Deployment Script
-- File: run_all.sql
-- Executes all schemas, functions, procedures, reports, triggers,
-- indexes, views, and seed data in the required dependency order.
-- ====================================================================

SELECT '>>> Initializing Kandypack Logistics Platform Database Deployment...' AS Step;

-- --------------------------------------------------------------------
-- 1. SCHEMAS (Tables & Relationships)
-- --------------------------------------------------------------------
SELECT '>>> [1/7] Creating Schemas...' AS Step;
SOURCE /docker-entrypoint-initdb.d/schema/01_tables_core.sql;
SOURCE /docker-entrypoint-initdb.d/schema/02_tables_order.sql;
SOURCE /docker-entrypoint-initdb.d/schema/03_tables_rail.sql;
SOURCE /docker-entrypoint-initdb.d/schema/04_tables_delivery.sql;

-- --------------------------------------------------------------------
-- 2. FUNCTIONS (Calculations & Lookups)
-- --------------------------------------------------------------------
SELECT '>>> [2/7] Creating Stored Functions...' AS Step;
SOURCE /docker-entrypoint-initdb.d/functions/fn_calculate_total_space.sql;
SOURCE /docker-entrypoint-initdb.d/functions/fn_get_available_capacity.sql;
SOURCE /docker-entrypoint-initdb.d/functions/fn_calculate_weekly_hours.sql;
SOURCE /docker-entrypoint-initdb.d/functions/fn_get_route_for_address.sql;

-- --------------------------------------------------------------------
-- 3. PROCEDURES (Business Transactions)
-- --------------------------------------------------------------------
SELECT '>>> [3/7] Creating Stored Procedures...' AS Step;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_place_order.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_schedule_shipment.sql;
-- Truck trip rules (called by the TruckTrip triggers, so they must load before the triggers block)
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_trip_route.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_schedule_conflict.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_driver_consecutive.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_assistant_consecutive.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_weekly_hours.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_assign_truck_trip.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_update_delivery_status.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_staff_weekly_hours_report.sql;

-- Management Reports (Moved to /reports directory)
SOURCE /docker-entrypoint-initdb.d/reports/sp_quarterly_sales_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_top_items_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_geographic_sales_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_working_hours_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_fleet_usage_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_customer_order_history.sql;

-- --------------------------------------------------------------------
-- 4. TRIGGERS (ACID Integrity & Constraint Enforcement)
-- --------------------------------------------------------------------
SELECT '>>> [4/7] Creating Triggers...' AS Step;
SOURCE /docker-entrypoint-initdb.d/triggers/trg_check_cargo_capacity.sql; 
SOURCE /docker-entrypoint-initdb.d/triggers/trg_before_insert_trucktrip.sql;
SOURCE /docker-entrypoint-initdb.d/triggers/trg_update_stock_on_dispatch.sql; 
SOURCE /docker-entrypoint-initdb.d/triggers/trg_audit_log.sql; 

-- --------------------------------------------------------------------
-- 5. INDEXES (B-Tree Performance Optimization)
-- --------------------------------------------------------------------
SELECT '>>> [5/7] Creating Indexes...' AS Step;
SOURCE /docker-entrypoint-initdb.d/indexes/01_indexes.sql;

-- --------------------------------------------------------------------
-- 6. VIEWS (Reporting & Analytical Views)
-- --------------------------------------------------------------------
SELECT '>>> [6/7] Creating Views...' AS Step;
SOURCE /docker-entrypoint-initdb.d/views/vw_order_summary.sql;
SOURCE /docker-entrypoint-initdb.d/views/vw_truck_utilization.sql;
SOURCE /docker-entrypoint-initdb.d/views/vw_staff_weekly_hours.sql;

-- --------------------------------------------------------------------
-- 7. SEED DATA (Base Configuration & 40+ Orders)
-- --------------------------------------------------------------------
SELECT '>>> [7/7] Populating Seed Data...' AS Step;
SOURCE /docker-entrypoint-initdb.d/seed/01_seed_core.sql;
SOURCE /docker-entrypoint-initdb.d/seed/02_seed_rail.sql;
SOURCE /docker-entrypoint-initdb.d/seed/03_seed_delivery.sql;
SOURCE /docker-entrypoint-initdb.d/seed/04_seed_orders.sql;

SELECT '>>> Kandypack Database Deployment Completed Successfully!' AS Status;