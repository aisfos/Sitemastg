<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-calificacion.jsp — Manejador POST del Comité para las Fases 3, 5 y 6
  (req. 4, 64, 65, 66, 68, 18). POST-only: un GET muestra "Acción no permitida".
  El manejador NUNCA lee id_revisor, id_fase, id_rol_proceso ni id_entrega del
  formulario: el revisor es el de la sesión; la fase y el turno salen del estado
  del proyecto en la BD; id_entrega es la versión vigente del documento revisado
  (PROPUESTA en la fase 3, INFORME en las fases 5 y 6). Los triggers validan el
  turno y mueven la fase. Tras el éxito redirige con el nuevo estado leído de la BD.
--%>
<c:set var="urlVolver" value="/comite/proyectos.jsp"/>

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

<sql:query var="d" dataSource="${db}"
           sql="SELECT id_proyecto, id_fase, id_rol_proceso, finalizado FROM proyecto WHERE id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 67 --%>
<c:if test="${d.rows[0].finalizado}">
  <c:set var="flashError" value="El proyecto está finalizado y no puede gestionarse" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="fase" value="${d.rows[0].id_fase + 0}"/>
<%-- req. 20f: el Comité solo califica las fases 3, 5 y 6 cuando su turno es el actual --%>
<c:if test="${d.rows[0].id_rol_proceso != 4 or (fase != 3 and fase != 5 and fase != 6)}">
  <c:set var="flashError" value="No es el turno del Comité en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="comentarios" value="${fn:trim(param.comentarios)}"/>
<c:set var="error" value=""/>
<c:if test="${empty comentarios}"><c:set var="error" value="Los comentarios son obligatorios"/></c:if>
<c:if test="${empty error and fn:length(comentarios) > 1000}">
  <c:set var="error" value="Los comentarios no pueden superar los 1000 caracteres"/>
</c:if>

<c:choose>
  <%-- Fases 3 y 5: resultado (lista fija) + acta obligatoria --%>
  <c:when test="${fase == 3 or fase == 5}">
    <c:set var="resultado" value="${fn:trim(param.resultado)}"/>
    <c:if test="${empty error and resultado ne 'APROBADO' and resultado ne 'APLAZADO'}">
      <c:set var="error" value="Debes seleccionar Aprobado o Aplazado"/>
    </c:if>
    <c:set var="acta" value="${fn:trim(param.acta_numero)}"/>
    <c:if test="${empty error and empty acta}">
      <c:set var="error" value="El número de acta es obligatorio"/>
    </c:if>
    <c:if test="${empty error and fn:length(acta) > 30}">
      <c:set var="error" value="El número de acta no puede superar los 30 caracteres"/>
    </c:if>
  </c:when>
  <%-- Fase 6: radicado obligatorio; la aprobación es implícita (no hay aplazar) --%>
  <c:otherwise>
    <c:set var="radicado" value="${fn:trim(param.radicado)}"/>
    <c:if test="${empty error and empty radicado}">
      <c:set var="error" value="El radicado es obligatorio"/>
    </c:if>
    <c:if test="${empty error and fn:length(radicado) > 50}">
      <c:set var="error" value="El radicado no puede superar los 50 caracteres"/>
    </c:if>
  </c:otherwise>
</c:choose>

<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:choose>
  <%-- Fases 3 y 5: calificación con acta; la versión vigente es PROPUESTA o INFORME --%>
  <c:when test="${fase == 3 or fase == 5}">
    <c:set var="tipoDoc" value="${fase == 3 ? 'PROPUESTA' : 'INFORME'}"/>
    <c:catch var="err">
      <sql:update dataSource="${db}"
                  sql="INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado)
                       VALUES (?, ?, 4, ?, (SELECT id_entrega FROM v_ultima_entrega WHERE id_proyecto = ? AND tipo = ?), ?, ?, ?, NULL)">
        <sql:param value="${idNum}"/>
        <sql:param value="${fase}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${idNum}"/>
        <sql:param value="${tipoDoc}"/>
        <sql:param value="${resultado}"/>
        <sql:param value="${comentarios}"/>
        <sql:param value="${acta}"/>
      </sql:update>
    </c:catch>
  </c:when>
  <%-- Fase 6: cierre con radicado; la versión vigente es el INFORME --%>
  <c:otherwise>
    <c:catch var="err">
      <sql:update dataSource="${db}"
                  sql="INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado)
                       VALUES (?, 6, 4, ?, (SELECT id_entrega FROM v_ultima_entrega WHERE id_proyecto = ? AND tipo = 'INFORME'), 'APROBADO', ?, NULL, ?)">
        <sql:param value="${idNum}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${idNum}"/>
        <sql:param value="${comentarios}"/>
        <sql:param value="${radicado}"/>
      </sql:update>
    </c:catch>
  </c:otherwise>
</c:choose>
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
