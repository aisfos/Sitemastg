<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-calificacion.jsp — Manejador POST del Docente para las fases 2, 3, 4 y 5
  (req. 79, 81, 82, 83, 4, 18, 20f). POST-only: un GET muestra "Acción no permitida".
  El manejador NUNCA lee id_revisor, id_fase, id_rol_proceso ni id_entrega del
  formulario: recalcula en la BD el rol del docente en el proyecto (director o
  evaluador) y exige que coincida con el turno; la fase y el turno salen del estado
  del proyecto; id_entrega es la versión vigente del documento revisado (PROPUESTA
  en las fases 2 y 3; INFORME en las fases 4 y 5). Los triggers validan el turno y
  mueven la fase. Tras el éxito redirige con el nuevo estado leído de la BD.
--%>
<c:set var="urlVolver" value="/docente/proyectos.jsp"/>

<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="idProy" value="${fn:trim(param.id_proyecto)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="No tienes permiso para calificar este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<sql:query var="d" dataSource="${db}"
           sql="SELECT id_proyecto, id_fase, id_rol_proceso, finalizado, id_director, id_evaluador
                FROM proyecto WHERE id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="No tienes permiso para calificar este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 84: el docente en sesión debe ser director o evaluador del proyecto --%>
<c:set var="miRol" value="${d.rows[0].id_director == sessionScope.usuarioId ? 'Director' : (d.rows[0].id_evaluador == sessionScope.usuarioId ? 'Evaluador' : '')}"/>
<c:if test="${empty miRol}">
  <c:set var="flashError" value="No tienes permiso para calificar este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 67 --%>
<c:if test="${d.rows[0].finalizado}">
  <c:set var="flashError" value="El proyecto está finalizado y no puede gestionarse" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="rolProceso" value="${miRol == 'Director' ? 2 : 3}"/>
<c:set var="fase" value="${d.rows[0].id_fase + 0}"/>
<%-- req. 20f: el turno debe ser el de mi rol y la fase debe ser 2, 3, 4 o 5 --%>
<c:if test="${d.rows[0].id_rol_proceso != rolProceso or (fase != 2 and fase != 3 and fase != 4 and fase != 5)}">
  <c:set var="flashError" value="No es el turno de tu rol en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="resultado" value="${fn:trim(param.resultado)}"/>
<c:set var="comentarios" value="${fn:trim(param.comentarios)}"/>
<c:set var="error" value=""/>
<c:if test="${resultado ne 'APROBADO' and resultado ne 'APLAZADO'}">
  <c:set var="error" value="Debes seleccionar Aprobado o Aplazado"/>
</c:if>
<c:if test="${empty error and empty comentarios}">
  <c:set var="error" value="Los comentarios son obligatorios"/>
</c:if>
<c:if test="${empty error and fn:length(comentarios) > 1000}">
  <c:set var="error" value="Los comentarios no pueden superar los 1000 caracteres"/>
</c:if>
<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="tipoDoc" value="${fase == 2 or fase == 3 ? 'PROPUESTA' : 'INFORME'}"/>
<c:catch var="err">
  <sql:update dataSource="${db}"
              sql="INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado)
                   VALUES (?, ?, ?, ?, (SELECT id_entrega FROM v_ultima_entrega WHERE id_proyecto = ? AND tipo = ?), ?, ?, NULL, NULL)">
    <sql:param value="${idNum}"/>
    <sql:param value="${fase}"/>
    <sql:param value="${rolProceso}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
    <sql:param value="${idNum}"/>
    <sql:param value="${tipoDoc}"/>
    <sql:param value="${resultado}"/>
    <sql:param value="${comentarios}"/>
  </sql:update>
</c:catch>
<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<sql:query var="nuevo" dataSource="${db}" sql="SELECT estado FROM v_proyecto WHERE id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:set var="flashOk" value="Calificación registrada. El proyecto queda en «${nuevo.rows[0].estado}»" scope="session"/>
<c:redirect url="${urlVolver}"/>
