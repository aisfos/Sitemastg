<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-revision-fase1.jsp — Manejador POST del Comité para calificar una idea
  de la Fase 1 (req. 4, 57, 58, 59). Sirve a los dos orígenes (decisión (g)):
    - PROPIA:        asigna director y evaluador y luego califica.
    - BANCO_DOCENTE: el director viene de la idea (no se cambia); solo el evaluador.
  El UPDATE de asignación y el INSERT en revision van en una sola sql:transaction:
  si un trigger rechaza el INSERT (p. ej. falta el soporte de pago, req. 57), la
  asignación de director y evaluador queda revertida.
  La calificación siempre queda a nombre del usuario Comité de la sesión; el
  resultado, la fase y el turno no se leen del formulario (los pone el manejador).
--%>
<c:set var="urlVolver" value="/comite/ideas-estudiantes.jsp"/>

<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="accion" value="${fn:trim(param.accion)}"/>
<c:if test="${accion ne 'aprobar' and accion ne 'aplazar'}">
  <c:set var="flashError" value="Acción no válida" scope="session"/>
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
           sql="SELECT id_proyecto, origen, id_fase, id_rol_proceso, finalizado, id_director, id_evaluador
                FROM proyecto WHERE id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 20f: el Comité solo califica proyectos en "Fase 1 | Comité" (decisión (e)) --%>
