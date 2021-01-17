mkdir dist || echo "dist already exists";
docker build --tag silver-magpie-extension .
docker run -v $(pwd):/mnt silver-magpie-extension cp dist/build.zip /mnt/dist/build.zip
