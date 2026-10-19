<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Panel del Comité. Contadores de lo pendiente (ideas por revisar y proyectos
     en su turno en las fases 1, 3, 5 y 6) y accesos a su gestión. --%>
<sql:query var="nIdeasDoc" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM idea_docente WHERE estado = 'PENDIENTE'"/>
<sql:query var="nFase1" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_fase = 1 AND id_rol_proceso = 4 AND finalizado = 0"/>
<sql:query var="nFase3" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_fase = 3 AND id_rol_proceso = 4 AND finalizado = 0"/>
<sql:query var="nFase5" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_fase = 5 AND id_rol_proceso = 4 AND finalizado = 0"/>
<sql:query var="nFase6" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_fase = 6 AND id_rol_proceso = 4 AND finalizado = 0"/>
<c:set var="nIdeasDoc" value="${nIdeasDoc.rows[0].n}"/>
<c:set var="nFase1" value="${nFase1.rows[0].n}"/>
<c:set var="nFase3" value="${nFase3.rows[0].n}"/>
<c:set var="nFase5" value="${nFase5.rows[0].n}"/>
<c:set var="nFase6" value="${nFase6.rows[0].n}"/>
<%-- M9-E C1: consultas de solo lectura para los gráficos del panel. Las ideas se
     muestran siempre en sus tres estados (categorías fijas). --%>
<sql:query var="ideasEstado" dataSource="${db}"
           sql="SELECT t.etiqueta AS etiqueta, t.n AS n, ROUND(t.n * 100.0 / GREATEST(MAX(t.n) OVER (), 1)) AS pct
                FROM (SELECT e.estado AS etiqueta, e.orden AS orden, COALESCE(i.n, 0) AS n
                      FROM (SELECT 'PENDIENTE' AS estado, 1 AS orden UNION SELECT 'APROBADA', 2 UNION SELECT 'APLAZADA', 3) e
                      LEFT JOIN (SELECT estado, COUNT(*) AS n FROM idea_docente GROUP BY estado) i ON i.estado = e.estado) t
                ORDER BY t.orden"/>
<sql:query var="proyPorFase" dataSource="${db}"
           sql="SELECT t.etiqueta AS etiqueta, t.n AS n, ROUND(t.n * 100.0 / GREATEST(MAX(t.n) OVER (), 1)) AS pct
                FROM (SELECT f.id_fase, f.nombre AS etiqueta, COUNT(p.id_proyecto) AS n
                      FROM fase f LEFT JOIN proyecto p ON p.id_fase = f.id_fase
                      GROUP BY f.id_fase, f.nombre) t
                ORDER BY t.id_fase"/>
<sql:query var="nTotalIdeas" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM idea_docente"/>
<sql:query var="nTotalProys" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto"/>
<c:set var="nTotalIdeas" value="${nTotalIdeas.rows[0].n}"/>
<c:set var="nTotalProys" value="${nTotalProys.rows[0].n}"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Panel del Comité — Sistemas TG</title>
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
        <svg class="icono" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-check"/></svg>
      </span>
      <div class="cabecera-rol-texto">
        <h1>Panel del Comité</h1>
        <p class="cabecera-rol-saludo">Hola, <strong><c:out value="${sessionScope.usuarioNombre}"/></strong> · <span class="insignia insignia-rol"><c:out value="${sessionScope.rolNombre}"/></span></p>
      </div>
    </div>

    <h2>Qué necesita tu atención</h2>
    <ul class="rejilla-contadores">
      <li>
        <a class="tarjeta-contador ${nIdeasDoc > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/comite/ideas-docentes.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-bombilla"/></svg></span>
          <span class="contador-numero" data-contador="ideas-docentes-pendientes"><c:out value="${nIdeasDoc}"/></span>
          <span class="contador-etiqueta">Ideas de docentes por revisar</span>
          <span class="contador-detalle">Ideas en estado pendiente</span>
          <span class="contador-estado">${nIdeasDoc > 0 ? 'Por revisar' : 'Todo al día'}</span>
        </a>
      </li>
      <li>
        <a class="tarjeta-contador ${nFase1 > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-fase1-comite"><c:out value="${nFase1}"/></span>
          <span class="contador-etiqueta">Ideas de estudiantes en Fase 1</span>
          <span class="contador-detalle">Fase 1 | Comité</span>
          <span class="contador-estado">${nFase1 > 0 ? 'Por revisar' : 'Todo al día'}</span>
        </a>
      </li>
      <li>
        <a class="tarjeta-contador ${nFase3 > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/comite/proyectos.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-fase3-comite"><c:out value="${nFase3}"/></span>
          <span class="contador-etiqueta">Propuestas en Fase 3</span>
          <span class="contador-detalle">Fase 3 | Comité</span>
          <span class="contador-estado">${nFase3 > 0 ? 'Por calificar' : 'Todo al día'}</span>
        </a>
      </li>
      <li>
        <a class="tarjeta-contador ${nFase5 > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/comite/proyectos.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-fase5-comite"><c:out value="${nFase5}"/></span>
          <span class="contador-etiqueta">Informes en Fase 5</span>
          <span class="contador-detalle">Fase 5 | Comité</span>
          <span class="contador-estado">${nFase5 > 0 ? 'Por calificar' : 'Todo al día'}</span>
        </a>
      </li>
      <li>
        <a class="tarjeta-contador ${nFase6 > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/comite/proyectos.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-check"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-fase6-comite"><c:out value="${nFase6}"/></span>
          <span class="contador-etiqueta">Proyectos por cerrar en Fase 6</span>
          <span class="contador-detalle">Fase 6 | Comité</span>
          <span class="contador-estado">${nFase6 > 0 ? 'Por cerrar' : 'Todo al día'}</span>
        </a>
      </li>
    </ul>

    <h2>Resumen visual</h2>
    <div class="rejilla-graficos">
      <c:set var="barrasId" value="comite-ideas-estado"/>
      <c:set var="barrasTitulo" value="Ideas del banco por estado"/>
      <c:set var="barrasColEtiqueta" value="Estado"/>
      <c:set var="barrasColValor" value="Ideas"/>
      <c:set var="barrasRows" value="${ideasEstado.rows}"/>
      <c:set var="barrasTotal" value="${nTotalIdeas}"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-barras.jsp" %>

      <c:set var="barrasId" value="comite-proyectos-fase"/>
      <c:set var="barrasTitulo" value="Proyectos por fase"/>
      <c:set var="barrasColEtiqueta" value="Fase"/>
      <c:set var="barrasColValor" value="Proyectos"/>
      <c:set var="barrasRows" value="${proyPorFase.rows}"/>
      <c:set var="barrasTotal" value="${nTotalProys}"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-barras.jsp" %>
    </div>

    <h2>Accesos rápidos</h2>
    <ul class="lista-enlaces">
      <li><a href="${pageContext.request.contextPath}/comite/ideas-docentes.jsp">Banco de ideas docente</a> — revisar, aprobar, aplazar, editar y eliminar las ideas propuestas por los docentes.</li>
      <li><a href="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp">Ideas de estudiantes</a> — revisar el soporte de pago, aprobar (asignando director y evaluador) o aplazar las ideas de los estudiantes.</li>
      <li><a href="${pageContext.request.contextPath}/comite/proyectos.jsp">Proyectos</a> — listado de todos los proyectos y gestión de las fases 1, 3, 5 y 6 (aprobar o aplazar con acta, y cerrar con radicado).</li>
    </ul>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
