<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  tomar-idea.jsp — Tomar una idea del banco (req. 86, 88, 89).
  Muestra la idea en solo lectura y pide el soporte de pago (URL obligatoria) y un
  segundo estudiante opcional. El id llega por GET (?id=N) y se valida; si la idea
  no está aprobada y disponible (o ya la tomó otro proyecto) se rechaza.
  El estudiante 1 y el director SIEMPRE salen de la BD, nunca del formulario.
--%>
<c:set var="urlVolver" value="/estudiante/banco-ideas.jsp"/>
<c:set var="idIdea" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${empty idIdea or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="La idea solicitada no está disponible" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="idea" dataSource="${db}"
           sql="SELECT id_idea_docente, titulo, objetivo, linea_investigacion, nivel_academico, periodo_academico, docente, id_docente, estado, disponibilidad
                FROM v_idea_docente v
                WHERE v.id_idea_docente = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${idea.rowCount == 0}">
  <c:set var="flashError" value="La idea solicitada no está disponible" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="tomada" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_idea_docente = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${tomada.rows[0].n > 0}">
  <c:set var="flashError" value="Esta idea ya fue tomada por otro estudiante" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:if test="${idea.rows[0].estado != 'APROBADA' or idea.rows[0].disponibilidad != 'DISPONIBLE'}">
  <c:set var="flashError" value="La idea solicitada no está disponible" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="estudiantes" dataSource="${db}"
           sql="SELECT id_usuario, nombre_completo, numero_documento FROM usuario WHERE id_rol = 4 AND id_usuario <> ? ORDER BY nombre_completo">
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tomar idea del banco — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>Tomar esta idea</h1>
    <p class="aviso">
      <strong><c:out value="${idea.rows[0].titulo}"/></strong><br>
      Objetivo: <c:out value="${idea.rows[0].objetivo}"/><br>
      Línea: <c:out value="${idea.rows[0].linea_investigacion}"/>
      · Nivel: <c:out value="${idea.rows[0].nivel_academico}"/>
      · Periodo: <c:out value="${idea.rows[0].periodo_academico}"/><br>
      Director (docente proponente): <strong><c:out value="${idea.rows[0].docente}"/></strong>
    </p>
    <p class="ayuda">Al crear el proyecto con esta idea, el docente proponente queda como director y el proyecto pasa al comité en la Fase 1.</p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/estudiante/guardar-proyecto.jsp" data-validar-url>
      <input type="hidden" name="origen" value="BANCO_DOCENTE">
      <input type="hidden" name="id_idea_docente" value="<c:out value='${idea.rows[0].id_idea_docente}'/>">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Documento y enlaces</legend>
        <div class="campo">
          <label class="etiqueta" for="soporte_pago">Soporte de pago (URL)</label>
          <input class="entrada" type="text" id="soporte_pago" name="soporte_pago" maxlength="500" data-tipo-url
                 placeholder="https://...">
          <p class="ayuda">Obligatorio. Debe empezar por http:// o https:// y no contener espacios ni comillas.</p>
        </div>
      </fieldset>
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Equipo</legend>
        <div class="campo">
          <label class="etiqueta" for="id_estudiante2">Segundo estudiante (opcional)</label>
          <select class="seleccion" id="id_estudiante2" name="id_estudiante2">
            <option value="">Sin segundo integrante</option>
            <c:forEach var="est" items="${estudiantes.rows}">
              <option value="${est.id_usuario}"><c:out value="${est.nombre_completo}"/> — <c:out value="${est.numero_documento}"/></option>
            </c:forEach>
          </select>
          <p class="ayuda">En la Fase 1 eres el estudiante 1; el segundo integrante solo queda como miembro del equipo.</p>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">Crear proyecto</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
<script src="${pageContext.request.contextPath}/js/url-valida.js"></script>
</body>
</html>
