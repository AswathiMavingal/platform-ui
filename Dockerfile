# -------- Stage 1: Build --------
FROM node:20 AS build
WORKDIR /app

# Copy root dependencies (IMPORTANT)
COPY package*.json ./

RUN npm ci

# Copy source
COPY . .

# Build Angular app (adjust project name if needed)
# RUN npm run build:products -- -- --configuration production
# RUN npm run build:products -- -- --configuration production --base-href / --deploy-url / # working
ARG APP_NAME=products
# RUN npm run build:$APP_NAME -- -- --configuration production --base-href / --deploy-url /
RUN npx ng build $APP_NAME --configuration production --base-href / --deploy-url /

# -------- Stage 2: Serve --------
FROM nginx:1.25

# Remove default nginx config
# RUN rm /etc/nginx/conf.d/default.conf
# RUN rm -rf /usr/share/nginx/html/* worked in nginx:alpine but not in nginx:1.25, so using below command instead
RUN mkdir -p /usr/share/nginx/html

# Copy built app
# COPY --from=build /app/projects/products/dist/products /usr/share/nginx/html #working
ARG APP_NAME=products
COPY --from=build /app/projects/${APP_NAME}/dist/${APP_NAME} /usr/share/nginx/html
# COPY --from=build /app/dist/products /usr/share/nginx/html

# Optional: custom nginx config for SPA + MF
# COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]