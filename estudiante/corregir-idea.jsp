<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  corregir-idea.jsp — Corregir y reenviar la Fase 1 (req. 5, 91).
  Solo cuando el proyecto está en "Fase 1 | Estudiante" (tras un aplazamiento del
  comité). Arriba se muestra el motivo del aplazamiento (último comentario de
  revisión). Proyecto PROPIA: se corrigen título, descripción y línea, y se puede
  subir un nuevo soporte de pago. Proyecto del BANCO: solo se sube un nuevo soporte
  de pago (título, descripción y línea no se pueden modificar; decisión (g)).
--%>
<c:set var="urlVolver" value="/estudiante/proyectos.jsp"/>
<c:set var="idProy" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="No tienes permiso para ver este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="d" dataSource="${db}"
           sql="SELECT vpe.id_proyecto, vpe.titulo, vpe.descripcion, vpe.linea_investigacion, vpe.estado,
                       p.id_fase, p.id_rol_proceso, p.finalizado, p.origen, p.id_linea
                FROM v_proyecto_estudiante vpe
                JOIN proyecto p ON p.id_proyecto = vpe.id_proyecto
                WHERE vpe.id_proyecto = ? AND vpe.id_estudiante1 = ?">
  <sql:param value="${idNum}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="No tienes permiso para ver este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="urlProyecto" value="/estudiante/proyecto.jsp?id=${idNum}"/>
<c:if test="${d.rows[0].finalizado or d.rows[0].id_fase != 1 or d.rows[0].id_rol_proceso != 1}">
  <c:set var="flashError" value="No es el turno del Estudiante en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlProyecto}"/>
</c:if>
<sql:query var="ultima" dataSource="${db}"
           sql="SELECT comentarios, fecha_revision FROM v_historial_revisiones WHERE id_proyecto = ? ORDER BY fecha_revision DESC, id_revision DESC LIMIT 1">
  <sql:param value="${idNum}"/>
</sql:query>
<sql:query var="lineas" dataSource="${db}" sql="SELECT id_linea, nombre FROM linea_investigacion ORDER BY nombre"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Corregir y reenviar — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>Corregir y reenviar la idea</h1>
    <c:if test="${ultima.rowCount > 0}">
      <p class="alerta alerta-error" role="alert">
        Motivo del aplazamiento: <c:out value="${ultima.rows[0].comentarios}"/>
      </p>
    </c:if>
    <p class="aviso">
      Estado actual: <span class="insignia insignia-rol"><c:out value="${d.rows[0].estado}"/></span>.
      Al reenviar, tu idea vuelve al comité en <strong>Fase 1 | Comité</strong>.
    </p>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/estudiante/guardar-correccion.jsp" data-validar-url>
      <input type="hidden" name="id_proyecto" value="<c:out value='${d.rows[0].id_proyecto}'/>">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Datos de la idea</legend>
        <c:choose>
          <c:when test="${d.rows[0].origen == 'PROPIA'}">
            <div class="campo">
              <label class="etiqueta" for="titulo">Título</label>
              <input class="entrada" type="text" id="titulo" name="titulo" maxlength="200" value="<c:out value='${d.rows[0].titulo}'/>">
            </div>
            <div class="campo">
              <label class="etiqueta" for="descripcion">Descripción</label>
              <textarea class="area" id="descripcion" name="descripcion" rows="6" maxlength="2000"><c:out value="${d.rows[0].descripcion}"/></textarea>
            </div>
            <div class="campo">
              <label class="etiqueta" for="id_linea">Línea de investigación</label>
              <select class="seleccion" id="id_linea" name="id_linea">
                <c:forEach var="l" items="${lineas.rows}">
                  <option value="${l.id_linea}"<c:if test="${l.id_linea eq d.rows[0].id_linea}"> selected</c:if>><c:out value="${l.nombre}"/></option>
                </c:forEach>
              </select>
            </div>
          </c:when>
          <c:otherwise>
            <p class="aviso">
              Idea del banco: <strong><c:out value="${d.rows[0].titulo}"/></strong><br>
              Línea: <c:out value="${d.rows[0].linea_investigacion}"/>
            </p>
            <p class="ayuda">En una idea del banco solo puedes subir un nuevo soporte de pago; el título y la línea no se modifican.</p>
          </c:otherwise>
        </c:choose>
      </fieldset>
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Documento y enlaces</legend>
        <div class="campo">
          <label class="etiqueta" for="soporte_pago">Nuevo soporte de pago (URL, opcional)</label>
          <input class="entrada" type="text" id="soporte_pago" name="soporte_pago" maxlength="500" data-tipo-url
                 placeholder="https://...">
          <p class="ayuda">Súbelo solo si necesitas corregir el pago. Debe empezar por http:// o https:// y no contener espacios ni comillas.</p>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">Reenviar</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyecto.jsp?id=<c:out value='${d.rows[0].id_proyecto}'/>">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
<script src="${pageContext.request.contextPath}/js/url-valida.js"></script>
</body>
</html>
