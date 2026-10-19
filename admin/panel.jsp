<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Panel del Administrador. Contadores de solo lectura (usuarios por rol y
     proyectos en curso/finalizados) y accesos rápidos a su gestión. --%>
<sql:query var="usuariosPorRol" dataSource="${db}"
           sql="SELECT r.id_rol, r.nombre, COUNT(u.id_usuario) AS n FROM rol r LEFT JOIN usuario u ON u.id_rol = r.id_rol GROUP BY r.id_rol, r.nombre ORDER BY r.id_rol"/>
<sql:query var="proysCurso" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE finalizado = 0"/>
<sql:query var="proysFin" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE finalizado = 1"/>
<c:set var="nCurso" value="${proysCurso.rows[0].n}"/>
<c:set var="nFin" value="${proysFin.rows[0].n}"/>
<%-- M9-E C1: consultas de solo lectura para los gráficos del panel. Los
     porcentajes los calcula la base (ROUND/GREATEST) para no dividir en EL. --%>
<sql:query var="proyEstado" dataSource="${db}"
           sql="SELECT COUNT(*) AS total, COALESCE(SUM(finalizado = 0), 0) AS curso, COALESCE(SUM(finalizado = 1), 0) AS fin,
                       ROUND(COALESCE(SUM(finalizado = 0), 0) * 100.0 / GREATEST(COUNT(*), 1)) AS pct_curso,
                       ROUND(COALESCE(SUM(finalizado = 1), 0) * 100.0 / GREATEST(COUNT(*), 1)) AS pct_fin
                FROM proyecto"/>
<sql:query var="proyFase" dataSource="${db}"
           sql="SELECT t.etiqueta AS etiqueta, t.n AS n, ROUND(t.n * 100.0 / GREATEST(MAX(t.n) OVER (), 1)) AS pct
                FROM (SELECT f.id_fase, f.nombre AS etiqueta, COUNT(p.id_proyecto) AS n
                      FROM fase f LEFT JOIN proyecto p ON p.id_fase = f.id_fase
                      GROUP BY f.id_fase, f.nombre) t
                ORDER BY t.id_fase"/>
<sql:query var="usuariosGrafico" dataSource="${db}"
           sql="SELECT t.etiqueta AS etiqueta, t.n AS n, ROUND(t.n * 100.0 / GREATEST(MAX(t.n) OVER (), 1)) AS pct
                FROM (SELECT r.id_rol, r.nombre AS etiqueta, COUNT(u.id_usuario) AS n
                      FROM rol r LEFT JOIN usuario u ON u.id_rol = r.id_rol
                      GROUP BY r.id_rol, r.nombre) t
                ORDER BY t.id_rol"/>
