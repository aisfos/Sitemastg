<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Proyectos: el administrador SOLO visualiza (req. 45, 47). Sin acciones ni
     "Gestionar fases" (req. 8c). Muestra el seguimiento de las seis fases (req. 7)
     en cada fila, sin ningún formulario de gestión. --%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Proyectos — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>Proyectos</h1>
    <p class="ayuda">Vista de solo lectura de todo el proceso.</p>
    <sql:query var="proyectos" dataSource="${db}"
               sql="SELECT id_proyecto, id_estudiante1, estudiante1, id_estudiante2, estudiante2, titulo, id_director, director, id_evaluador, evaluador, estado, id_fase, finalizado FROM v_proyecto ORDER BY id_proyecto"/>
    <c:choose>
      <c:when test="${proyectos.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">Todavía no hay proyectos registrados en el sistema</h3>
          <p class="vacio-texto">Cuando los estudiantes creen sus proyectos, aparecerán aquí en modo de solo lectura.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Estudiante 1</th><th>Estudiante 2</th><th>Título</th>
                <th>Director</th><th>Evaluador</th><th>Estado</th><th>Seguimiento</th>
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
                  <td>
                    <c:choose>
                      <c:when test="${empty p.director}">—</c:when>
                      <c:otherwise>
                        <span class="celda-persona">
                          <c:set var="avatarId" value="${p.id_director}"/>
                          <c:set var="avatarNombre" value="${p.director}"/>
                          <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                          <c:out value="${p.director}"/>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${empty p.evaluador}">—</c:when>
                      <c:otherwise>
                        <span class="celda-persona">
                          <c:set var="avatarId" value="${p.id_evaluador}"/>
                          <c:set var="avatarNombre" value="${p.evaluador}"/>
                          <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                          <c:out value="${p.evaluador}"/>
                        </span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td><c:out value="${p.estado}"/></td>
                  <td>
                    <details class="detalle-fases">
                      <summary>Seguimiento</summary>
                      <c:set var="faseActual" value="${p.id_fase}"/>
                      <c:set var="finalizado" value="${p.finalizado}"/>
                      <%@ include file="/WEB-INF/fragmentos/seguimiento-fases.jsp" %>
                    </details>
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
