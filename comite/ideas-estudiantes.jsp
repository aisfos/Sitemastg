<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  ideas-estudiantes.jsp — Ideas propuestas por estudiantes (4.5), listado del
  Comité (req. 56, 18). Usa v_idea_estudiante unido a v_proyecto para traer el
  estado "Fase N | Rol", el rol en turno, el director y el evaluador. Filtro por
  estado de la idea validado contra lista fija.
  Botones Aprobar y Aplazar habilitados SOLO en "Fase 1 | Comité"; en otro estado
  aparecen deshabilitados con una pista. Eliminar (req. 60) solo si el proyecto
  sigue en la Fase 1. El Comité solo revisa; no crea ideas (req. 61).
--%>
<c:set var="estadoFiltro" value="${param.estado}"/>
<c:if test="${estadoFiltro ne 'PENDIENTE' and estadoFiltro ne 'APROBADA' and estadoFiltro ne 'APLAZADA'}">
  <c:set var="estadoFiltro" value=""/>
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Ideas de estudiantes — Sistemas TG</title>
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
      <h1>Ideas de estudiantes</h1>
    </div>
    <p class="aviso">El Comité revisa las ideas propuestas por los estudiantes y su soporte de pago; no las crea. Solo se puede calificar un proyecto que esté en <strong>Fase 1 | Comité</strong>.</p>
    <form class="filtro" method="get" action="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp">
      <label class="etiqueta" for="estado">Estado de la idea</label>
      <select class="seleccion" id="estado" name="estado">
        <option value=""<c:if test="${empty estadoFiltro}"> selected</c:if>>Todas</option>
        <option value="PENDIENTE"<c:if test="${estadoFiltro == 'PENDIENTE'}"> selected</c:if>>Pendientes</option>
        <option value="APROBADA"<c:if test="${estadoFiltro == 'APROBADA'}"> selected</c:if>>Aprobadas</option>
        <option value="APLAZADA"<c:if test="${estadoFiltro == 'APLAZADA'}"> selected</c:if>>Aplazadas</option>
      </select>
      <button class="boton boton-secundario" type="submit">Filtrar</button>
    </form>
    <sql:query var="ideas" dataSource="${db}"
               sql="SELECT ie.id_proyecto, ie.titulo, ie.descripcion, ie.linea_investigacion,
                           ie.estudiante1, ie.estudiante2, ie.nivel_academico, ie.soporte_pago_url,
                           ie.estado_idea, vp.estado, vp.id_fase, vp.id_rol_proceso, vp.rol_turno,
                           vp.id_estudiante1, vp.id_estudiante2, vp.id_director, vp.id_evaluador,
                           vp.director, vp.evaluador, vp.finalizado
                    FROM v_idea_estudiante ie
                    JOIN v_proyecto vp ON vp.id_proyecto = ie.id_proyecto
                    WHERE (? = '' OR ie.estado_idea = ?)
                    ORDER BY ie.id_proyecto">
      <sql:param value="${estadoFiltro}"/>
      <sql:param value="${estadoFiltro}"/>
    </sql:query>
    <c:choose>
      <c:when test="${ideas.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">No hay ideas de estudiantes que correspondan al filtro seleccionado</h3>
          <p class="vacio-texto">Prueba con otro estado o vuelve a «Todas» para ver todas las ideas.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Título</th><th>Descripción</th><th>Línea</th><th>Estudiante(s)</th>
                <th>Nivel</th><th>Soporte de pago</th><th>Estado de la idea</th><th>Estado del proyecto</th><th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="p" items="${ideas.rows}">
                <tr>
                  <td><c:out value="${p.id_proyecto}"/></td>
                  <td><c:out value="${p.titulo}"/></td>
                  <td><c:out value="${p.descripcion}"/></td>
                  <td><c:out value="${p.linea_investigacion}"/></td>
                  <td>
                    <span class="celda-persona">
                      <c:set var="avatarId" value="${p.id_estudiante1}"/>
                      <c:set var="avatarNombre" value="${p.estudiante1}"/>
                      <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                      <c:out value="${p.estudiante1}"/>
                    </span><c:if test="${not empty p.estudiante2}"> / <span class="celda-persona"><c:set var="avatarId" value="${p.id_estudiante2}"/><c:set var="avatarNombre" value="${p.estudiante2}"/><%@ include file="/WEB-INF/fragmentos/avatar.jsp" %><c:out value="${p.estudiante2}"/></span></c:if>
                  </td>
                  <td><c:out value="${p.nivel_academico}"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty p.soporte_pago_url}">
                        <a href="<c:out value='${p.soporte_pago_url}'/>" target="_blank" rel="noopener noreferrer">Ver soporte de pago</a>
                      </c:when>
                      <c:otherwise><span class="detalle">Sin soporte de pago</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${p.estado_idea == 'APROBADA'}"><span class="insignia insignia-verde">Aprobada</span></c:when>
                      <c:when test="${p.estado_idea == 'APLAZADA'}"><span class="insignia insignia-rojo">Aplazada</span></c:when>
                      <c:otherwise><span class="insignia insignia-gris">Pendiente</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td><span class="insignia insignia-rol"><c:out value="${p.estado}"/></span></td>
                  <td class="acciones">
                    <c:if test="${p.id_fase == 1 and p.id_rol_proceso == 4 and not p.finalizado}">
                      <span class="pastilla-turno"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>Tu turno</span>
                    </c:if>
                    <c:choose>
                      <c:when test="${p.id_fase == 1 and p.id_rol_proceso == 4 and not p.finalizado}">
                        <a class="boton boton-primario boton-pequeno" href="${pageContext.request.contextPath}/comite/idea-estudiante-revisar.jsp?id=<c:out value='${p.id_proyecto}'/>&amp;accion=aprobar">Aprobar</a>
                        <a class="boton boton-secundario boton-pequeno" href="${pageContext.request.contextPath}/comite/idea-estudiante-revisar.jsp?id=<c:out value='${p.id_proyecto}'/>&amp;accion=aplazar">Aplazar</a>
                      </c:when>
                      <c:otherwise>
                        <span class="boton boton-deshabilitado boton-pequeno" title="Solo en Fase 1 | Comité">Aprobar</span>
                        <span class="boton boton-deshabilitado boton-pequeno" title="Solo en Fase 1 | Comité">Aplazar</span>
                        <span class="pista-fase">Solo en Fase 1 | Comité</span>
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${p.id_fase == 1 and not p.finalizado}">
                        <form class="form-eliminar" method="post" action="${pageContext.request.contextPath}/comite/eliminar-idea-estudiante.jsp" data-mensaje="¿Seguro que deseas eliminar esta idea y su proyecto?">
                          <input type="hidden" name="id_proyecto" value="<c:out value='${p.id_proyecto}'/>">
                          <button class="boton boton-peligro boton-pequeno" type="submit">Eliminar</button>
                        </form>
                      </c:when>
                      <c:otherwise>
                        <span class="boton boton-deshabilitado boton-pequeno" title="Solo en Fase 1">Eliminar</span>
                        <span class="pista-fase">Solo en Fase 1</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                </tr>
                <c:if test="${p.estado_idea != 'PENDIENTE'}">
                  <tr class="${p.estado_idea == 'APROBADA' ? 'fila-detalle-ok' : 'fila-detalle'}">
                    <td colspan="10">
                      Director:
                      <c:choose>
                        <c:when test="${empty p.director}">—</c:when>
                        <c:otherwise><span class="celda-persona"><c:set var="avatarId" value="${p.id_director}"/><c:set var="avatarNombre" value="${p.director}"/><%@ include file="/WEB-INF/fragmentos/avatar.jsp" %><c:out value="${p.director}"/></span></c:otherwise>
                      </c:choose>
                      · Evaluador:
                      <c:choose>
                        <c:when test="${empty p.evaluador}">—</c:when>
                        <c:otherwise><span class="celda-persona"><c:set var="avatarId" value="${p.id_evaluador}"/><c:set var="avatarNombre" value="${p.evaluador}"/><%@ include file="/WEB-INF/fragmentos/avatar.jsp" %><c:out value="${p.evaluador}"/></span></c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:if>
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
