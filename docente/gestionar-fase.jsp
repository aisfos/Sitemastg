<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  gestionar-fase.jsp — Gestión de fases del Docente (req. 78 a 83, 20f, 67).
  Valida en el servidor: id numérico, proyecto existente y del que el docente en
  sesión sea director o evaluador (mismo mensaje de falta de permiso para el
  inexistente y el ajeno, req. 84), proyecto no finalizado (req. 67) y turno
  ("Fase N | <su rol en ese proyecto>"); si no, mensaje del req. 20f y redirige.
  Muestra el documento vigente (propuesta F-DC-124 en las fases 2 y 3; informe
  F-DC-125 con sus anexos en las fases 4 y 5), el historial y las observaciones
  mediante documentos-proyecto.jsp. Formulario: resultado (Aprobado/Aplazado) y
  comentarios obligatorios; la calificación la registra guardar-calificacion.jsp.
--%>
<c:set var="urlVolver" value="/docente/proyectos.jsp"/>
<c:set var="idProy" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="No tienes permiso para acceder a este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="d" dataSource="${db}"
           sql="SELECT id_proyecto, origen, titulo, descripcion, linea_investigacion,
                       estudiante1, estudiante2, director, evaluador, estado, fase, id_fase,
                       id_rol_proceso, rol_turno, finalizado, id_director, id_evaluador
                FROM v_proyecto WHERE id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="No tienes permiso para acceder a este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 84: solo el director o el evaluador del proyecto (mismo mensaje que inexistente) --%>
<c:set var="miRol" value="${d.rows[0].id_director == sessionScope.usuarioId ? 'Director' : (d.rows[0].id_evaluador == sessionScope.usuarioId ? 'Evaluador' : '')}"/>
<c:if test="${empty miRol}">
  <c:set var="flashError" value="No tienes permiso para acceder a este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 67: un proyecto finalizado no puede gestionarse --%>
<c:if test="${d.rows[0].finalizado}">
  <c:set var="flashError" value="El proyecto está finalizado y no puede gestionarse" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 20f: solo cuando el turno es de mi rol en ese proyecto --%>
<c:if test="${d.rows[0].rol_turno ne miRol}">
  <c:set var="flashError" value="No es el turno de tu rol en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="fase" value="${d.rows[0].id_fase + 0}"/>
<c:set var="esPropuesta" value="${fase == 2 or fase == 3}"/>
<c:set var="docIdProyecto" value="${idNum}"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestionar fases — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <div class="barra-titulo">
      <h1>Gestionar fases — Proyecto #<c:out value="${d.rows[0].id_proyecto}"/></h1>
      <a class="boton boton-secundario" href="${pageContext.request.contextPath}/docente/proyectos.jsp">Volver a Mis proyectos</a>
    </div>
    <p class="destacado"><c:out value="${d.rows[0].titulo}"/></p>
    <p>
      <span class="insignia insignia-rol insignia-grande">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>
        <c:out value="${d.rows[0].estado}"/>
      </span>
      <span class="insignia insignia-rol">Mi rol: <c:out value="${miRol}"/></span>
    </p>
    <dl>
      <dt>Estudiante 1</dt><dd><c:out value="${d.rows[0].estudiante1}"/></dd>
      <c:if test="${not empty d.rows[0].estudiante2}">
        <dt>Estudiante 2</dt><dd><c:out value="${d.rows[0].estudiante2}"/></dd>
      </c:if>
      <dt>Director</dt><dd><c:out value="${empty d.rows[0].director ? 'Por asignar' : d.rows[0].director}"/></dd>
      <dt>Evaluador</dt><dd><c:out value="${empty d.rows[0].evaluador ? 'Por asignar' : d.rows[0].evaluador}"/></dd>
    </dl>
    <details class="detalle-fases" open>
      <summary>Seguimiento de las seis fases</summary>
      <c:set var="faseActual" value="${d.rows[0].id_fase}"/>
      <c:set var="finalizado" value="${false}"/>
      <%@ include file="/WEB-INF/fragmentos/seguimiento-fases.jsp" %>
    </details>
  </section>

  <%@ include file="/WEB-INF/fragmentos/documentos-proyecto.jsp" %>

  <section class="tarjeta">
    <h2>Calificación de la Fase <c:out value="${fase}"/> | <c:out value="${miRol}"/></h2>
    <p class="aviso">
      <c:choose>
        <c:when test="${fase == 2}">Revisa la propuesta F-DC-124. Al aprobar, el proyecto pasa a <strong>Fase 3 | Evaluador</strong>; al aplazar, vuelve al estudiante.</c:when>
        <c:when test="${fase == 3}">Revisa la propuesta F-DC-124 que aprobó el director. Al aprobar, el proyecto pasa a <strong>Fase 3 | Comité</strong>; al aplazar, vuelve al estudiante.</c:when>
        <c:when test="${fase == 4}">Revisa el informe F-DC-125 con sus anexos. Al aprobar, el proyecto pasa a <strong>Fase 5 | Evaluador</strong>; al aplazar, vuelve al estudiante.</c:when>
        <c:otherwise>Revisa el informe F-DC-125 con sus anexos que aprobó el director. Al aprobar, el proyecto pasa a <strong>Fase 5 | Comité</strong>; al aplazar, vuelve al estudiante.</c:otherwise>
      </c:choose>
    </p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/docente/guardar-calificacion.jsp">
      <input type="hidden" name="id_proyecto" value="<c:out value='${idNum}'/>">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Decisión de tu revisión</legend>
        <div class="campo">
          <label class="etiqueta" for="resultado">Resultado</label>
          <select class="seleccion" id="resultado" name="resultado" required>
            <option value="">Selecciona…</option>
            <option value="APROBADO">Aprobado</option>
            <option value="APLAZADO">Aplazado</option>
          </select>
          <p class="ayuda">Solo Aprobado o Aplazado.</p>
        </div>
        <div class="campo">
          <label class="etiqueta" for="comentarios">Comentarios</label>
          <textarea class="area" id="comentarios" name="comentarios" rows="4" maxlength="1000" required></textarea>
          <p class="ayuda">Obligatorios, máximo 1000 caracteres.</p>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">Registrar calificación</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/docente/proyectos.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
