# NOTE About prisma DB Connection
- Before running docker-compose, or docker build, generate migrations - `prisma migrate dev` so that the local or remote postgres server has the tables or schema ready. This will come handy in NextJS applications where we have ISR or SSG which needs db connection during build time.

# Docker Compose Installation
- Generate migrations (bun db:migrate-dev)
- Use .env.common file to add db credentials during runtime
- RUN `docker-compose -f ./docker/docker-compose.yml up`
