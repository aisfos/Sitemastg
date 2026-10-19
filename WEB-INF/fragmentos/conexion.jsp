<%--
  conexion.jsp — Único punto de configuración de la base de datos.

  Prioridad: variables de entorno DB_HOST, DB_PORT, DB_NAME, DB_USER y
  DB_PASSWORD. Si alguna no está definida, se usa el valor por defecto de la
  base Aiven de este proyecto.

  SSL: sslMode=REQUIRED siempre (Aiven exige TLS). En atributos JSP el & va
  crudo, no como &amp; (ver docs/AGENTS.md §13).
--%>
<c:set var="dbHost" value="${System.getenv('DB_HOST')}"/>
<c:set var="dbPort" value="${System.getenv('DB_PORT')}"/>
<c:set var="dbName" value="${System.getenv('DB_NAME')}"/>
<c:set var="dbUser" value="${System.getenv('DB_USER')}"/>
<c:set var="dbPassword" value="${System.getenv('DB_PASSWORD')}"/>

<c:if test="${empty dbHost}"><c:set var="dbHost" value="mysql-10db8214-sistemastg.c.aivencloud.com"/></c:if>
<c:if test="${empty dbPort}"><c:set var="dbPort" value="27151"/></c:if>
<c:if test="${empty dbName}"><c:set var="dbName" value="defaultdb"/></c:if>
<c:if test="${empty dbUser}"><c:set var="dbUser" value="avnadmin"/></c:if>
<c:if test="${empty dbPassword}"><c:set var="dbPassword" value="AVNS_lZMKEqkuXWGN6TORns4"/></c:if>

<c:set var="dbUrl" value="jdbc:mysql://${dbHost}:${dbPort}/${dbName}?sslMode=REQUIRED&characterEncoding=UTF-8&serverTimezone=America/Bogota&useOldAliasMetadataBehavior=true"/>

<sql:setDataSource var="db"
                   driver="com.mysql.cj.jdbc.Driver"
                   url="${dbUrl}"
                   user="${dbUser}"
                   password="${dbPassword}"/>
