<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Panel del Docente. Contadores de lo que espera su gestión: proyectos en su
     turno (como director o evaluador) e ideas aplazadas por corregir. --%>
<sql:query var="nTurno" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM v_proyecto WHERE finalizado = 0 AND ((id_director = ? AND rol_turno = 'Director') OR (id_evaluador = ? AND rol_turno = 'Evaluador'))">
  <sql:param value="${sessionScope.usuarioId}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="nAplazadas" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM v_idea_docente WHERE id_docente = ? AND estado = 'APLAZADA'">
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:set var="nTurno" value="${nTurno.rows[0].n}"/>
<c:set var="nAplazadas" value="${nAplazadas.rows[0].n}"/>
<%-- M9-E C1: consultas de solo lectura para los gráficos. Solo los proyectos del
     docente en sesión (como director o evaluador); el evaluador nunca lo ve el
     estudiante. --%>
<sql:query var="misFases" dataSource="${db}"
           sql="SELECT t.etiqueta AS etiqueta, t.n AS n, ROUND(t.n * 100.0 / GREATEST(MAX(t.n) OVER (), 1)) AS pct
                FROM (SELECT f.id_fase, f.nombre AS etiqueta, COUNT(p.id_proyecto) AS n
                      FROM fase f
                      LEFT JOIN v_proyecto p ON p.id_fase = f.id_fase AND (p.id_director = ? OR p.id_evaluador = ?)
                      GROUP BY f.id_fase, f.nombre) t
                ORDER BY t.id_fase">
  <sql:param value="${sessionScope.usuarioId}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="misRoles" dataSource="${db}"
           sql="SELECT t.etiqueta AS etiqueta, t.n AS n, ROUND(t.n * 100.0 / GREATEST(MAX(t.n) OVER (), 1)) AS pct
                FROM (SELECT 'Director' AS etiqueta, 1 AS orden, COUNT(*) AS n FROM v_proyecto WHERE id_director = ?
                      UNION ALL
                      SELECT 'Evaluador', 2, COUNT(*) FROM v_proyecto WHERE id_evaluador = ?) t
                ORDER BY t.orden">
  <sql:param value="${sessionScope.usuarioId}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="nMisProys" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM v_proyecto WHERE id_director = ? OR id_evaluador = ?">
  <sql:param value="${sessionScope.usuarioId}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:set var="nMisProysTotal" value="${nMisProys.rows[0].n}"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Panel del Docente — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <div class="cabecera-rol">
      <span class="cabecera-rol-avatar" aria-hidden="true">
        <svg class="icono" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-bombilla"/></svg>
      </span>
      <div class="cabecera-rol-texto">
        <h1>Panel del Docente</h1>
        <p class="cabecera-rol-saludo">Hola, <strong><c:out value="${sessionScope.usuarioNombre}"/></strong> · <span class="insignia insignia-rol"><c:out value="${sessionScope.rolNombre}"/></span></p>
      </div>
    </div>

    <h2>Qué necesita tu atención</h2>
    <ul class="rejilla-contadores">
      <li>
        <a class="tarjeta-contador ${nTurno > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/docente/proyectos.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-mi-turno"><c:out value="${nTurno}"/></span>
          <span class="contador-etiqueta">Proyectos en tu turno</span>
          <span class="contador-detalle">Como director o evaluador</span>
          <span class="contador-estado">${nTurno > 0 ? 'Es tu turno' : 'Todo al día'}</span>
        </a>
      </li>
      <li>
        <a class="tarjeta-contador ${nAplazadas > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/docente/ideas.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-editar"/></svg></span>
          <span class="contador-numero" data-contador="ideas-aplazadas"><c:out value="${nAplazadas}"/></span>
          <span class="contador-etiqueta">Ideas aplazadas</span>
          <span class="contador-detalle">Para corregir y volver a enviar</span>
          <span class="contador-estado">${nAplazadas > 0 ? 'Por corregir' : 'Todo al día'}</span>
        </a>
      </li>
    </ul>

    <h2>Resumen visual</h2>
    <div class="rejilla-graficos">
      <c:set var="barrasId" value="docente-proyectos-fase"/>
      <c:set var="barrasTitulo" value="Mis proyectos por fase"/>
      <c:set var="barrasColEtiqueta" value="Fase"/>
      <c:set var="barrasColValor" value="Proyectos"/>
      <c:set var="barrasRows" value="${misFases.rows}"/>
      <c:set var="barrasTotal" value="${nMisProysTotal}"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-barras.jsp" %>

      <c:set var="barrasId" value="docente-proyectos-rol"/>
      <c:set var="barrasTitulo" value="Mis proyectos por rol"/>
      <c:set var="barrasColEtiqueta" value="Rol"/>
      <c:set var="barrasColValor" value="Proyectos"/>
      <c:set var="barrasRows" value="${misRoles.rows}"/>
      <c:set var="barrasTotal" value="${nMisProysTotal}"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-barras.jsp" %>
    </div>

    <h2>Accesos rápidos</h2>
    <ul class="accesos-rapidos">
      <li><a class="boton boton-primario" href="${pageContext.request.contextPath}/docente/proyectos.jsp">Mis proyectos</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/docente/ideas.jsp">Mis ideas</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/docente/idea-form.jsp">Proponer idea</a></li>
    </ul>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
