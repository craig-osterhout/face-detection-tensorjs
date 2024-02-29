# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=19.0.0

FROM node:${NODE_VERSION}-alpine

# Use development node environment by default.
ENV NODE_ENV development

WORKDIR /usr/src/app

# Install util-linux to ensure lscpu is available
RUN apk add --no-cache util-linux

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.yarn to speed up subsequent builds.
# Leverage a bind mounts to package.json and yarn.lock to avoid having to copy them into
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=cache,target=/root/.yarn \
    yarn install --frozen-lockfile


# Copy the rest of the source files into the image.
COPY . .

# Create a static directory to store the built assets
RUN mkdir -p static

# Change ownership of the /usr/src/app directory to the 'node' user
RUN chown -R node:node /usr/src/app

# Run the application as a non-root user.
USER node


# Expose the port that the application listens on.
EXPOSE 1234

# Run the application.
CMD yarn watch