-- Master deployment script: runs all schemas, functions, procedures, triggers, indexes, views, and seed data.

SELECT '>>> Initializing Kandypack Logistics Platform Database Deployment...' AS Step;

SELECT '>>> [1/7] Creating Schemas...' AS Step;
SOURCE /docker-entrypoint-initdb.d/schema/01_tables_core.sql;
SOURCE /docker-entrypoint-initdb.d/schema/02_tables_order.sql;
SOURCE /docker-entrypoint-initdb.d/schema/03_tables_rail.sql;
SOURCE /docker-entrypoint-initdb.d/schema/04_tables_delivery.sql;

SELECT '>>> [2/7] Creating Stored Functions...' AS Step;
SOURCE /docker-entrypoint-initdb.d/functions/fn_calculate_total_space.sql;
SOURCE /docker-entrypoint-initdb.d/functions/fn_get_available_capacity.sql;
SOURCE /docker-entrypoint-initdb.d/functions/fn_calculate_weekly_hours.sql;
SOURCE /docker-entrypoint-initdb.d/functions/fn_get_route_for_address.sql;

SELECT '>>> [3/7] Creating Stored Procedures...' AS Step;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_place_order.sql;
-- sp_ship_order_line is shared by sp_schedule_shipment (one line) and sp_schedule_order (whole order)
SOURCE /docker-entrypoint-initdb.d/procedures/sp_ship_order_line.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_schedule_shipment.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_schedule_order.sql;
-- Truck trip rule procedures must load before the triggers that call them
SOURCE /docker-entrypoint-initdb.d/procedures/sp_lock_trip_resources.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_trip_route.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_schedule_conflict.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_driver_consecutive.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_assistant_consecutive.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_weekly_hours.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_check_delivery.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_assign_truck_trip.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_update_delivery_status.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_assign_delivery.sql;
SOURCE /docker-entrypoint-initdb.d/procedures/sp_staff_weekly_hours_report.sql;

SOURCE /docker-entrypoint-initdb.d/reports/sp_quarterly_sales_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_top_items_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_geographic_sales_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_working_hours_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_fleet_usage_report.sql;
SOURCE /docker-entrypoint-initdb.d/reports/sp_customer_order_history.sql;

SELECT '>>> [4/7] Creating Triggers...' AS Step;
SOURCE /docker-entrypoint-initdb.d/triggers/trg_check_cargo_capacity.sql; 
SOURCE /docker-entrypoint-initdb.d/triggers/trg_before_insert_trucktrip.sql;
SOURCE /docker-entrypoint-initdb.d/triggers/trg_validate_delivery.sql;
SOURCE /docker-entrypoint-initdb.d/triggers/trg_update_stock_on_dispatch.sql; 
SOURCE /docker-entrypoint-initdb.d/triggers/trg_audit_log.sql; 
SOURCE /docker-entrypoint-initdb.d/triggers/trg_shipment_weekday_check.sql;

SELECT '>>> [5/7] Creating Indexes...' AS Step;
SOURCE /docker-entrypoint-initdb.d/indexes/01_indexes.sql;

SELECT '>>> [6/7] Creating Views...' AS Step;
SOURCE /docker-entrypoint-initdb.d/views/vw_order_summary.sql;
SOURCE /docker-entrypoint-initdb.d/views/vw_truck_utilization.sql;
SOURCE /docker-entrypoint-initdb.d/views/vw_staff_weekly_hours.sql;

SELECT '>>> [7/7] Populating Seed Data...' AS Step;
SOURCE /docker-entrypoint-initdb.d/seed/01_seed_core.sql;
SOURCE /docker-entrypoint-initdb.d/seed/02_seed_rail.sql;
SOURCE /docker-entrypoint-initdb.d/seed/03_seed_delivery.sql;
SOURCE /docker-entrypoint-initdb.d/seed/04_seed_orders.sql;

SELECT '>>> Kandypack Database Deployment Completed Successfully!' AS Status;