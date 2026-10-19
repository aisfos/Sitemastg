<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  idea-propia.jsp — Proponer una idea propia (req. 87, 88, 89).
  Formulario con título, descripción, línea de investigación, soporte de pago (URL)
  y segundo estudiante opcional. El proyecto nace PROPIA y pasa al comité en Fase 1;
  el director y el evaluador los asigna el comité al aprobar.
--%>
<sql:query var="lineas" dataSource="${db}" sql="SELECT id_linea, nombre FROM linea_investigacion ORDER BY nombre"/>
<sql:query var="estudiantes" dataSource="${db}"
           sql="SELECT id_usuario, nombre_completo, numero_documento FROM usuario WHERE id_rol = 4 AND id_usuario <> ? ORDER BY nombre_completo">
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Proponer idea propia — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>Proponer una idea propia</h1>
    <p class="aviso">Tu idea se crea en la Fase 1 y pasa al comité, que asignará al director y al evaluador.</p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/estudiante/guardar-proyecto.jsp" data-validar-url>
      <input type="hidden" name="origen" value="PROPIA">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Datos de la idea</legend>
        <div class="campo">
          <label class="etiqueta" for="titulo">Título</label>
          <input class="entrada" type="text" id="titulo" name="titulo" maxlength="200" value="">
          <p class="ayuda">Obligatorio, máximo 200 caracteres.</p>
        </div>
        <div class="campo">
          <label class="etiqueta" for="descripcion">Descripción</label>
          <textarea class="area" id="descripcion" name="descripcion" rows="6" maxlength="2000"></textarea>
          <p class="ayuda">Obligatoria, máximo 2000 caracteres.</p>
        </div>
        <div class="campo">
          <label class="etiqueta" for="id_linea">Línea de investigación</label>
          <select class="seleccion" id="id_linea" name="id_linea">
            <option value="">-- Selecciona --</option>
            <c:forEach var="l" items="${lineas.rows}">
              <option value="${l.id_linea}"><c:out value="${l.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
      </fieldset>
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
          <p class="ayuda">El segundo integrante solo queda como miembro del equipo; el proyecto lo ve únicamente el estudiante 1.</p>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">Crear proyecto</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyectos.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
<script src="${pageContext.request.contextPath}/js/url-valida.js"></script>
</body>
</html>
