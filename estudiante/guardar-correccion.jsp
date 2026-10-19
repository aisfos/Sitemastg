<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-correccion.jsp — Manejador POST para corregir y reenviar la Fase 1
  (req. 5, 91). Comprueba propiedad y turno, aplica los campos permitidos según el
  origen y, en una sola sql:transaction, inserta la nueva versión del pago (si hay
  URL) y hace un único UPDATE que pasa el turno al comité por la transición ENVIAR
  (leída de transicion_fase). Exige al menos un cambio.
--%>
<c:set var="urlVolver" value="/estudiante/proyectos.jsp"/>

<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="idProy" value="${fn:trim(param.id_proyecto)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="No tienes permiso para ver este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="urlCorregir" value="/estudiante/corregir-idea.jsp?id=${idNum}"/>
<sql:query var="d" dataSource="${db}"
           sql="SELECT id_proyecto, titulo, descripcion, id_linea, origen, id_fase, id_rol_proceso, finalizado
                FROM proyecto WHERE id_proyecto = ? AND id_estudiante1 = ?">
  <sql:param value="${idNum}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="No tienes permiso para ver este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:if test="${d.rows[0].finalizado or d.rows[0].id_fase != 1 or d.rows[0].id_rol_proceso != 1}">
  <c:set var="flashError" value="No es el turno del Estudiante en la fase actual del proyecto" scope="session"/>
  <c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
</c:if>

<c:set var="nuevoPago" value="${fn:trim(param.soporte_pago)}"/>
<c:set var="hayCambio" value="${not empty nuevoPago}"/>
<c:set var="error" value=""/>

<c:choose>
  <c:when test="${d.rows[0].origen == 'PROPIA'}">
    <c:set var="titulo" value="${fn:trim(param.titulo)}"/>
    <c:set var="descripcion" value="${fn:trim(param.descripcion)}"/>
    <c:set var="idLinea" value="${fn:trim(param.id_linea)}"/>
    <c:if test="${empty titulo}"><c:set var="error" value="El título es obligatorio"/></c:if>
    <c:if test="${empty error and fn:length(titulo) > 200}"><c:set var="error" value="El título no puede superar los 200 caracteres"/></c:if>
    <c:if test="${empty error and empty descripcion}"><c:set var="error" value="La descripción es obligatoria"/></c:if>
    <c:if test="${empty error and fn:length(descripcion) > 2000}"><c:set var="error" value="La descripción no puede superar los 2000 caracteres"/></c:if>
    <c:if test="${empty error and empty idLinea}"><c:set var="error" value="La línea de investigación es obligatoria"/></c:if>
    <c:if test="${empty error}">
      <sql:query var="chkLinea" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM linea_investigacion WHERE id_linea = ?">
        <sql:param value="${idLinea}"/>
      </sql:query>
      <c:if test="${chkLinea.rows[0].n == 0}">
        <c:set var="error" value="La línea de investigación seleccionada no es válida"/>
      </c:if>
    </c:if>
    <c:if test="${empty error and (titulo ne d.rows[0].titulo or descripcion ne d.rows[0].descripcion or idLinea ne d.rows[0].id_linea)}">
      <c:set var="hayCambio" value="true"/>
    </c:if>
  </c:when>
</c:choose>

<%-- URL del nuevo soporte de pago (req. 17, 20d), si viene --%>
<c:if test="${empty error and not empty nuevoPago}">
  <c:set var="url" value="${nuevoPago}"/>
  <%@ include file="/WEB-INF/fragmentos/url-valida.jsp" %>
  <c:if test="${not urlValida}"><c:set var="error" value="La URL no tiene un formato válido"/></c:if>
</c:if>

<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlCorregir}"/>
</c:if>
<c:if test="${not hayCambio}">
  <c:set var="flashError" value="No hay cambios para reenviar" scope="session"/>
  <c:redirect url="${urlCorregir}"/>
</c:if>

<c:set var="filas" value="0"/>
<c:catch var="err">
  <sql:transaction dataSource="${db}">
    <c:if test="${not empty nuevoPago}">
      <sql:update sql="INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, 'SOPORTE_PAGO', ?, ?)">
        <sql:param value="${idNum}"/>
        <sql:param value="${d.rows[0].id_fase}"/>
        <sql:param value="${nuevoPago}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:if>
    <sql:query var="trans" sql="SELECT id_fase_destino, id_rol_destino FROM transicion_fase WHERE id_fase_origen = ? AND id_rol_origen = 1 AND accion = 'ENVIAR'">
      <sql:param value="${d.rows[0].id_fase}"/>
    </sql:query>
    <c:choose>
      <c:when test="${d.rows[0].origen == 'PROPIA'}">
        <sql:update var="filas" sql="UPDATE proyecto SET titulo = ?, descripcion = ?, id_linea = ?, id_fase = ?, id_rol_proceso = ? WHERE id_proyecto = ? AND id_estudiante1 = ? AND id_fase = 1 AND id_rol_proceso = 1 AND finalizado = 0">
          <sql:param value="${titulo}"/>
          <sql:param value="${descripcion}"/>
          <sql:param value="${idLinea}"/>
          <sql:param value="${trans.rows[0].id_fase_destino}"/>
          <sql:param value="${trans.rows[0].id_rol_destino}"/>
          <sql:param value="${idNum}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
        </sql:update>
      </c:when>
      <c:otherwise>
        <sql:update var="filas" sql="UPDATE proyecto SET id_fase = ?, id_rol_proceso = ? WHERE id_proyecto = ? AND id_estudiante1 = ? AND id_fase = 1 AND id_rol_proceso = 1 AND finalizado = 0">
          <sql:param value="${trans.rows[0].id_fase_destino}"/>
          <sql:param value="${trans.rows[0].id_rol_destino}"/>
          <sql:param value="${idNum}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
        </sql:update>
      </c:otherwise>
    </c:choose>
  </sql:transaction>
</c:catch>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlCorregir}"/>
</c:if>

<c:if test="${filas == 0}">
  <c:set var="flashError" value="No es el turno del Estudiante en la fase actual del proyecto" scope="session"/>
  <c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
</c:if>

<c:set var="flashOk" value="Idea corregida y reenviada al comité" scope="session"/>
<c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
