#!/bin/sh
ERMIS_SERVER="$(dirname "$0")/bin/ermis-server-1.0.0-rc1.jar"
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
  sudo $JAVA_HOME/bin/java -jar $VM_ARGUMENTS $ERMIS_SERVER $PROGRAM_ARGUMENTS
else
  sudo java -jar $VM_ARGUMENTS $ERMIS_SERVER $PROGRAM_ARGUMENTS
fi

