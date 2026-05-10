#!/bin/sh
set -e

# Copy secrets to a readable location for ermis_docker user
mkdir -p /run/credentials/ermis-server.service
cp -r /run/secrets/* /run/credentials/ermis-server.service/
chown -R ermis_docker:ermis_docker /run/credentials/ermis-server.service/
chmod 400 /run/credentials/ermis-server.service/*

exec gosu ermis_docker java \
  -Djava.security.egd=file:/dev/./urandom \
  -server \
  -XX:+UseZGC \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=75.0 \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  --add-opens java.base/jdk.internal.misc=ALL-UNNAMED \
  --add-opens java.base/java.nio=ALL-UNNAMED \
  -Dio.netty.tryReflectionSetAccessible=true \
  -Dfile.encoding=UTF-8 \
  -jar /app/app.jar
