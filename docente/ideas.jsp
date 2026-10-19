<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  ideas.jsp — "Mis ideas" del Docente (req. 74, 18).
  Lista SOLO las ideas del docente en sesión (filtro id_docente = usuario).
  Muestra estado y disponibilidad; si está Aplazada, además el acta y el
  motivo, con el botón Corregir (req. 51).
--%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mis ideas — Sistemas TG</title>
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
      <h1>Mis ideas</h1>
      <a class="boton boton-primario" href="${pageContext.request.contextPath}/docente/idea-form.jsp">Proponer idea</a>
    </div>
    <sql:query var="ideas" dataSource="${db}"
               sql="SELECT id_idea_docente, titulo, objetivo, linea_investigacion, nivel_academico, periodo_academico, estado, disponibilidad, acta_numero, motivo_aplazamiento
                    FROM v_idea_docente
                    WHERE id_docente = ?
                    ORDER BY id_idea_docente">
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <c:choose>
      <c:when test="${ideas.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">Todavía no has propuesto ideas</h3>
          <p class="vacio-texto">Propón tu primera idea para que el Comité la revise y los estudiantes puedan tomarla.</p>
          <div class="vacio-acciones">
            <a class="boton boton-primario" href="${pageContext.request.contextPath}/docente/idea-form.jsp">Proponer idea</a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Título</th><th>Objetivo</th><th>Línea</th><th>Nivel</th>
                <th>Periodo</th><th>Estado</th><th>Disponibilidad</th><th>Acciones</th>
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
                    <c:if test="${idea.estado == 'APLAZADA'}">
                      <a class="boton boton-secundario boton-pequeno" href="${pageContext.request.contextPath}/docente/idea-form.jsp?id=<c:out value='${idea.id_idea_docente}'/>">Corregir</a>
                    </c:if>
                  </td>
                </tr>
                <c:if test="${idea.estado == 'APLAZADA'}">
                  <tr class="fila-detalle">
                    <td colspan="9">
                      <strong>Acta <c:out value="${idea.acta_numero}"/></strong>
                      — Motivo del aplazamiento: <c:out value="${idea.motivo_aplazamiento}"/>
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
