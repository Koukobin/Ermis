#!/bin/sh

sudo ./apply_server_settings.pl

# Attempt to find server JAR file
ERMIS_SERVER_JAR_FILE=$(find bin -maxdepth 1 -name "*.jar" -print -quit)

# Check if a JAR file was found
if [ -z "$ERMIS_SERVER_JAR_FILE" ]; then
  echo "No JAR file found in the directory!"
  exit 1
fi

VM_ARGUMENTS="
-Djava.security.egd=file:/dev/./urandom 
-server 
-XX:+UseZGC 
--add-opens java.base/java.lang=ALL-UNNAMED 
--add-opens java.base/jdk.internal.misc=ALL-UNNAMED
--add-opens java.base/java.nio=ALL-UNNAMED
-Dio.netty.tryReflectionSetAccessible=true
-Dfile.encoding=UTF-8"
PROGRAM_ARGUMENTS=""

if [ -n "$JAVA_HOME" ]; then
  sudo $JAVA_HOME/bin/java -jar $VM_ARGUMENTS $ERMIS_SERVER_JAR_FILE $PROGRAM_ARGUMENTS
else
  sudo java -jar $VM_ARGUMENTS $ERMIS_SERVER_JAR_FILE $PROGRAM_ARGUMENTS
fi