<sql:query var="nUsuarios" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM usuario"/>
<c:set var="nUsuariosTotal" value="${nUsuarios.rows[0].n}"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Panel del Administrador — Sistemas TG</title>
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
        <svg class="icono" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-candado"/></svg>
      </span>
      <div class="cabecera-rol-texto">
        <h1>Panel del Administrador</h1>
        <p class="cabecera-rol-saludo">Hola, <strong><c:out value="${sessionScope.usuarioNombre}"/></strong> · <span class="insignia insignia-rol"><c:out value="${sessionScope.rolNombre}"/></span></p>
      </div>
    </div>

    <h2>Qué necesita tu atención</h2>
    <ul class="rejilla-contadores">
      <c:forEach var="r" items="${usuariosPorRol.rows}">
        <c:choose>
          <c:when test="${r.id_rol == 1}"><c:set var="iconoRol" value="i-candado"/></c:when>
          <c:when test="${r.id_rol == 2}"><c:set var="iconoRol" value="i-check"/></c:when>
          <c:when test="${r.id_rol == 3}"><c:set var="iconoRol" value="i-bombilla"/></c:when>
          <c:otherwise><c:set var="iconoRol" value="i-diploma"/></c:otherwise>
        </c:choose>
        <li>
          <a class="tarjeta-contador tarjeta-contador-al-dia" href="${pageContext.request.contextPath}/admin/usuarios.jsp">
            <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#${iconoRol}"/></svg></span>
            <span class="contador-numero" data-contador="rol-${r.id_rol}"><c:out value="${r.n}"/></span>
            <span class="contador-etiqueta"><c:out value="${r.nombre}"/></span>
            <span class="contador-detalle">Usuarios con este rol</span>
          </a>
        </li>
      </c:forEach>
      <li>
        <a class="tarjeta-contador ${nCurso > 0 ? 'tarjeta-contador-pendiente' : 'tarjeta-contador-al-dia'}" href="${pageContext.request.contextPath}/admin/proyectos.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-curso"><c:out value="${nCurso}"/></span>
          <span class="contador-etiqueta">Proyectos en curso</span>
          <span class="contador-detalle">Trabajos en proceso</span>
          <span class="contador-estado">${nCurso > 0 ? 'Por acompañar' : 'Todo al día'}</span>
        </a>
      </li>
      <li>
        <a class="tarjeta-contador tarjeta-contador-al-dia" href="${pageContext.request.contextPath}/admin/proyectos.jsp">
          <span class="tarjeta-contador-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-check"/></svg></span>
          <span class="contador-numero" data-contador="proyectos-finalizados"><c:out value="${nFin}"/></span>
          <span class="contador-etiqueta">Proyectos finalizados</span>
          <span class="contador-detalle">Procesos cerrados</span>
          <span class="contador-estado">Cerrados</span>
        </a>
      </li>
    </ul>

    <h2>Resumen visual</h2>
    <div class="rejilla-graficos">
      <%-- Donut: proyectos en curso y finalizados (valores calculados en la BD). --%>
      <figure class="grafico" data-grafico="admin-proyectos-estado">
        <figcaption class="grafico-titulo">Proyectos en curso y finalizados</figcaption>
        <c:choose>
          <c:when test="${proyEstado.rows[0].total > 0}">
            <div class="donut">
              <svg class="donut-svg" viewBox="0 0 36 36" role="img" aria-label="Proyectos en curso y finalizados. Los valores están en la tabla de datos del gráfico.">
                <circle class="donut-pista" cx="18" cy="18" r="15.9155" fill="none" stroke-width="4"/>
                <circle class="donut-curso" cx="18" cy="18" r="15.9155" fill="none" stroke-width="4" stroke-dasharray="${proyEstado.rows[0].pct_curso} 100" stroke-dashoffset="25"/>
                <circle class="donut-fin" cx="18" cy="18" r="15.9155" fill="none" stroke-width="4" stroke-dasharray="${proyEstado.rows[0].pct_fin} 100" stroke-dashoffset="${25 - proyEstado.rows[0].pct_curso}"/>
              </svg>
              <ul class="donut-leyenda">
                <li><span class="donut-punto donut-punto-curso" aria-hidden="true"></span>En curso <strong><c:out value="${proyEstado.rows[0].curso}"/></strong></li>
                <li><span class="donut-punto donut-punto-fin" aria-hidden="true"></span>Finalizados <strong><c:out value="${proyEstado.rows[0].fin}"/></strong></li>
              </ul>
            </div>
          </c:when>
          <c:otherwise>
            <p class="grafico-vacio">Sin datos todavía.</p>
          </c:otherwise>
        </c:choose>
        <table class="solo-lectores">
          <caption>Proyectos en curso y finalizados</caption>
          <thead><tr><th scope="col">Estado</th><th scope="col">Proyectos</th></tr></thead>
          <tbody>
            <tr data-etiqueta="En curso" data-valor="${proyEstado.rows[0].curso}"><th scope="row">En curso</th><td><c:out value="${proyEstado.rows[0].curso}"/></td></tr>
            <tr data-etiqueta="Finalizados" data-valor="${proyEstado.rows[0].fin}"><th scope="row">Finalizados</th><td><c:out value="${proyEstado.rows[0].fin}"/></td></tr>
          </tbody>
        </table>
      </figure>

      <c:set var="barrasId" value="admin-proyectos-fase"/>
      <c:set var="barrasTitulo" value="Proyectos por fase"/>
      <c:set var="barrasColEtiqueta" value="Fase"/>
      <c:set var="barrasColValor" value="Proyectos"/>
      <c:set var="barrasRows" value="${proyFase.rows}"/>
      <c:set var="barrasTotal" value="${proyEstado.rows[0].total}"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-barras.jsp" %>

      <c:set var="barrasId" value="admin-usuarios-rol"/>
      <c:set var="barrasTitulo" value="Usuarios por rol"/>
      <c:set var="barrasColEtiqueta" value="Rol"/>
      <c:set var="barrasColValor" value="Usuarios"/>
      <c:set var="barrasRows" value="${usuariosGrafico.rows}"/>
      <c:set var="barrasTotal" value="${nUsuariosTotal}"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-barras.jsp" %>
    </div>

    <h2>Accesos rápidos</h2>
    <ul class="accesos-rapidos">
      <li><a class="boton boton-primario" href="${pageContext.request.contextPath}/admin/usuario-form.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-mas"/></svg>Nuevo usuario</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/admin/usuarios.jsp">Usuarios</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/admin/proyectos.jsp">Proyectos</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/admin/recursos.jsp">Calendario y formatos</a></li>
    </ul>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
