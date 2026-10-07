# Kandypack Operations Console

React + TypeScript frontend for the Kandypack Logistics Platform.

## Run locally

Requirements: Node.js 20.19+ and npm.

```powershell
cd frontend
npm install
npm run dev
```

The Vite server runs at `http://localhost:5173` and proxies `/api` requests to the Spring Boot backend at `http://localhost:8080`. Start the backend and MySQL database separately. The backend's database password is configured with `DB_PASSWORD` in `backend/src/main/resources/application.properties`.

To point at another API origin, create a `.env.local` file with `VITE_API_URL=http://localhost:8080`.

## Build

```powershell
npm run build
```

The interface uses the existing REST endpoints. Order history and order-detail lookup are not currently exposed by the backend, so the frontend supports order placement but does not invent order-history or shipment-line data.
