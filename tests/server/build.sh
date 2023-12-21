yarn --frozen-lockfile
yarn build
cp -f packages/server/Dockerfile ./
docker buildx build . --output type=docker,name=elestio4test/budibase-server:latest | docker load