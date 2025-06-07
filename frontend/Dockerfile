FROM node:20-alpine as base

WORKDIR /base

COPY package*.json .

RUN npm install

COPY . .

RUN npm run build



FROM nginx:1.27.5-alpine-slim

WORKDIR /usr/share/nginx/html

COPY --from=base /base/dist/frontend/browser .