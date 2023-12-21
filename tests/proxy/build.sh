yarn --frozen-lockfile
yarn build
cp -rf hosting/proxy/* ./
docker buildx build . --output type=docker,name=elestio4test/budibase-server:latest | docker load