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

# Runtime stage
FROM eclipse-temurin:21-jre

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

# Non-root user
RUN groupadd --system ermis_docker 2>/dev/null || addgroup -S ermis_docker \
    && (useradd --system --gid ermis_docker --no-create-home ermis_docker 2>/dev/null \
        || adduser -S -G ermis_docker ermis_docker) \
    && chown -R ermis_docker:ermis_docker /opt/ermis-server \
    && chown -R ermis_docker:ermis_docker /etc/ermis-server \
    && chown -R ermis_docker:ermis_docker /var/lib/ermis-server

RUN mkdir -p /var/ermis-server/log/server-logs \
    && chown -R ermis_docker:ermis_docker /var/ermis-server

# Install gosu manually with GPG verification and
# subsequently remove redundant packages to reduce:
#   1. image size
#   2. attack surface
#   3. CVE reports by Docker Scout (main reason)
RUN set -eux; \
    GOSU_VERSION=1.17; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    apt-get update; \
    apt-get install -y --no-install-recommends wget gnupg; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}.asc"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm /usr/local/bin/gosu.asc; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true; \
    apt-get remove -y wget gnupg; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

# Copy and set entrypoint script
COPY ErmisServer/Docker/entrypoint.sh /opt/ermis-server/entrypoint.sh
RUN chmod +x /opt/ermis-server/entrypoint.sh

ENTRYPOINT ["/opt/ermis-server/entrypoint.sh"]
