# Staff Authentication and Roles

Staff use accounts in the existing `Administrator` table. Customer accounts remain separate and are not accepted by staff login.

## Database setup

For a new database, run the regular schema and seed scripts; `schema/02_tables_order.sql` creates `StaffRole` and `AdministratorRole`, and `seed/04_seed_orders.sql` seeds roles and assigns `ADMIN` to the `admin` sample account.

For an existing database, back it up and apply `../database/migrations/staff_roles.sql` once. Do not rerun the destructive schema setup scripts on a database containing data.

No administrator password is stored in the source code. The seeded `admin` account has a placeholder hash that cannot be used to log in. At startup the backend reads the first administrator's details from environment variables and gives that account a real BCrypt password hash:

| Variable | Required | Default | Meaning |
|---|---|---|---|
| `BOOTSTRAP_ADMIN_PASSWORD` | Yes | none | Password, 12 to 72 characters |
| `BOOTSTRAP_ADMIN_USERNAME` | No | `admin` | Account to create or to activate |
| `BOOTSTRAP_ADMIN_EMAIL` | No | `admin@kandypack.lk` | Used only when the account is created |
| `BOOTSTRAP_ADMIN_NAME` | No | `Kandypack Administrator` | Used only when the account is created |

If `BOOTSTRAP_ADMIN_PASSWORD` is missing or the wrong length, the backend still starts, logs a warning and provisions no administrator, so nobody can log in as staff until it is set.

With Docker Compose, copy `.env.example` to `.env` in the repository root and set `DB_ROOT_PASSWORD` and `BOOTSTRAP_ADMIN_PASSWORD`. `.env` is git-ignored.

Without Docker, set the variables in the shell before starting the backend:

```powershell
$env:BOOTSTRAP_ADMIN_PASSWORD = "use-a-unique-password-of-at-least-12-characters"
$env:DB_PASSWORD = "your-mysql-password"
.\mvnw.cmd spring-boot:run
```

The bootstrap creates the account if the username does not exist, or replaces the password if the account still has the seed's placeholder hash. It never changes a real password, so changing `BOOTSTRAP_ADMIN_PASSWORD` later has no effect on an account that already works; use the Change password screen instead. Further staff accounts are created from the Staff and roles screen.

## Roles

- `ADMIN`: staff account management and all application APIs.
- `ORDER_MANAGER`: customer, product, and order APIs.
- `RAIL_DISPATCHER`: train schedules and shipment scheduling.
- `FLEET_MANAGER`: store, route, and truck utilization APIs.
- `ROSTER_DISPATCHER`: trips, crew, deliveries, and roster quota APIs.
- `ANALYST`: sales, geographic, and fleet-usage reports.

API authorization is enforced by Spring Security, not only by the React navigation. Sessions use HTTP-only cookies. Mutating requests require the CSRF token returned by `GET /api/auth/csrf`; the frontend API client handles this automatically. Set `SESSION_COOKIE_SECURE=true` when deployed over HTTPS.
