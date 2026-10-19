<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  eliminar-idea-estudiante.jsp — Manejador POST para eliminar una idea de
  estudiante (req. 60; decisión (h)): solo ideas de origen PROPIA que sigan en la
  Fase 1. En una sola sql:transaction, en este orden, DELETE de revision, de
  entrega y de proyecto. CADA delete lleva la condición (PROPIA, Fase 1, no
  finalizado; con subconsulta a proyecto en revision y entrega) para que, si el
  estado cambió, no se borre nada. Si no se cumple, mensaje claro y sin cambios.
--%>
<c:set var="urlVolver" value="/comite/ideas-estudiantes.jsp"/>

<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="idProy" value="${fn:trim(param.id_proyecto)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="mensajeAsociados" value="No se puede eliminar la idea: tiene datos asociados"/>
<c:set var="filasProy" value="0"/>
<c:catch var="err">
  <sql:transaction dataSource="${db}">
    <sql:update sql="DELETE FROM revision WHERE id_proyecto = ? AND EXISTS (SELECT 1 FROM proyecto WHERE id_proyecto = ? AND origen = 'PROPIA' AND id_fase = 1 AND finalizado = 0)">
      <sql:param value="${idNum}"/>
      <sql:param value="${idNum}"/>
    </sql:update>
    <sql:update sql="DELETE FROM entrega WHERE id_proyecto = ? AND EXISTS (SELECT 1 FROM proyecto WHERE id_proyecto = ? AND origen = 'PROPIA' AND id_fase = 1 AND finalizado = 0)">
      <sql:param value="${idNum}"/>
      <sql:param value="${idNum}"/>
    </sql:update>
    <sql:update var="filasProy" sql="DELETE FROM proyecto WHERE id_proyecto = ? AND origen = 'PROPIA' AND id_fase = 1 AND finalizado = 0">
      <sql:param value="${idNum}"/>
    </sql:update>
  </sql:transaction>
</c:catch>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:if test="${filasProy == 0}">
  <%-- No era PROPIA, no existe o ya salió de la Fase 1: sin cambios --%>
  <c:set var="flashError" value="Solo se pueden eliminar ideas propias que sigan en la Fase 1" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="flashOk" value="Idea del estudiante eliminada correctamente" scope="session"/>
<c:redirect url="${urlVolver}"/>
