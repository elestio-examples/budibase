#!/usr/bin/env bash
yarn --frozen-lockfile
yarn build
cp -f packages/server/Dockerfile ./
docker buildx build . --output type=docker,name=elestio4test/budibase-apps:latest | docker load