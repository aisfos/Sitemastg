<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-idea-docente.jsp — Manejador POST del Comité para el Banco de Ideas
  Docente: aprobar (req. 50), aplazar (req. 51) y editar estado/disponibilidad
  (req. 52). Redirigir-después-de-enviar.

  Seguridad:
    - Solo POST; la acción se valida contra una lista fija.
    - El id se valida numéricamente.
    - aprobar/aplazar solo desde PENDIENTE (UPDATE condicionado).
    - editar solo si ningún proyecto usa la idea y con reglas de estado/
      disponibilidad validadas aquí, no delegadas al CHECK de la BD.
--%>
<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:set var="accion" value="${fn:trim(param.accion)}"/>
<c:if test="${accion ne 'aprobar' and accion ne 'aplazar' and accion ne 'editar'}">
  <c:set var="flashError" value="Acción no válida" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:set var="idIdea" value="${fn:trim(param.id_idea_docente)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${empty idIdea or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>

<c:set var="urlVolver" value="/comite/ideas-docentes.jsp"/>

<c:choose>

  <%-- ======================= APROBAR (req. 50) ======================= --%>
  <c:when test="${accion == 'aprobar'}">
    <c:set var="acta" value="${fn:trim(param.acta_numero)}"/>
    <c:set var="error" value=""/>
    <c:if test="${empty acta}"><c:set var="error" value="El número de acta es obligatorio"/></c:if>
    <c:if test="${empty error and fn:length(acta) > 30}"><c:set var="error" value="El número de acta no puede superar los 30 caracteres"/></c:if>
    <c:if test="${not empty error}">
      <c:set var="flashError" value="${error}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>

    <c:set var="filas" value="0"/>
    <c:catch var="err">
      <sql:update var="filas" dataSource="${db}"
                  sql="UPDATE idea_docente SET estado = 'APROBADA', acta_numero = ?, disponibilidad = 'DISPONIBLE', motivo_aplazamiento = NULL, fecha_revision = NOW() WHERE id_idea_docente = ? AND estado = 'PENDIENTE'">
        <sql:param value="${acta}"/>
        <sql:param value="${idNum}"/>
      </sql:update>
    </c:catch>
    <%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
    <c:if test="${not empty err}">
      <c:set var="flashError" value="${mensajeBd}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>
    <c:if test="${filas == 0}">
      <c:set var="flashError" value="La idea ya no está pendiente" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>
    <c:set var="flashOk" value="Idea aprobada y publicada como disponible" scope="session"/>
    <c:redirect url="${urlVolver}"/>
  </c:when>

  <%-- ======================= APLAZAR (req. 51) ======================= --%>
  <c:when test="${accion == 'aplazar'}">
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

    <c:set var="filas" value="0"/>
    <c:catch var="err">
      <sql:update var="filas" dataSource="${db}"
                  sql="UPDATE idea_docente SET estado = 'APLAZADA', acta_numero = ?, motivo_aplazamiento = ?, disponibilidad = 'NO_DISPONIBLE', fecha_revision = NOW() WHERE id_idea_docente = ? AND estado = 'PENDIENTE'">
        <sql:param value="${acta}"/>
        <sql:param value="${motivo}"/>
        <sql:param value="${idNum}"/>
      </sql:update>
    </c:catch>
    <%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
    <c:if test="${not empty err}">
      <c:set var="flashError" value="${mensajeBd}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>
    <c:if test="${filas == 0}">
      <c:set var="flashError" value="La idea ya no está pendiente" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>
    <c:set var="flashOk" value="Idea aplazada; el docente podrá corregirla" scope="session"/>
    <c:redirect url="${urlVolver}"/>
  </c:when>

  <%-- ============ EDITAR estado y disponibilidad (req. 52) ============ --%>
  <c:otherwise>
    <c:set var="estado" value="${fn:trim(param.estado)}"/>
    <c:set var="disponibilidad" value="${fn:trim(param.disponibilidad)}"/>
    <c:set var="acta" value="${fn:trim(param.acta_numero)}"/>
    <c:set var="motivo" value="${fn:trim(param.motivo)}"/>
    <c:set var="error" value=""/>

    <%-- Reglas validadas en el servidor, no delegadas al CHECK de la BD --%>
    <c:if test="${estado ne 'PENDIENTE' and estado ne 'APROBADA' and estado ne 'APLAZADA'}">
      <c:set var="error" value="El estado seleccionado no es válido"/>
    </c:if>
    <c:if test="${empty error and disponibilidad ne 'DISPONIBLE' and disponibilidad ne 'NO_DISPONIBLE'}">
      <c:set var="error" value="La disponibilidad seleccionada no es válida"/>
    </c:if>
    <c:if test="${empty error and estado == 'APROBADA' and empty acta}">
      <c:set var="error" value="Para aprobar una idea debes registrar el número de acta"/>
    </c:if>
    <c:if test="${empty error and estado == 'APLAZADA' and empty acta}">
      <c:set var="error" value="Para aplazar una idea debes registrar el número de acta"/>
    </c:if>
    <c:if test="${empty error and estado == 'APLAZADA' and empty motivo}">
      <c:set var="error" value="Para aplazar una idea debes registrar el motivo"/>
    </c:if>
    <c:if test="${empty error and estado == 'APLAZADA' and disponibilidad == 'DISPONIBLE'}">
      <c:set var="error" value="Una idea aplazada no puede quedar disponible"/>
    </c:if>
    <c:if test="${empty error and fn:length(acta) > 30}">
      <c:set var="error" value="El número de acta no puede superar los 30 caracteres"/>
    </c:if>
    <c:if test="${empty error and fn:length(motivo) > 1000}">
      <c:set var="error" value="El motivo no puede superar los 1000 caracteres"/>
    </c:if>

    <%-- Una idea tomada por un proyecto no se puede editar (decisión (c)) --%>
    <c:if test="${empty error}">
      <sql:query var="usada" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_idea_docente = ?">
        <sql:param value="${idNum}"/>
      </sql:query>
      <c:if test="${usada.rows[0].n > 0}">
        <c:set var="error" value="No se puede editar una idea que ya fue tomada por un proyecto"/>
      </c:if>
    </c:if>

    <c:if test="${not empty error}">
      <c:set var="flashError" value="${error}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>

    <c:set var="filas" value="0"/>
    <c:choose>
      <c:when test="${estado == 'PENDIENTE'}">
        <c:catch var="err">
          <sql:update var="filas" dataSource="${db}"
                      sql="UPDATE idea_docente SET estado = 'PENDIENTE', disponibilidad = 'NO_DISPONIBLE', acta_numero = NULL, motivo_aplazamiento = NULL, fecha_revision = NULL WHERE id_idea_docente = ?">
            <sql:param value="${idNum}"/>
          </sql:update>
        </c:catch>
      </c:when>
      <c:when test="${estado == 'APROBADA'}">
        <c:catch var="err">
          <sql:update var="filas" dataSource="${db}"
                      sql="UPDATE idea_docente SET estado = 'APROBADA', disponibilidad = ?, acta_numero = ?, motivo_aplazamiento = NULL, fecha_revision = NOW() WHERE id_idea_docente = ?">
            <sql:param value="${disponibilidad}"/>
            <sql:param value="${acta}"/>
            <sql:param value="${idNum}"/>
          </sql:update>
        </c:catch>
      </c:when>
      <c:otherwise>
        <c:catch var="err">
          <sql:update var="filas" dataSource="${db}"
                      sql="UPDATE idea_docente SET estado = 'APLAZADA', disponibilidad = 'NO_DISPONIBLE', acta_numero = ?, motivo_aplazamiento = ?, fecha_revision = NOW() WHERE id_idea_docente = ?">
            <sql:param value="${acta}"/>
            <sql:param value="${motivo}"/>
            <sql:param value="${idNum}"/>
          </sql:update>
        </c:catch>
      </c:otherwise>
    </c:choose>
    <%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
    <c:if test="${not empty err}">
      <c:set var="flashError" value="${mensajeBd}" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>
    <c:if test="${filas == 0}">
      <c:set var="flashError" value="La idea no existe" scope="session"/>
      <c:redirect url="${urlVolver}"/>
    </c:if>
    <c:set var="flashOk" value="Idea actualizada" scope="session"/>
    <c:redirect url="${urlVolver}"/>
  </c:otherwise>

</c:choose>
