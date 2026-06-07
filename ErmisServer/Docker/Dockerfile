# Build stage
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy parent POM
COPY pom.xml ./pom.xml

# Copy and install ErmisCommon locally since it is not readily available on Maven Central
COPY ErmisCommon/pom.xml ./ErmisCommon/pom.xml
COPY ErmisCommon/src ./ErmisCommon/src
RUN mvn -f pom.xml install -DskipTests

# Copy ErmisServer and cache dependencies
COPY ErmisServer/pom.xml ./ErmisServer/pom.xml
RUN mvn -f ErmisServer/pom.xml dependency:go-offline -B

# Build ErmisServer
COPY ErmisServer/src ./ErmisServer/src
RUN mvn -f ErmisServer/pom.xml package -DskipTests

FROM eclipse-temurin:21-jdk AS jre-builder
RUN jlink \
    --module-path "$JAVA_HOME/jmods" \
    --add-modules java.base,java.logging,java.xml,java.desktop,java.scripting,jdk.attach,jdk.jdi,jdk.sctp,java.naming,jdk.security.auth,java.security.jgss,java.security.sasl,jdk.crypto.ec,jdk.crypto.cryptoki,java.net.http,jdk.net,java.sql,java.transaction.xa,java.instrument,jdk.unsupported,java.management,java.management.rmi,jdk.management.agent,jdk.naming.dns,java.compiler \
    --strip-debug \
    --no-header-files \
    --no-man-pages \
    --compress=2 \
    --output /opt/jre

# Runtime stage
FROM debian:bookworm-slim

COPY --from=jre-builder /opt/jre /opt/jre

ENV JAVA_HOME=/opt/jre
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /app

# Create required directories
RUN mkdir -p /opt/ermis-server \
    && mkdir -p /etc/ermis-server/configs \
    && mkdir -p /var/lib/ermis-server/profile-photos \
    && mkdir -p /var/lib/ermis-server/user-files

# Copy default config files into the image
COPY ErmisServer/Installers/Unix/DEB/ermis-server-installer_all/etc/ermis-server/configs /etc/ermis-server/configs
COPY ErmisServer/Installers/Unix/DEB/ermis-server-installer_all/etc/nginx/ /etc/nginx/

# Copy static assets
COPY ErmisServer/Installers/Unix/DEB/ermis-server-installer_all/var/ermis-server /var/ermis-server
# RUN ls /etc/ermis-server/configs/

# Copy jar and dependencies
COPY --from=builder /app/ErmisServer/target/ermis-server-*.jar /app/app.jar
COPY --from=builder /app/ErmisServer/target/lib ./lib

# Configure non-root ermis user with explicit user/group IDs
RUN set -eux; \
	groupadd -r ermis_docker --gid=1567; \
	useradd -r -g ermis_docker --uid=1567 ermis_docker; \
    chown -R ermis_docker:ermis_docker /opt/ermis-server; \
    chown -R ermis_docker:ermis_docker /etc/ermis-server; \
    chown -R ermis_docker:ermis_docker /var/lib/ermis-server;

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		gnupg \
		less \
	; \
	rm -rf /var/lib/apt/lists/*

# Grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
ENV GOSU_VERSION 1.19
RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

# Copy and set entrypoint script
COPY ErmisServer/Docker/entrypoint.sh /opt/ermis-server/entrypoint.sh
RUN chmod +x /opt/ermis-server/entrypoint.sh

ENTRYPOINT ["/opt/ermis-server/entrypoint.sh"]
