<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Panel del Estudiante. Una tarjeta grande por proyecto propio con el estado
     actual, el seguimiento de las seis fases y la acción cuando es su turno.
     Nunca muestra al evaluador (req. 95). --%>
<sql:query var="misProyectos" dataSource="${db}"
           sql="SELECT id_proyecto, titulo, estado, finalizado, director, estado_idea, id_fase, rol_turno, radicado,
                       ROUND((CASE WHEN finalizado = 1 THEN 6 ELSE id_fase END) * 100.0 / 6) AS pct
                FROM v_proyecto_estudiante WHERE id_estudiante1 = ? ORDER BY id_proyecto">
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Panel del Estudiante — Sistemas TG</title>
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
        <svg class="icono" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-diploma"/></svg>
      </span>
      <div class="cabecera-rol-texto">
        <h1>Panel del Estudiante</h1>
        <p class="cabecera-rol-saludo">Hola, <strong><c:out value="${sessionScope.usuarioNombre}"/></strong> · <span class="insignia insignia-rol"><c:out value="${sessionScope.rolNombre}"/></span></p>
      </div>
    </div>

    <h2>Mi trabajo de grado</h2>
    <c:choose>
      <c:when test="${misProyectos.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">Aún no tienes un trabajo de grado</h3>
          <p class="vacio-texto">Toma una idea aprobada del banco de ideas o propone la tuya para crear tu proyecto.</p>
          <div class="vacio-acciones">
            <a class="boton boton-primario" href="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp">Ver banco de ideas</a>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/idea-propia.jsp">Proponer idea propia</a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="p" items="${misProyectos.rows}">
          <article class="tarjeta tarjeta-proyecto">
            <h3 class="proyecto-titulo"><c:out value="${p.titulo}"/></h3>
            <p class="ayuda">Director: <strong><c:out value="${empty p.director ? 'Por asignar' : p.director}"/></strong></p>
            <p>
              <span class="insignia insignia-rol insignia-grande">
                <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>
                <c:out value="${p.estado}"/>
              </span>
            </p>
            <div class="proyecto-progreso">
              <c:set var="anilloId" value="${p.id_proyecto}"/>
              <c:set var="anilloFase" value="${p.id_fase}"/>
              <c:set var="anilloPct" value="${p.pct}"/>
              <c:set var="anilloEtiqueta" value="Fase ${p.id_fase} de 6"/>
              <%@ include file="/WEB-INF/fragmentos/grafico-anillo.jsp" %>
            </div>
            <c:set var="faseActual" value="${p.id_fase}"/>
            <c:set var="finalizado" value="${p.finalizado}"/>
            <%@ include file="/WEB-INF/fragmentos/seguimiento-fases.jsp" %>
            <c:choose>
              <c:when test="${p.finalizado}">
                <c:set var="celebracionRadicado" value="${p.radicado}"/>
                <%@ include file="/WEB-INF/fragmentos/celebracion.jsp" %>
              </c:when>
              <c:when test="${p.rol_turno == 'Estudiante'}">
                <p class="llamado-turno">
                  <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>
                  <span class="llamado-turno-texto">Es tu turno</span>
                  <span>${p.id_fase == 1 ? 'Corrige tu idea y vuelve a enviarla.' : 'Envía el documento de esta fase.'}</span>
                  <a class="boton boton-primario llamado-turno-accion" href="${pageContext.request.contextPath}${p.id_fase == 1 ? '/estudiante/corregir-idea.jsp' : '/estudiante/enviar-documento.jsp'}?id=${p.id_proyecto}">${p.id_fase == 1 ? 'Corregir idea' : 'Enviar documento'}</a>
                </p>
              </c:when>
              <c:otherwise>
                <p class="aviso-revision">
                  <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj-arena"/></svg>
                  En revisión: <strong><c:out value="${p.estado}"/></strong>. Te avisaremos cuando sea tu turno.
                </p>
              </c:otherwise>
            </c:choose>
            <p><a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyecto.jsp?id=${p.id_proyecto}">Ver detalle</a></p>
          </article>
        </c:forEach>
      </c:otherwise>
    </c:choose>

    <h2>Accesos rápidos</h2>
    <ul class="accesos-rapidos">
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyectos.jsp">Mis proyectos</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp">Banco de ideas</a></li>
      <li><a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/idea-propia.jsp">Proponer idea propia</a></li>
    </ul>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
