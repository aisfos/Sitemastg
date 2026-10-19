<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  idea-docente-editar.jsp — Editar estado y disponibilidad de una idea (req. 52).
  El Comité NUNCA cambia título, objetivo, línea, nivel, periodo ni docente
  (req. 54). Si algún proyecto ya usa la idea, no se puede editar.
--%>
<c:set var="idIdea" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idIdea + 0}"/></c:catch>
<c:if test="${empty idIdea or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<sql:query var="d" dataSource="${db}"
           sql="SELECT id_idea_docente, titulo, estado, disponibilidad, acta_numero, motivo_aplazamiento
                FROM v_idea_docente
                WHERE id_idea_docente = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="La idea solicitada no existe" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<sql:query var="usada" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_idea_docente = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${usada.rows[0].n > 0}">
  <c:set var="flashError" value="No se puede editar una idea que ya fue tomada por un proyecto" scope="session"/>
  <c:redirect url="/comite/ideas-docentes.jsp"/>
</c:if>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Editar idea — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>Editar estado y disponibilidad</h1>
    <p class="aviso">
      <strong><c:out value="${d.rows[0].titulo}"/></strong><br>
      El Comité solo cambia el <strong>estado</strong> y la <strong>disponibilidad</strong>; el título, el objetivo, la línea, el nivel, el periodo y el docente no se modifican.
    </p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/comite/guardar-idea-docente.jsp">
      <input type="hidden" name="id_idea_docente" value="<c:out value='${d.rows[0].id_idea_docente}'/>">
      <input type="hidden" name="accion" value="editar">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Estado y disponibilidad</legend>
        <div class="campo">
          <label class="etiqueta" for="estado">Estado</label>
          <select class="seleccion" id="estado" name="estado">
            <option value="PENDIENTE"<c:if test="${d.rows[0].estado == 'PENDIENTE'}"> selected</c:if>>Pendiente</option>
            <option value="APROBADA"<c:if test="${d.rows[0].estado == 'APROBADA'}"> selected</c:if>>Aprobada</option>
            <option value="APLAZADA"<c:if test="${d.rows[0].estado == 'APLAZADA'}"> selected</c:if>>Aplazada</option>
          </select>
        </div>
        <div class="campo">
          <label class="etiqueta" for="disponibilidad">Disponibilidad</label>
          <select class="seleccion" id="disponibilidad" name="disponibilidad">
            <option value="NO_DISPONIBLE"<c:if test="${d.rows[0].disponibilidad == 'NO_DISPONIBLE'}"> selected</c:if>>No disponible</option>
            <option value="DISPONIBLE"<c:if test="${d.rows[0].disponibilidad == 'DISPONIBLE'}"> selected</c:if>>Disponible</option>
          </select>
          <p class="ayuda">Disponible solo cuando el estado es Aprobada. Pendiente y Aplazada quedan No disponible.</p>
        </div>
      </fieldset>
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Acta y motivo</legend>
        <div class="campo">
          <label class="etiqueta" for="acta_numero">Número de acta</label>
          <input class="entrada" type="text" id="acta_numero" name="acta_numero" maxlength="30" value="<c:out value='${d.rows[0].acta_numero}'/>">
          <p class="ayuda">Obligatorio para Aprobada y Aplazada.</p>
        </div>
        <div class="campo">
          <label class="etiqueta" for="motivo">Motivo del aplazamiento</label>
          <textarea class="area" id="motivo" name="motivo" rows="5" maxlength="1000"><c:out value="${d.rows[0].motivo_aplazamiento}"/></textarea>
          <p class="ayuda">Obligatorio cuando el estado es Aplazada; máximo 1000 caracteres.</p>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">Guardar cambios</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/ideas-docentes.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
