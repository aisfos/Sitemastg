<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  proyectos.jsp — Listado de proyectos del Comité (req. 62, 68, 72, 18).
  Muestra TODOS los proyectos desde v_proyecto (req. 62). El botón "Gestionar fases"
  (req. 8) solo se habilita cuando el turno (id_rol_proceso = 4, "Fase N | Comité")
  es del Comité y el proyecto no está finalizado; en los demás casos aparece
  deshabilitado (atributo disabled real), con una pista del estado actual (req. 8b)
  y el seguimiento de las seis fases siempre visible (req. 6, 7).
  El Comité no crea proyectos aquí; solo gestiona los que están en su turno.
--%>
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
    <div class="barra-titulo">
      <h1>Proyectos</h1>
    </div>
    <p class="aviso">Todos los proyectos del sistema. El botón <strong>Gestionar fases</strong> se habilita solo cuando el turno es del Comité y el proyecto no está finalizado.</p>
    <sql:query var="proyectos" dataSource="${db}"
               sql="SELECT id_proyecto, id_estudiante1, estudiante1, id_estudiante2, estudiante2,
                           titulo, id_director, director, id_evaluador, evaluador,
                           estado, id_fase, id_rol_proceso, rol_turno, finalizado
                    FROM v_proyecto ORDER BY id_proyecto"/>
    <c:choose>
      <c:when test="${proyectos.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">Todavía no hay proyectos registrados en el sistema</h3>
          <p class="vacio-texto">Cuando existan, aquí verás todos los proyectos y podrás gestionar las fases del Comité.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Estudiante 1</th><th>Estudiante 2</th><th>Título</th>
                <th>Director</th><th>Evaluador</th><th>Estado</th><th>Seguimiento</th><th>Acciones</th>
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
                      <c:when test="${empty p.director}">Por asignar</c:when>
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
                      <c:when test="${empty p.evaluador}">Por asignar</c:when>
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
                  <td><span class="insignia insignia-rol"><c:out value="${p.estado}"/></span></td>
                  <td>
                    <details class="detalle-fases">
                      <summary>Seguimiento</summary>
                      <c:set var="faseActual" value="${p.id_fase}"/>
                      <c:set var="finalizado" value="${p.finalizado}"/>
                      <%@ include file="/WEB-INF/fragmentos/seguimiento-fases.jsp" %>
                    </details>
                  </td>
                  <td class="acciones">
                    <c:if test="${p.id_rol_proceso == 4 and not p.finalizado}">
                      <span class="pastilla-turno"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>Tu turno</span>
                    </c:if>
                    <c:choose>
                      <c:when test="${p.id_rol_proceso == 4 and not p.finalizado}">
                        <a class="boton boton-primario boton-pequeno" href="${pageContext.request.contextPath}/comite/gestionar-fase.jsp?id=<c:out value='${p.id_proyecto}'/>">Gestionar fases</a>
                      </c:when>
                      <c:otherwise>
                        <button class="boton boton-deshabilitado boton-pequeno" type="button" disabled title="Solo cuando el turno es del Comité">Gestionar fases</button>
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
