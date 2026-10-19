<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-idea.jsp — Manejador POST para proponer (req. 73) y corregir (req. 51)
  una idea del Banco de Ideas Docente. Redirigir-después-de-enviar.

  Seguridad:
    - El docente SIEMPRE se toma de la sesión (nunca del formulario).
    - Estado y disponibilidad nunca se leen del formulario (los pone la BD).
    - Corregir solo afecta ideas propias y aplazadas (filtro en el UPDATE).
--%>
<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="/docente/ideas.jsp"/>
</c:if>

<c:set var="idIdea" value="${fn:trim(param.id_idea_docente)}"/>
<c:set var="modoEdicion" value="${not empty idIdea}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${modoEdicion and (not empty errIdNum or idNum <= 0)}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/docente/ideas.jsp"/>
</c:if>

<c:set var="titulo" value="${fn:trim(param.titulo)}"/>
<c:set var="objetivo" value="${fn:trim(param.objetivo)}"/>
<c:set var="idLinea" value="${fn:trim(param.id_linea)}"/>
<c:set var="idNivel" value="${fn:trim(param.id_nivel_academico)}"/>
<c:set var="idPeriodo" value="${fn:trim(param.id_periodo)}"/>

<c:choose>
  <c:when test="${modoEdicion}"><c:set var="urlVolver" value="/docente/idea-form.jsp?id=${idNum}"/></c:when>
  <c:otherwise><c:set var="urlVolver" value="/docente/idea-form.jsp"/></c:otherwise>
</c:choose>

<%-- Campos obligatorios (req. 20b) y largos máximos --%>
<c:set var="error" value=""/>
<c:if test="${empty error and empty titulo}"><c:set var="error" value="El título es obligatorio"/></c:if>
<c:if test="${empty error and empty objetivo}"><c:set var="error" value="El objetivo es obligatorio"/></c:if>
<c:if test="${empty error and empty idLinea}"><c:set var="error" value="La línea de investigación es obligatoria"/></c:if>
<c:if test="${empty error and empty idNivel}"><c:set var="error" value="El nivel académico es obligatorio"/></c:if>
<c:if test="${empty error and empty idPeriodo}"><c:set var="error" value="El periodo académico es obligatorio"/></c:if>
<c:if test="${empty error and fn:length(titulo) > 200}"><c:set var="error" value="El título no puede superar los 200 caracteres"/></c:if>
<c:if test="${empty error and fn:length(objetivo) > 2000}"><c:set var="error" value="El objetivo no puede superar los 2000 caracteres"/></c:if>

<%-- Catálogos: validar que línea, nivel y periodo existan (mensaje propio, no FK) --%>
<c:if test="${empty error}">
  <sql:query var="chkLinea" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM linea_investigacion WHERE id_linea = ?">
    <sql:param value="${idLinea}"/>
  </sql:query>
  <c:if test="${chkLinea.rows[0].n == 0}"><c:set var="error" value="La línea de investigación seleccionada no es válida"/></c:if>
</c:if>
<c:if test="${empty error}">
  <sql:query var="chkNivel" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM nivel_academico WHERE id_nivel_academico = ?">
    <sql:param value="${idNivel}"/>
  </sql:query>
  <c:if test="${chkNivel.rows[0].n == 0}"><c:set var="error" value="El nivel académico seleccionado no es válido"/></c:if>
</c:if>
<c:if test="${empty error}">
  <sql:query var="chkPeriodo" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM periodo_academico WHERE id_periodo = ?">
    <sql:param value="${idPeriodo}"/>
  </sql:query>
  <c:if test="${chkPeriodo.rows[0].n == 0}"><c:set var="error" value="El periodo académico seleccionado no es válido"/></c:if>
</c:if>

<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="filas" value="0"/>
<c:choose>
  <c:when test="${modoEdicion}">
    <c:catch var="err">
      <sql:update var="filas" dataSource="${db}"
                  sql="UPDATE idea_docente SET titulo = ?, objetivo = ?, id_linea = ?, id_nivel_academico = ?, id_periodo = ?, estado = 'PENDIENTE', acta_numero = NULL, motivo_aplazamiento = NULL, fecha_revision = NULL WHERE id_idea_docente = ? AND id_docente = ? AND estado = 'APLAZADA'">
        <sql:param value="${titulo}"/>
        <sql:param value="${objetivo}"/>
        <sql:param value="${idLinea}"/>
        <sql:param value="${idNivel}"/>
        <sql:param value="${idPeriodo}"/>
        <sql:param value="${idNum}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:catch>
  </c:when>
  <c:otherwise>
    <c:catch var="err">
      <sql:update var="filas" dataSource="${db}"
                  sql="INSERT INTO idea_docente (titulo, objetivo, id_linea, id_nivel_academico, id_periodo, id_docente) VALUES (?, ?, ?, ?, ?, ?)">
        <sql:param value="${titulo}"/>
        <sql:param value="${objetivo}"/>
        <sql:param value="${idLinea}"/>
        <sql:param value="${idNivel}"/>
        <sql:param value="${idPeriodo}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
    </c:catch>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<%-- Corregir: si no se actualizó ninguna fila, la idea no era propia o ya no
     estaba aplazada; no se revela la causa. --%>
<c:if test="${modoEdicion and filas == 0}">
  <c:set var="flashError" value="La idea no existe, no es tuya o ya no está aplazada" scope="session"/>
  <c:redirect url="/docente/ideas.jsp"/>
</c:if>

<c:set var="flashOk" value="${modoEdicion ? 'Idea corregida y enviada de nuevo a revisión' : 'Idea propuesta correctamente'}" scope="session"/>
<c:redirect url="/docente/ideas.jsp"/>
