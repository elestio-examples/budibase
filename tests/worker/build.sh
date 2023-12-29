#!/usr/bin/env bash
yarn --frozen-lockfile
yarn build
cp -f packages/worker/Dockerfile ./
docker buildx build . --output type=docker,name=elestio4test/budibase-worker:latest | docker load