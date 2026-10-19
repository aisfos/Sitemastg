<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Calendario y formatos de grado: solo lectura (req. 44). URLs como enlaces. --%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Calendario y formatos — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>Calendario y formatos</h1>
    <p class="ayuda">Enlaces institucionales de consulta. Se abren en una pestaña nueva.</p>

    <sql:query var="calendario" dataSource="${db}"
               sql="SELECT nombre, url FROM recurso_institucional WHERE tipo = 'CALENDARIO_ACADEMICO' ORDER BY id_recurso"/>
    <h2>Calendario académico</h2>
    <c:choose>
      <c:when test="${calendario.rowCount == 0}">
        <p class="aviso">No hay calendario académico cargado.</p>
      </c:when>
      <c:otherwise>
        <ul class="lista-enlaces">
          <c:forEach var="r" items="${calendario.rows}">
            <li><a href="<c:out value='${r.url}'/>" target="_blank" rel="noopener"><c:out value="${r.nombre}"/></a></li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>

    <sql:query var="formatos" dataSource="${db}"
               sql="SELECT nombre, url FROM recurso_institucional WHERE tipo = 'FORMATO_GRADO' ORDER BY id_recurso"/>
    <h2>Formatos de grado</h2>
    <c:choose>
      <c:when test="${formatos.rowCount == 0}">
        <p class="aviso">No hay formatos de grado cargados.</p>
      </c:when>
      <c:otherwise>
        <ul class="lista-enlaces">
          <c:forEach var="r" items="${formatos.rows}">
            <li><a href="<c:out value='${r.url}'/>" target="_blank" rel="noopener"><c:out value="${r.nombre}"/></a></li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
