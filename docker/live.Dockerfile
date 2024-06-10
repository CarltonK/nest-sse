FROM node:20.12.1-alpine As build

# # See https://github.com/prisma/prisma/issues/13717
# RUN apk add --no-cache libc6-compat openssl

WORKDIR /usr/src/app

# Install dev dependencies for build
COPY --chown=node:node package*.json ./
# # Prisma types must be inserted into node modules during install
# COPY --chown=node:node prisma ./prisma
RUN npm ci
COPY --chown=node:node . .
# RUN npx prisma generate
RUN npm run build

# Cleanup node modules to be production only
ENV NODE_ENV production
RUN npm ci --only=production && npm cache clean --force

USER node

FROM node:20.12.1-alpine As production

# RUN apk add --no-cache libc6-compat openssl

WORKDIR /app

# Copy only required production build files, no src
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
# COPY --chown=node:node --from=build /usr/src/app/prisma ./prisma
COPY --chown=node:node --from=build /usr/src/app/package.json ./

RUN npm i -g ts-node

ENV PATH /app/node_modules/.bin:$PATH

RUN chown node:node .

USER node

CMD [ "npm", "run", "start" ]