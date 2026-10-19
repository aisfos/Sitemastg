<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  idea-docente-revisar.jsp — Formulario del Comité para APROBAR (req. 50) o
  APLAZAR (req. 51) una idea PENDIENTE del banco.
  La acción llega por GET (?accion=aprobar|aplazar) y se valida contra lista
  fija; el guardado es un POST al manejador. Si la idea no está PENDIENTE se
  redirige con mensaje claro.
--%>
<c:set var="idIdea" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${empty idIdea or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<c:set var="accion" value="${fn:trim(param.accion)}"/>
<c:if test="${accion ne 'aprobar' and accion ne 'aplazar'}">
  <c:set var="flashError" value="Acción no válida" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<sql:query var="d" dataSource="${db}"
           sql="SELECT id_idea_docente, titulo, objetivo, linea_investigacion, nivel_academico, periodo_academico, id_docente, docente, estado
                FROM v_idea_docente
                WHERE id_idea_docente = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<c:if test="${d.rows[0].estado != 'PENDIENTE'}">
  <c:set var="flashError" value="Solo se pueden aprobar o aplazar ideas en estado Pendiente" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${accion == 'aprobar' ? 'Aprobar idea' : 'Aplazar idea'} — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>${accion == 'aprobar' ? 'Aprobar idea' : 'Aplazar idea'}</h1>
    <p class="aviso">
      <strong><c:out value="${d.rows[0].titulo}"/></strong><br>
      Docente: <span class="celda-persona"><c:set var="avatarId" value="${d.rows[0].id_docente}"/><c:set var="avatarNombre" value="${d.rows[0].docente}"/><%@ include file="/WEB-INF/fragmentos/avatar.jsp" %><c:out value="${d.rows[0].docente}"/></span> ·
      Línea: <c:out value="${d.rows[0].linea_investigacion}"/> ·
      Nivel: <c:out value="${d.rows[0].nivel_academico}"/> ·
      Periodo: <c:out value="${d.rows[0].periodo_academico}"/>
    </p>
    <p class="aviso">
      <c:choose>
        <c:when test="${accion == 'aprobar'}">Al aprobar, la idea se publica y queda <strong>Disponible</strong> para que los estudiantes la tomen. La idea del docente se aprueba sin soporte de pago.</c:when>
        <c:otherwise>Al aplazar, el docente podrá corregir la idea y volver a enviarla.</c:otherwise>
      </c:choose>
    </p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/comite/guardar-idea-docente.jsp">
      <input type="hidden" name="id_idea_docente" value="<c:out value='${d.rows[0].id_idea_docente}'/>">
      <input type="hidden" name="accion" value="<c:out value='${accion}'/>">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Decisión</legend>
        <div class="campo">
          <label class="etiqueta" for="acta_numero">Número de acta</label>
          <input class="entrada" type="text" id="acta_numero" name="acta_numero" maxlength="30" value="">
          <p class="ayuda">Obligatorio, máximo 30 caracteres.</p>
        </div>
        <c:if test="${accion == 'aplazar'}">
          <div class="campo">
            <label class="etiqueta" for="motivo">Motivo del aplazamiento</label>
            <textarea class="area" id="motivo" name="motivo" rows="5" maxlength="1000"></textarea>
            <p class="ayuda">Obligatorio, máximo 1000 caracteres.</p>
          </div>
        </c:if>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">${accion == 'aprobar' ? 'Aprobar idea' : 'Aplazar idea'}</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/ideas-docentes.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
