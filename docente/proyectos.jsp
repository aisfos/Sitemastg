<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  proyectos.jsp — "Mis proyectos" del Docente (req. 76, 77, 84, 85, 18).
  Vista ÚNICA, sin pestañas ni menús separados: en una sola tabla aparecen los
  proyectos donde el docente en sesión es director y donde es evaluador (req. 85).
  La columna "Mi rol" se calcula con un CASE sobre id_director/id_evaluador; como
  director y evaluador nunca coinciden en un proyecto (req. 9), no hay ambigüedad.
  El botón "Gestionar fases" (req. 8) se habilita solo cuando el proyecto no está
  finalizado y el turno (rol_turno) coincide con "Mi rol"; en cualquier otro caso
  se emite un <button disabled> real con una pista (req. 77) y el seguimiento de
  las seis fases sigue visible.
--%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mis proyectos — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <div class="barra-titulo">
      <h1>Mis proyectos</h1>
    </div>
    <p class="aviso">Proyectos en los que participas como director o evaluador. El botón <strong>Gestionar fases</strong> se habilita solo cuando el turno es tuyo y el proyecto no está finalizado.</p>
    <sql:query var="proyectos" dataSource="${db}"
               sql="SELECT v.id_proyecto, v.id_estudiante1, v.estudiante1, v.id_estudiante2, v.estudiante2, v.titulo, v.estado,
                           v.id_fase, v.rol_turno, v.id_rol_proceso, v.finalizado,
                           v.id_director, v.id_evaluador,
                           CASE WHEN v.id_director = ? THEN 'Director' ELSE 'Evaluador' END AS mi_rol
                    FROM v_proyecto v
                    WHERE v.id_director = ? OR v.id_evaluador = ?
                    ORDER BY v.id_proyecto">
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <c:choose>
      <c:when test="${proyectos.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">Todavía no participas en ningún proyecto</h3>
          <p class="vacio-texto">Aquí aparecerán los proyectos en los que te asignen como director o evaluador.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Estudiante 1</th><th>Estudiante 2</th><th>Título</th>
                <th>Estado</th><th>Mi rol</th><th>Seguimiento</th><th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="p" items="${proyectos.rows}">
                <tr>
                  <td><c:out value="${p.id_proyecto}"/></td>
                  <td>
                    <span class="celda-persona">
                      <c:set var="avatarId" value="${p.id_estudiante1}"/>
                      <c:set var="avatarNombre" value="${p.estudiante1}"/>
                      <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                      <c:out value="${p.estudiante1}"/>
                    </span>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${empty p.estudiante2}">—</c:when>
                      <c:otherwise>
                        <span class="celda-persona">
                          <c:set var="avatarId" value="${p.id_estudiante2}"/>
                          <c:set var="avatarNombre" value="${p.estudiante2}"/>
                          <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                          <c:out value="${p.estudiante2}"/>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td><c:out value="${p.titulo}"/></td>
                  <td><span class="insignia insignia-rol"><c:out value="${p.estado}"/></span></td>
                  <td><span class="insignia insignia-rol"><c:out value="${p.mi_rol}"/></span></td>
                  <td>
                    <details class="detalle-fases">
                      <summary>Seguimiento</summary>
                      <c:set var="faseActual" value="${p.id_fase}"/>
                      <c:set var="finalizado" value="${p.finalizado}"/>
                      <%@ include file="/WEB-INF/fragmentos/seguimiento-fases.jsp" %>
                    </details>
                  </td>
                  <td class="acciones">
                    <c:if test="${not p.finalizado and p.rol_turno == p.mi_rol}">
                      <span class="pastilla-turno"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>Tu turno</span>
                    </c:if>
                    <c:choose>
                      <c:when test="${not p.finalizado and p.rol_turno == p.mi_rol}">
                        <a class="boton boton-primario boton-pequeno" href="${pageContext.request.contextPath}/docente/gestionar-fase.jsp?id=<c:out value='${p.id_proyecto}'/>">Gestionar fases</a>
                      </c:when>
                      <c:otherwise>
                        <button class="boton boton-deshabilitado boton-pequeno" type="button" disabled title="Solo cuando el turno es tuyo">Gestionar fases</button>
                        <span class="pista-fase"><c:out value="${p.estado}"/></span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
