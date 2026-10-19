<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-proyecto.jsp — Manejador POST para crear un proyecto (req. 70, 86-89).
  Sirve a los dos orígenes:
    - BANCO_DOCENTE: relee la idea en la BD y usa su título, objetivo, línea y
      docente (director); nunca confía en el formulario.
    - PROPIA: título, descripción y línea vienen del formulario validado.
  El estudiante 1 es SIEMPRE el de la sesión. En una sola sql:transaction: INSERT
  en proyecto, INSERT en entrega (SOPORTE_PAGO, Fase 1) y el UPDATE de proyecto que
  pasa el turno al comité por la transición ENVIAR (leída de transicion_fase). Si
  el INSERT en entrega falla (o el UPDATE afecta 0 filas) todo revierte.
--%>
<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="/estudiante/proyectos.jsp"/>
</c:if>

<c:set var="origen" value="${fn:trim(param.origen)}"/>
<c:if test="${origen ne 'BANCO_DOCENTE' and origen ne 'PROPIA'}">
  <c:set var="flashError" value="Acción no válida" scope="session"/>
  <c:redirect url="/estudiante/proyectos.jsp"/>
</c:if>

<c:set var="idIdea" value="${fn:trim(param.id_idea_docente)}"/>
<c:set var="idIdeaNum" value="0"/>
<c:if test="${origen == 'BANCO_DOCENTE' and not empty idIdea}">
  <c:catch var="errIdIdea"><c:set var="idIdeaNum" value="${idIdea + 0}"/></c:catch>
</c:if>

<c:choose>
  <c:when test="${origen == 'BANCO_DOCENTE' and not empty errIdIdea}">
    <c:set var="urlVolver" value="/estudiante/banco-ideas.jsp"/>
  </c:when>
  <c:when test="${origen == 'BANCO_DOCENTE'}">
    <c:set var="urlVolver" value="/estudiante/tomar-idea.jsp?id=${idIdeaNum}"/>
  </c:when>
  <c:otherwise>
    <c:set var="urlVolver" value="/estudiante/idea-propia.jsp"/>
  </c:otherwise>
</c:choose>

<c:set var="soportePago" value="${fn:trim(param.soporte_pago)}"/>
<c:set var="idEst2" value="${fn:trim(param.id_estudiante2)}"/>
<c:set var="titulo" value="${fn:trim(param.titulo)}"/>
<c:set var="descripcion" value="${fn:trim(param.descripcion)}"/>
<c:set var="idLinea" value="${fn:trim(param.id_linea)}"/>

<c:set var="error" value=""/>
<c:if test="${empty error and empty soportePago}"><c:set var="error" value="El soporte de pago es obligatorio"/></c:if>

<%-- URL del soporte de pago (req. 17, 20d) --%>
<c:if test="${empty error}">
  <c:set var="url" value="${soportePago}"/>
  <%@ include file="/WEB-INF/fragmentos/url-valida.jsp" %>
  <c:if test="${not urlValida}"><c:set var="error" value="La URL no tiene un formato válido"/></c:if>
</c:if>

<%-- Segundo estudiante opcional (req. 88): numérico, existe, rol Estudiante y distinto del 1 --%>
<c:set var="idEst2Num" value="0"/>
<c:if test="${empty error and not empty idEst2}">
  <c:catch var="errEst2"><c:set var="idEst2Num" value="${idEst2 + 0}"/></c:catch>
  <c:if test="${not empty errEst2 or idEst2Num <= 0}">
    <c:set var="error" value="El segundo estudiante seleccionado no es válido"/>
  </c:if>
  <c:if test="${empty error and idEst2Num == sessionScope.usuarioId}">
    <c:set var="error" value="El segundo estudiante debe ser distinto de ti"/>
  </c:if>
  <c:if test="${empty error}">
    <sql:query var="chkEst2" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM usuario WHERE id_usuario = ? AND id_rol = 4">
      <sql:param value="${idEst2Num}"/>
    </sql:query>
    <c:if test="${chkEst2.rows[0].n == 0}">
      <c:set var="error" value="El segundo estudiante debe ser un usuario con rol Estudiante"/>
    </c:if>
  </c:if>
</c:if>

