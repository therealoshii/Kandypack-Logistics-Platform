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
SOURCE schema/01_tables_core.sql;
SOURCE schema/02_tables_order.sql;
SOURCE schema/03_tables_rail.sql;
SOURCE schema/04_tables_delivery.sql;

-- --------------------------------------------------------------------
-- 2. FUNCTIONS (Calculations & Lookups)
-- --------------------------------------------------------------------
SELECT '>>> [2/7] Creating Stored Functions...' AS Step;
SOURCE functions/fn_calculate_total_space.sql;
SOURCE functions/fn_get_available_capacity.sql;
SOURCE functions/fn_calculate_weekly_hours.sql;
SOURCE functions/fn_get_route_for_address.sql;

-- --------------------------------------------------------------------
-- 3. PROCEDURES (Business Transactions)
-- --------------------------------------------------------------------
SELECT '>>> [3/7] Creating Stored Procedures...' AS Step;
SOURCE procedures/sp_place_order.sql;
SOURCE procedures/sp_schedule_shipment.sql;
SOURCE procedures/sp_assign_truck_trip.sql;
SOURCE procedures/sp_update_delivery_status.sql;
SOURCE procedures/sp_staff_weekly_hours_report.sql;

-- Management Reports (Moved to /reports directory)
SOURCE reports/sp_quarterly_sales_report.sql;
SOURCE reports/sp_top_items_report.sql;
SOURCE reports/sp_geographic_sales_report.sql;
SOURCE reports/sp_working_hours_report.sql;
SOURCE reports/sp_fleet_usage_report.sql;
SOURCE reports/sp_customer_order_history.sql;

-- --------------------------------------------------------------------
-- 4. TRIGGERS (ACID Integrity & Constraint Enforcement)
-- --------------------------------------------------------------------
SELECT '>>> [4/7] Creating Triggers...' AS Step;
SOURCE triggers/trg_check_cargo_capacity.sql; 
SOURCE triggers/trg_before_insert_trucktrip.sql;
SOURCE triggers/trg_update_stock_on_dispatch.sql; 
SOURCE triggers/trg_audit_log.sql; 

-- --------------------------------------------------------------------
-- 5. INDEXES (B-Tree Performance Optimization)
-- --------------------------------------------------------------------
SELECT '>>> [5/7] Creating Indexes...' AS Step;
SOURCE indexes/01_indexes.sql;

-- --------------------------------------------------------------------
-- 6. VIEWS (Reporting & Analytical Views)
-- --------------------------------------------------------------------
SELECT '>>> [6/7] Creating Views...' AS Step;
SOURCE views/vw_order_summary.sql;
SOURCE views/vw_truck_utilization.sql;
SOURCE views/vw_staff_weekly_hours.sql;

-- --------------------------------------------------------------------
-- 7. SEED DATA (Base Configuration & 40+ Orders)
-- --------------------------------------------------------------------
SELECT '>>> [7/7] Populating Seed Data...' AS Step;
SOURCE seed/01_seed_core.sql;
SOURCE seed/02_seed_rail.sql;
SOURCE seed/03_seed_delivery.sql;
SOURCE seed/04_seed_orders.sql;

SELECT '>>> Kandypack Database Deployment Completed Successfully!' AS Status;