FROM node:lts-alpine as build-frontend
WORKDIR /home/jackito/map/frontend
COPY frontend/ .
RUN yarn install --ignore-engines
RUN yarn run build

FROM node:lts-alpine as build-backend
WORKDIR /home/jackito/map/backend
COPY backend/ .
RUN yarn install --ignore-engines
RUN yarn run build

FROM node:lts
WORKDIR /home/jackito/map

COPY ./entrypoint.sh .

COPY --from=1 /home/jackito/map/backend/prisma/schema.prisma ./backend/prisma/schema.prisma
COPY --from=0 /home/jackito/map/frontend/dist ./frontend/dist

WORKDIR /home/jackito/map/backend
COPY ./backend/package.json .
RUN yarn install --ignore-engines --prod
COPY --from=1 /home/jackito/map/backend/dist .
RUN npx prisma generate

RUN ["chmod", "+x", "/home/jackito/map/entrypoint.sh"]
EXPOSE 8899

ENTRYPOINT /home/jackito/map/entrypoint.sh
