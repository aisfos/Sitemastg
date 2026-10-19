<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  ideas-docentes.jsp — Banco de Ideas Docente (4.4), listado del Comité
  (req. 49, 18). Filtro por estado validado contra una lista fija.
  Botones por fila: Aprobar y Aplazar solo en PENDIENTE; Editar y Eliminar en
  todas. De las ideas revisadas se muestran el acta y, si están aplazadas, el
  motivo. El Comité solo revisa; no crea ni redacta ideas (req. 54).
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
  <title>Banco de ideas docente — Sistemas TG</title>
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
      <h1>Banco de ideas docente</h1>
    </div>
    <p class="aviso">El Comité revisa las ideas propuestas por los docentes; no las crea ni las redacta.</p>
    <form class="filtro" method="get" action="${pageContext.request.contextPath}/comite/ideas-docentes.jsp">
      <label class="etiqueta" for="estado">Estado</label>
      <select class="seleccion" id="estado" name="estado">
        <option value=""<c:if test="${empty estadoFiltro}"> selected</c:if>>Todas</option>
        <option value="PENDIENTE"<c:if test="${estadoFiltro == 'PENDIENTE'}"> selected</c:if>>Pendientes</option>
        <option value="APROBADA"<c:if test="${estadoFiltro == 'APROBADA'}"> selected</c:if>>Aprobadas</option>
        <option value="APLAZADA"<c:if test="${estadoFiltro == 'APLAZADA'}"> selected</c:if>>Aplazadas</option>
      </select>
      <button class="boton boton-secundario" type="submit">Filtrar</button>
    </form>
    <sql:query var="ideas" dataSource="${db}"
               sql="SELECT id_idea_docente, titulo, objetivo, linea_investigacion, nivel_academico, periodo_academico, id_docente, docente, estado, disponibilidad, acta_numero, motivo_aplazamiento
                    FROM v_idea_docente
                    WHERE (? = '' OR estado = ?)
                    ORDER BY id_idea_docente">
      <sql:param value="${estadoFiltro}"/>
      <sql:param value="${estadoFiltro}"/>
    </sql:query>
    <c:choose>
      <c:when test="${ideas.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">No hay ideas que correspondan al filtro seleccionado</h3>
          <p class="vacio-texto">Cambia el filtro de estado para ver otras ideas del banco.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Título</th><th>Objetivo</th><th>Línea</th><th>Nivel</th>
                <th>Periodo</th><th>Docente</th><th>Estado</th><th>Disponibilidad</th><th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="idea" items="${ideas.rows}">
                <tr>
                  <td><c:out value="${idea.id_idea_docente}"/></td>
                  <td><c:out value="${idea.titulo}"/></td>
                  <td><c:out value="${idea.objetivo}"/></td>
                  <td><c:out value="${idea.linea_investigacion}"/></td>
                  <td><c:out value="${idea.nivel_academico}"/></td>
                  <td><c:out value="${idea.periodo_academico}"/></td>
                  <td>
                    <span class="celda-persona">
                      <c:set var="avatarId" value="${idea.id_docente}"/>
                      <c:set var="avatarNombre" value="${idea.docente}"/>
                      <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                      <c:out value="${idea.docente}"/>
                    </span>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${idea.estado == 'APROBADA'}"><span class="insignia insignia-verde">Aprobada</span></c:when>
                      <c:when test="${idea.estado == 'APLAZADA'}"><span class="insignia insignia-rojo">Aplazada</span></c:when>
                      <c:otherwise><span class="insignia insignia-gris">Pendiente</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${idea.disponibilidad == 'DISPONIBLE'}"><span class="insignia insignia-verde">Disponible</span></c:when>
                      <c:otherwise><span class="insignia insignia-gris">No disponible</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td class="acciones">
                    <c:if test="${idea.estado == 'PENDIENTE'}">
                      <span class="pastilla-turno"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>Tu turno</span>
                    </c:if>
                    <c:if test="${idea.estado == 'PENDIENTE'}">
                      <a class="boton boton-primario boton-pequeno" href="${pageContext.request.contextPath}/comite/idea-docente-revisar.jsp?id=<c:out value='${idea.id_idea_docente}'/>&amp;accion=aprobar">Aprobar</a>
                      <a class="boton boton-secundario boton-pequeno" href="${pageContext.request.contextPath}/comite/idea-docente-revisar.jsp?id=<c:out value='${idea.id_idea_docente}'/>&amp;accion=aplazar">Aplazar</a>
                    </c:if>
                    <a class="boton boton-secundario boton-pequeno" href="${pageContext.request.contextPath}/comite/idea-docente-editar.jsp?id=<c:out value='${idea.id_idea_docente}'/>">Editar</a>
                    <form class="form-eliminar" method="post" action="${pageContext.request.contextPath}/comite/eliminar-idea-docente.jsp" data-mensaje="¿Seguro que deseas eliminar esta idea del banco?">
                      <input type="hidden" name="id_idea_docente" value="<c:out value='${idea.id_idea_docente}'/>">
                      <button class="boton boton-peligro boton-pequeno" type="submit">Eliminar</button>
                    </form>
                  </td>
                </tr>
                <c:if test="${idea.estado != 'PENDIENTE'}">
                  <tr class="${idea.estado == 'APROBADA' ? 'fila-detalle-ok' : 'fila-detalle'}">
                    <td colspan="10">
                      <strong>Acta <c:out value="${idea.acta_numero}"/></strong>
                      <c:if test="${idea.estado == 'APLAZADA'}"> — Motivo del aplazamiento: <c:out value="${idea.motivo_aplazamiento}"/></c:if>
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
