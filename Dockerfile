FROM node:lts-alpine as build-frontend
WORKDIR /home/jackito/home/jackito/app/frontend
COPY frontend/ .
RUN yarn install
RUN yarn run build

FROM node:lts-alpine as build-backend
WORKDIR /home/jackito/home/jackito/app/backend
COPY backend/ .
RUN yarn install
RUN yarn run build

FROM node:lts
WORKDIR /home/jackito/app

COPY ./entrypoint.sh .

COPY --from=1 /home/jackito/app/backend/prisma/schema.prisma ./backend/prisma/schema.prisma
COPY --from=0 /home/jackito/app/frontend/dist ./frontend/dist

WORKDIR /home/jackito/app/backend
COPY ./backend/package.json .
RUN yarn install --prod
COPY --from=1 /home/jackito/app/backend/dist .
RUN npx prisma generate

RUN ["chmod", "+x", "/home/jackito/app/entrypoint.sh"]
EXPOSE 8899

ENTRYPOINT /home/jackito/app/entrypoint.sh
