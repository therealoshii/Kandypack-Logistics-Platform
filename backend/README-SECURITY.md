# Staff Authentication and Roles

Staff use accounts in the existing `Administrator` table. Customer accounts remain separate and are not accepted by staff login.

## Database setup

For a new database, run the regular schema and seed scripts; `schema/02_tables_order.sql` creates `StaffRole` and `AdministratorRole`, and `seed/04_seed_orders.sql` seeds roles and assigns `ADMIN` to the `admin` sample account.

For an existing database, back it up and apply `../database/migrations/staff_roles.sql` once. Do not rerun the destructive schema setup scripts on a database containing data.

The existing sample Administrator passwords are placeholder hashes and are not valid login credentials. Create a real initial administrator using environment variables before starting the backend:

```powershell
$env:BOOTSTRAP_ADMIN_NAME = "Kandypack Administrator"
$env:BOOTSTRAP_ADMIN_USERNAME = "kandy-admin"
$env:BOOTSTRAP_ADMIN_EMAIL = "admin@example.com"
$env:BOOTSTRAP_ADMIN_PASSWORD = "use-a-unique-password-of-at-least-12-characters"
$env:DB_PASSWORD = "your-mysql-password"
.\mvnw.cmd spring-boot:run
```

The bootstrap runs only when the requested username does not already exist. It creates that account with the `ADMIN` role and a BCrypt password hash. After the first successful startup, remove the four `BOOTSTRAP_ADMIN_*` variables from the shell. The existing sample `admin` account can then be disabled from the staff screen if desired.

## Roles

- `ADMIN`: staff account management and all application APIs.
- `ORDER_MANAGER`: customer, product, and order APIs.
- `RAIL_DISPATCHER`: train schedules and shipment scheduling.
- `FLEET_MANAGER`: store, route, and truck utilization APIs.
- `ROSTER_DISPATCHER`: trips, crew, deliveries, and roster quota APIs.
- `ANALYST`: sales, geographic, and fleet-usage reports.

API authorization is enforced by Spring Security, not only by the React navigation. Sessions use HTTP-only cookies. Mutating requests require the CSRF token returned by `GET /api/auth/csrf`; the frontend API client handles this automatically. Set `SESSION_COOKIE_SECURE=true` when deployed over HTTPS.
