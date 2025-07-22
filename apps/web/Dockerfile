FROM oven/bun:alpine AS base

# Install dependencies and build the application
FROM base AS builder

WORKDIR /app

COPY package.json package.json
COPY bun.lock bun.lock
COPY turbo.json turbo.json

COPY apps/web/package.json apps/web/package.json
COPY packages/db/package.json packages/db/package.json
COPY packages/auth/package.json packages/auth/package.json

RUN bun install

COPY apps/web/ apps/web/
COPY packages/db/ packages/db/
COPY packages/auth/ packages/auth/

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1
#
ARG DATABASE_URL
ARG BETTER_AUTH_SECRET
ARG UPSTASH_REDIS_REST_URL
ARG UPSTASH_REDIS_REST_TOKEN
ARG NEXT_PUBLIC_BETTER_AUTH_URL
ENV DATABASE_URL=$DATABASE_URL
ENV BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
ENV UPSTASH_REDIS_REST_URL=$UPSTASH_REDIS_REST_URL
ENV UPSTASH_REDIS_REST_TOKEN=$UPSTASH_REDIS_REST_TOKEN
ENV NEXT_PUBLIC_BETTER_AUTH_URL=$NEXT_PUBLIC_BETTER_AUTH_URL

WORKDIR /app/apps/web
RUN bun run db:migrate
RUN bun run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/apps/web/public ./apps/web/public
COPY --from=builder --chown=nextjs:nodejs /app/apps/web/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/apps/web/.next/static ./apps/web/.next/static

RUN chown nextjs:nodejs apps

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["bun", "apps/web/server.js"]
