<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="3"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  idea-form.jsp — Proponer una idea (req. 73) o corregir una aplazada (req. 51).
  Con ?id=N entra en modo corrección: solo si la idea es del docente en sesión
  y está en estado APLAZADA. El docente NUNCA sale del formulario: se toma de
  la sesión. Estado y disponibilidad tampoco se envían.
--%>
<c:set var="idIdea" value="${param.id}"/>
<c:set var="modoEdicion" value="${not empty idIdea}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${modoEdicion and (not empty errIdNum or idNum <= 0)}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/docente/ideas.jsp"/>
</c:if>
<c:if test="${modoEdicion}">
  <sql:query var="d" dataSource="${db}"
             sql="SELECT id_idea_docente, titulo, objetivo, id_linea, id_nivel_academico, id_periodo, estado, acta_numero, motivo_aplazamiento
                  FROM idea_docente
                  WHERE id_idea_docente = ? AND id_docente = ?">
    <sql:param value="${idNum}"/>
    <sql:param value="${sessionScope.usuarioId}"/>
  </sql:query>
  <c:if test="${d.rowCount == 0}">
    <c:set var="flashError" value="La idea no existe o no es tuya" scope="session"/>
    <c:redirect url="/docente/ideas.jsp"/>
  </c:if>
  <c:if test="${d.rows[0].estado != 'APLAZADA'}">
    <c:set var="flashError" value="Solo se pueden corregir ideas que estén aplazadas" scope="session"/>
    <c:redirect url="/docente/ideas.jsp"/>
  </c:if>
</c:if>
<sql:query var="lineas" dataSource="${db}" sql="SELECT id_linea, nombre FROM linea_investigacion ORDER BY nombre"/>
<sql:query var="niveles" dataSource="${db}" sql="SELECT id_nivel_academico, nombre FROM nivel_academico ORDER BY id_nivel_academico"/>
<sql:query var="periodos" dataSource="${db}" sql="SELECT id_periodo, nombre FROM periodo_academico ORDER BY id_periodo"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${modoEdicion ? 'Corregir idea' : 'Proponer idea'} — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>${modoEdicion ? 'Corregir idea' : 'Proponer idea'}</h1>
    <c:if test="${modoEdicion}">
      <p class="alerta alerta-error" role="alert">
        La idea fue aplazada con el acta <strong><c:out value="${d.rows[0].acta_numero}"/></strong>.
        Motivo: <c:out value="${d.rows[0].motivo_aplazamiento}"/>.
        Al guardar los cambios, la idea vuelve a estado <strong>Pendiente</strong> para una nueva revisión.
      </p>
    </c:if>
    <p class="aviso">
      Al aprobarse la idea, quedarás como <strong>director</strong> del proyecto de esa idea.
    </p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/docente/guardar-idea.jsp">
      <input type="hidden" name="id_idea_docente" value="<c:out value='${d.rows[0].id_idea_docente}'/>">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Datos de la idea</legend>
        <div class="campo">
          <label class="etiqueta" for="titulo">Título</label>
          <input class="entrada" type="text" id="titulo" name="titulo" maxlength="200"
                 value="<c:out value='${d.rows[0].titulo}'/>">
        </div>
        <div class="campo">
          <label class="etiqueta" for="objetivo">Objetivo</label>
          <textarea class="area" id="objetivo" name="objetivo" rows="6" maxlength="2000"><c:out value="${d.rows[0].objetivo}"/></textarea>
        </div>
      </fieldset>
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Clasificación académica</legend>
        <div class="campo">
          <label class="etiqueta" for="id_linea">Línea de investigación</label>
          <select class="seleccion" id="id_linea" name="id_linea">
            <option value="">-- Selecciona --</option>
            <c:forEach var="l" items="${lineas.rows}">
              <option value="${l.id_linea}"<c:if test="${l.id_linea eq d.rows[0].id_linea}"> selected</c:if>><c:out value="${l.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
        <div class="campo">
          <label class="etiqueta" for="id_nivel_academico">Nivel académico</label>
          <select class="seleccion" id="id_nivel_academico" name="id_nivel_academico">
            <option value="">-- Selecciona --</option>
            <c:forEach var="n" items="${niveles.rows}">
              <option value="${n.id_nivel_academico}"<c:if test="${n.id_nivel_academico eq d.rows[0].id_nivel_academico}"> selected</c:if>><c:out value="${n.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
        <div class="campo">
          <label class="etiqueta" for="id_periodo">Periodo académico</label>
          <select class="seleccion" id="id_periodo" name="id_periodo">
            <option value="">-- Selecciona --</option>
            <c:forEach var="p" items="${periodos.rows}">
              <option value="${p.id_periodo}"<c:if test="${p.id_periodo eq d.rows[0].id_periodo}"> selected</c:if>><c:out value="${p.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">${modoEdicion ? 'Guardar corrección' : 'Proponer idea'}</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/docente/ideas.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
