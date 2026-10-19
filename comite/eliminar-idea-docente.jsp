<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  eliminar-idea-docente.jsp — Manejador POST para eliminar una idea del banco
  (req. 53). Solo si ningún proyecto la usa (DELETE condicionado con NOT EXISTS,
  comprobando filas afectadas) y con captura del error 1451 como respaldo.
--%>
<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:set var="idIdea" value="${fn:trim(param.id_idea_docente)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${empty idIdea or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:set var="mensajeAsociados" value="No se puede eliminar una idea que ya fue tomada por un proyecto"/>
<c:catch var="err">
  <sql:update var="filas" dataSource="${db}"
              sql="DELETE FROM idea_docente WHERE id_idea_docente = ? AND NOT EXISTS (SELECT 1 FROM proyecto WHERE id_idea_docente = ?)">
    <sql:param value="${idNum}"/>
    <sql:param value="${idNum}"/>
  </sql:update>
</c:catch>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:if test="${filas == 0}">
  <%-- 0 filas: la idea no existe o un proyecto la usa; se distingue el mensaje --%>
  <sql:query var="usada" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_idea_docente = ?">
    <sql:param value="${idNum}"/>
  </sql:query>
  <c:choose>
    <c:when test="${usada.rows[0].n > 0}">
      <c:set var="flashError" value="No se puede eliminar una idea que ya fue tomada por un proyecto" scope="session"/>
    </c:when>
    <c:otherwise>
      <c:set var="flashError" value="La idea no existe" scope="session"/>
    </c:otherwise>
  </c:choose>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:set var="flashOk" value="Idea eliminada correctamente" scope="session"/>
<c:redirect url="/comite/ideas-docentes.jsp"/>
