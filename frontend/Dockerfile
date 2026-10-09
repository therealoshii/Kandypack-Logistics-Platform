# Stage 1: Build the React Application
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source files and build the production bundle
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Replace default Nginx config with our custom one
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built React app from the Stage 1 build directory
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]