<%-- Datos de origen --%>
<c:set var="tituloIdea" value=""/>
<c:set var="objetivoIdea" value=""/>
<c:set var="lineaIdea" value="0"/>
<c:set var="docenteIdea" value="0"/>
<c:choose>
  <c:when test="${origen == 'BANCO_DOCENTE'}">
    <c:if test="${empty error and (empty idIdea or idIdeaNum <= 0)}">
      <c:set var="error" value="La idea solicitada no está disponible"/>
    </c:if>
    <c:if test="${empty error}">
      <sql:query var="tomada" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_idea_docente = ?">
        <sql:param value="${idIdeaNum}"/>
      </sql:query>
      <c:if test="${tomada.rows[0].n > 0}">
        <c:set var="error" value="Esta idea ya fue tomada por otro estudiante"/>
      </c:if>
    </c:if>
    <c:if test="${empty error}">
      <sql:query var="idea" dataSource="${db}"
                 sql="SELECT titulo, objetivo, id_linea, id_docente, estado, disponibilidad
                      FROM idea_docente WHERE id_idea_docente = ?">
        <sql:param value="${idIdeaNum}"/>
      </sql:query>
      <c:if test="${idea.rowCount == 0}">
        <c:set var="error" value="La idea solicitada no está disponible"/>
      </c:if>
      <c:if test="${empty error and (idea.rows[0].estado != 'APROBADA' or idea.rows[0].disponibilidad != 'DISPONIBLE')}">
        <c:set var="error" value="La idea solicitada no está disponible"/>
      </c:if>
      <c:if test="${empty error}">
        <c:set var="tituloIdea" value="${idea.rows[0].titulo}"/>
        <c:set var="objetivoIdea" value="${idea.rows[0].objetivo}"/>
        <c:set var="lineaIdea" value="${idea.rows[0].id_linea}"/>
        <c:set var="docenteIdea" value="${idea.rows[0].id_docente}"/>
      </c:if>
    </c:if>
  </c:when>
  <c:otherwise>
    <c:if test="${empty error and empty titulo}"><c:set var="error" value="El título es obligatorio"/></c:if>
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
  </c:otherwise>
</c:choose>

<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="idProy" value="0"/>
<c:set var="filasTurno" value="0"/>
<c:set var="transOk" value="false"/>
<c:catch var="err">
  <sql:transaction dataSource="${db}">
    <c:choose>
      <c:when test="${origen == 'BANCO_DOCENTE'}">
        <sql:update sql="INSERT INTO proyecto (origen, id_idea_docente, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, id_director) VALUES ('BANCO_DOCENTE', ?, ?, ?, ?, ?, NULLIF(?, ''), ?)">
          <sql:param value="${idIdeaNum}"/>
          <sql:param value="${tituloIdea}"/>
          <sql:param value="${objetivoIdea}"/>
          <sql:param value="${lineaIdea}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${idEst2}"/>
          <sql:param value="${docenteIdea}"/>
        </sql:update>
      </c:when>
      <c:otherwise>
        <sql:update sql="INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2) VALUES ('PROPIA', ?, ?, ?, ?, NULLIF(?, ''))">
          <sql:param value="${titulo}"/>
          <sql:param value="${descripcion}"/>
          <sql:param value="${idLinea}"/>
          <sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${idEst2}"/>
        </sql:update>
      </c:otherwise>
    </c:choose>
    <sql:query var="idNuevo" sql="SELECT LAST_INSERT_ID() AS id_proyecto"/>
    <c:set var="idProy" value="${idNuevo.rows[0].id_proyecto}"/>
    <sql:query var="estadoActual" sql="SELECT id_fase, id_rol_proceso FROM proyecto WHERE id_proyecto = ?">
      <sql:param value="${idProy}"/>
    </sql:query>
    <sql:query var="trans" sql="SELECT id_fase_destino, id_rol_destino FROM transicion_fase WHERE id_fase_origen = ? AND id_rol_origen = 1 AND accion = 'ENVIAR'">
      <sql:param value="${estadoActual.rows[0].id_fase}"/>
    </sql:query>
    <c:if test="${trans.rowCount > 0}">
      <sql:update sql="INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, 'SOPORTE_PAGO', ?, ?)">
        <sql:param value="${idProy}"/>
        <sql:param value="${estadoActual.rows[0].id_fase}"/>
        <sql:param value="${soportePago}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
      </sql:update>
      <sql:update var="filasTurno" sql="UPDATE proyecto SET id_fase = ?, id_rol_proceso = ? WHERE id_proyecto = ? AND id_estudiante1 = ? AND id_fase = ? AND id_rol_proceso = 1 AND finalizado = 0">
        <sql:param value="${trans.rows[0].id_fase_destino}"/>
        <sql:param value="${trans.rows[0].id_rol_destino}"/>
        <sql:param value="${idProy}"/>
        <sql:param value="${sessionScope.usuarioId}"/>
        <sql:param value="${estadoActual.rows[0].id_fase}"/>
      </sql:update>
      <c:set var="transOk" value="true"/>
    </c:if>
  </sql:transaction>
</c:catch>

<c:set var="mensajeDuplicado" value="Esta idea ya fue tomada por otro estudiante"/>
<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:if test="${not transOk or filasTurno == 0}">
  <c:set var="flashError" value="No se pudo crear el proyecto en la Fase 1. Intenta de nuevo." scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="flashOk" value="Proyecto creado y enviado al comité en la Fase 1" scope="session"/>
<c:redirect url="/estudiante/proyecto.jsp?id=${idProy}"/>
