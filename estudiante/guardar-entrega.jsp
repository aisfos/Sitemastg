<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-entrega.jsp — Manejador POST del envío de documentos de las fases 2 a 5
  (req. 90, 91, 92, 96). Comprueba propiedad y turno, valida las URLs (req. 17, 20d)
  y, en una sola sql:transaction, inserta las entregas (el tipo lo determina la fase,
  nunca el formulario) y hace un único UPDATE que pasa el turno por la transición
  ENVIAR leída de transicion_fase. El tipo y la versión los fija el trigger
  trg_entrega_bi; el estudiante actuante es SIEMPRE el de la sesión.
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

<c:set var="urlFormulario" value="/estudiante/enviar-documento.jsp?id=${idNum}"/>
<sql:query var="d" dataSource="${db}"
           sql="SELECT id_proyecto, id_fase, id_rol_proceso, finalizado
                FROM proyecto WHERE id_proyecto = ? AND id_estudiante1 = ?">
  <sql:param value="${idNum}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="No tienes permiso para ver este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="fase" value="${d.rows[0].id_fase}"/>
<c:if test="${d.rows[0].finalizado or d.rows[0].id_rol_proceso != 1 or (fase != 2 and fase != 3 and fase != 4 and fase != 5)}">
  <c:set var="flashError" value="No es el turno del Estudiante en la fase actual del proyecto" scope="session"/>
  <c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
</c:if>

<c:set var="esPropuesta" value="${fase == 2 or fase == 3}"/>
<c:set var="tipoPrincipal" value="${esPropuesta ? 'PROPUESTA' : 'INFORME'}"/>
<c:set var="error" value=""/>

<c:choose>
  <c:when test="${esPropuesta}">
    <c:set var="urlPrincipal" value="${fn:trim(param.url_propuesta)}"/>
    <c:if test="${empty urlPrincipal}">
      <c:set var="error" value="La URL de la propuesta es obligatoria"/>
    </c:if>
  </c:when>
  <c:otherwise>
    <c:set var="urlPrincipal" value="${fn:trim(param.url_informe)}"/>
    <c:set var="urlManualUsuario" value="${fn:trim(param.url_manual_usuario)}"/>
    <c:set var="urlManualTecnico" value="${fn:trim(param.url_manual_tecnico)}"/>
    <c:set var="urlRepositorio" value="${fn:trim(param.url_repositorio)}"/>
    <c:if test="${empty urlPrincipal}">
      <c:set var="error" value="La URL del informe es obligatoria"/>
    </c:if>
  </c:otherwise>
</c:choose>

<%-- Validación de URLs (req. 17, 20d): la principal es obligatoria; los anexos solo si vienen --%>
<c:if test="${empty error}">
  <c:set var="url" value="${urlPrincipal}"/>
  <%@ include file="/WEB-INF/fragmentos/url-valida.jsp" %>
  <c:if test="${not urlValida}"><c:set var="error" value="${esPropuesta ? 'La URL de la propuesta no tiene un formato válido' : 'La URL del informe no tiene un formato válido'}"/></c:if>
</c:if>
<c:if test="${empty error and not empty urlManualUsuario}">
  <c:set var="url" value="${urlManualUsuario}"/>
  <%@ include file="/WEB-INF/fragmentos/url-valida.jsp" %>
  <c:if test="${not urlValida}"><c:set var="error" value="La URL del manual de usuario no tiene un formato válido"/></c:if>
</c:if>
<c:if test="${empty error and not empty urlManualTecnico}">
  <c:set var="url" value="${urlManualTecnico}"/>
  <%@ include file="/WEB-INF/fragmentos/url-valida.jsp" %>
  <c:if test="${not urlValida}"><c:set var="error" value="La URL del manual técnico no tiene un formato válido"/></c:if>
</c:if>
<c:if test="${empty error and not empty urlRepositorio}">
  <c:set var="url" value="${urlRepositorio}"/>
  <%@ include file="/WEB-INF/fragmentos/url-valida.jsp" %>
  <c:if test="${not urlValida}"><c:set var="error" value="La URL del repositorio no tiene un formato válido"/></c:if>
</c:if>

<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlFormulario}"/>
</c:if>

<c:set var="filas" value="0"/>
<c:catch var="err">
  <sql:transaction dataSource="${db}">
    <sql:query var="trans" sql="SELECT id_fase_destino, id_rol_destino FROM transicion_fase WHERE id_fase_origen = ? AND id_rol_origen = 1 AND accion = 'ENVIAR'">
      <sql:param value="${fase}"/>
    </sql:query>
    <sql:update sql="INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, ?, ?, ?)">
      <sql:param value="${idNum}"/>
      <sql:param value="${fase}"/>
      <sql:param value="${tipoPrincipal}"/>
      <sql:param value="${urlPrincipal}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:update>
    <c:if test="${not esPropuesta and not empty urlManualUsuario}">
      <sql:update sql="INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, 'MANUAL_USUARIO', ?, ?)">
        <sql:param value="${idNum}"/>
        <sql:param value="${fase}"/>
        <sql:param value="${urlManualUsuario}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:if>
    <c:if test="${not esPropuesta and not empty urlManualTecnico}">
      <sql:update sql="INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, 'MANUAL_TECNICO', ?, ?)">
        <sql:param value="${idNum}"/>
        <sql:param value="${fase}"/>
        <sql:param value="${urlManualTecnico}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:if>
    <c:if test="${not esPropuesta and not empty urlRepositorio}">
      <sql:update sql="INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, 'REPOSITORIO', ?, ?)">
        <sql:param value="${idNum}"/>
        <sql:param value="${fase}"/>
        <sql:param value="${urlRepositorio}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:if>
    <sql:update var="filas" sql="UPDATE proyecto SET id_fase = ?, id_rol_proceso = ? WHERE id_proyecto = ? AND id_estudiante1 = ? AND id_fase = ? AND id_rol_proceso = 1 AND finalizado = 0">
      <sql:param value="${trans.rows[0].id_fase_destino}"/>
      <sql:param value="${trans.rows[0].id_rol_destino}"/>
      <sql:param value="${idNum}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${fase}"/>
    </sql:update>
  </sql:transaction>
</c:catch>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlFormulario}"/>
</c:if>

<c:if test="${filas == 0}">
  <c:set var="flashError" value="No es el turno del Estudiante en la fase actual del proyecto" scope="session"/>
  <c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
</c:if>

<c:set var="flashOk" value="${esPropuesta ? 'Propuesta enviada a revisión' : 'Informe y anexos enviados a revisión'}" scope="session"/>
<c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
