# Tomcat 8.5 (Servlet 3.1 / JSP 2.3 / javax.servlet) con JDK 11.
FROM tomcat:8.5-jdk11

ENV PORT=8080 \
    MYSQL_CONNECTOR_VERSION=8.0.33

# La aplicación ocupa la raíz del contexto: webapps/ROOT.
RUN rm -rf "${CATALINA_HOME}/webapps/ROOT" \
 && mkdir -p "${CATALINA_HOME}/webapps/ROOT/WEB-INF/lib"

COPY . "${CATALINA_HOME}/webapps/ROOT/"

# El driver no se copia desde el contexto de build: se descarga aquí.
RUN curl -fsSL -o "${CATALINA_HOME}/webapps/ROOT/WEB-INF/lib/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar" \
        "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar" \
 && test -s "${CATALINA_HOME}/webapps/ROOT/WEB-INF/lib/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar"

# Render inyecta PORT en tiempo de ejecución. server.xml queda con ${port} y
# setenv.sh lo resuelve como system property (-Dport) al arrancar Tomcat.
RUN sed -i 's/port="8080"/port="${port}"/' "${CATALINA_HOME}/conf/server.xml" \
 && printf '#!/bin/sh\nexport CATALINA_OPTS="$CATALINA_OPTS -Dport=${PORT:-8080}"\n' > "${CATALINA_HOME}/bin/setenv.sh" \
 && chmod +x "${CATALINA_HOME}/bin/setenv.sh"

EXPOSE 8080

CMD ["catalina.sh", "run"]