<c:if test="${d.rows[0].finalizado or d.rows[0].id_fase != 1 or d.rows[0].id_rol_proceso != 4}">
  <c:set var="flashError" value="No es el turno del Comité en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:choose>

  <%-- ================== APROBAR (req. 57, 58; 9 y 20h) ================== --%>
  <c:when test="${accion == 'aprobar'}">
    <c:set var="acta" value="${fn:trim(param.acta_numero)}"/>
    <c:set var="comentarios" value="${fn:trim(param.comentarios)}"/>
    <c:set var="error" value=""/>

    <c:if test="${empty acta}"><c:set var="error" value="El número de acta es obligatorio"/></c:if>
    <c:if test="${empty error and fn:length(acta) > 30}"><c:set var="error" value="El número de acta no puede superar los 30 caracteres"/></c:if>
    <c:if test="${empty error and empty comentarios}"><c:set var="error" value="Los comentarios son obligatorios"/></c:if>
    <c:if test="${empty error and fn:length(comentarios) > 1000}"><c:set var="error" value="Los comentarios no pueden superar los 1000 caracteres"/></c:if>

    <%-- Director: fijo en las ideas del banco; elegido por el Comité en las propias --%>
    <c:set var="dirNum" value="0"/>
    <c:choose>
      <c:when test="${d.rows[0].origen == 'BANCO_DOCENTE'}">
        <c:set var="dirNum" value="${d.rows[0].id_director + 0}"/>
        <c:if test="${empty error and empty d.rows[0].id_director}">
          <c:set var="error" value="La idea del banco no tiene director asignado"/>
        </c:if>
      </c:when>
      <c:otherwise>
        <c:set var="dirParam" value="${fn:trim(param.id_director)}"/>
        <c:set var="errDir" value=""/>
        <c:if test="${not empty dirParam}"><c:catch var="errDir"><c:set var="dirNum" value="${dirParam + 0}"/></c:catch></c:if>
        <c:if test="${empty error and (empty dirParam or not empty errDir or dirNum <= 0)}">
          <c:set var="error" value="Debes seleccionar al director"/>
        </c:if>
      </c:otherwise>
    </c:choose>

    <c:set var="evaParam" value="${fn:trim(param.id_evaluador)}"/>
    <c:set var="evaNum" value="0"/>
    <c:set var="errEva" value=""/>
    <c:if test="${not empty evaParam}"><c:catch var="errEva"><c:set var="evaNum" value="${evaParam + 0}"/></c:catch></c:if>
    <c:if test="${empty error and (empty evaParam or not empty errEva or evaNum <= 0)}">
      <c:set var="error" value="Debes seleccionar al evaluador"/>
    </c:if>

    <%-- Director y evaluador deben existir y ser docentes --%>
    <c:if test="${empty error}">
      <sql:query var="qDir" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM usuario WHERE id_usuario = ? AND id_rol = 3">
        <sql:param value="${dirNum}"/>
      </sql:query>
      <c:if test="${qDir.rows[0].n == 0}"><c:set var="error" value="El director debe ser un usuario con rol Docente"/></c:if>
    </c:if>
    <c:if test="${empty error}">
      <sql:query var="qEva" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM usuario WHERE id_usuario = ? AND id_rol = 3">
        <sql:param value="${evaNum}"/>
      </sql:query>
      <c:if test="${qEva.rows[0].n == 0}"><c:set var="error" value="El evaluador debe ser un usuario con rol Docente"/></c:if>
    </c:if>
    <%-- req. 9 y 20h: el evaluador no puede ser el director --%>
    <c:if test="${empty error and dirNum == evaNum}">
      <c:set var="error" value="El evaluador no puede ser el director del proyecto"/>
    </c:if>

    <c:if test="${not empty error}">
      <c:set var="flashError" value="${error}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>

    <c:catch var="err">
      <sql:transaction dataSource="${db}">
        <c:choose>
          <c:when test="${d.rows[0].origen == 'BANCO_DOCENTE'}">
            <sql:update sql="UPDATE proyecto SET id_evaluador = ? WHERE id_proyecto = ? AND id_fase = 1 AND id_rol_proceso = 4 AND finalizado = 0">
              <sql:param value="${evaNum}"/>
              <sql:param value="${idNum}"/>
            </sql:update>
          </c:when>
          <c:otherwise>
            <sql:update sql="UPDATE proyecto SET id_director = ?, id_evaluador = ? WHERE id_proyecto = ? AND id_fase = 1 AND id_rol_proceso = 4 AND finalizado = 0">
              <sql:param value="${dirNum}"/>
              <sql:param value="${evaNum}"/>
              <sql:param value="${idNum}"/>
            </sql:update>
          </c:otherwise>
        </c:choose>
        <sql:update sql="INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado) VALUES (?, 1, 4, ?, (SELECT MAX(id_entrega) FROM entrega WHERE id_proyecto = ? AND tipo = 'SOPORTE_PAGO'), 'APROBADO', ?, ?, NULL)">
          <sql:param value="${idNum}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${idNum}"/>
          <sql:param value="${comentarios}"/>
          <sql:param value="${acta}"/>
        </sql:update>
      </sql:transaction>
    </c:catch>
    <%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
    <c:if test="${not empty err}">
      <c:set var="flashError" value="${mensajeBd}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>

    <c:set var="flashOk" value="Idea aprobada; el proyecto pasa al estudiante para la propuesta" scope="session"/>
    <c:redirect url="${urlVolver}"/>
  </c:when>

  <%-- ======================= APLAZAR (req. 59) ======================= --%>
  <c:otherwise>
    <c:set var="acta" value="${fn:trim(param.acta_numero)}"/>
    <c:set var="motivo" value="${fn:trim(param.motivo)}"/>
    <c:set var="error" value=""/>
    <c:if test="${empty acta}"><c:set var="error" value="El número de acta es obligatorio"/></c:if>
    <c:if test="${empty error and fn:length(acta) > 30}"><c:set var="error" value="El número de acta no puede superar los 30 caracteres"/></c:if>
    <c:if test="${empty error and empty motivo}"><c:set var="error" value="El motivo del aplazamiento es obligatorio"/></c:if>
    <c:if test="${empty error and fn:length(motivo) > 1000}"><c:set var="error" value="El motivo no puede superar los 1000 caracteres"/></c:if>
    <c:if test="${not empty error}">
      <c:set var="flashError" value="${error}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>

    <c:catch var="err">
      <sql:transaction dataSource="${db}">
        <sql:update sql="INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado) VALUES (?, 1, 4, ?, (SELECT MAX(id_entrega) FROM entrega WHERE id_proyecto = ? AND tipo = 'SOPORTE_PAGO'), 'APLAZADO', ?, ?, NULL)">
          <sql:param value="${idNum}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${idNum}"/>
          <sql:param value="${motivo}"/>
          <sql:param value="${acta}"/>
        </sql:update>
      </sql:transaction>
    </c:catch>
    <%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
    <c:if test="${not empty err}">
      <c:set var="flashError" value="${mensajeBd}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>

    <c:set var="flashOk" value="Idea aplazada; el estudiante podrá corregirla" scope="session"/>
    <c:redirect url="${urlVolver}"/>
  </c:otherwise>

</c:choose>
