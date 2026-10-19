<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  enviar-documento.jsp — Formulario de envío de la Fase 2 a la 5 (req. 90, 91, 92, 96).
  Solo cuando el turno es del Estudiante y la fase es 2, 3, 4 o 5:
    - Fases 2 y 3: URL de la propuesta (F-DC-124, obligatoria; tipo PROPUESTA).
    - Fases 4 y 5: URL del informe (F-DC-125, obligatoria; tipo INFORME) y,
      opcionales, manual de usuario, manual técnico y repositorio.
  Si ya existe una versión anterior del documento principal, el título es
  "Subir versión corregida"; si no, "Enviar a revisión". Arriba se muestra la última
  observación recibida. El estudiante actuante es SIEMPRE el de la sesión.
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
           sql="SELECT id_proyecto, titulo, id_fase, id_rol_proceso, finalizado
                FROM proyecto WHERE id_proyecto = ? AND id_estudiante1 = ?">
  <sql:param value="${idNum}"/>
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="No tienes permiso para ver este proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="fase" value="${d.rows[0].id_fase}"/>
<c:if test="${d.rows[0].finalizado or d.rows[0].id_rol_proceso != 1 or (fase != 2 and fase != 3 and fase != 4 and fase != 5)}">
  <c:set var="flashError" value="No es el turno del Estudiante en la fase actual del proyecto" scope="session"/>
  <c:redirect url="/estudiante/proyecto.jsp?id=${idNum}"/>
</c:if>
<c:set var="esPropuesta" value="${fase == 2 or fase == 3}"/>
<c:set var="tipoPrincipal" value="${esPropuesta ? 'PROPUESTA' : 'INFORME'}"/>
<sql:query var="vers" dataSource="${db}"
           sql="SELECT COUNT(*) AS n FROM entrega WHERE id_proyecto = ? AND tipo = ?">
  <sql:param value="${idNum}"/>
  <sql:param value="${tipoPrincipal}"/>
</sql:query>
<c:set var="esCorreccion" value="${vers.rows[0].n > 0}"/>
<sql:query var="ultima" dataSource="${db}"
           sql="SELECT fase, rol, resultado, comentarios, fecha_revision
                FROM v_historial_revisiones WHERE id_proyecto = ?
                ORDER BY fecha_revision DESC, id_revision DESC LIMIT 1">
  <sql:param value="${idNum}"/>
</sql:query>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Enviar documento — Sistemas TG</title>
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
      <h1><c:out value="${esCorreccion ? 'Subir versión corregida' : 'Enviar a revisión'}"/></h1>
      <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyecto.jsp?id=<c:out value='${idNum}'/>">Volver al proyecto</a>
    </div>
    <p class="destacado">Proyecto #<c:out value="${idNum}"/> — <c:out value="${d.rows[0].titulo}"/></p>
    <p><span class="insignia insignia-rol">Fase <c:out value="${fase}"/></span>
       <c:out value="${esPropuesta ? 'Propuesta (F-DC-124)' : 'Informe final (F-DC-125)'}"/></p>

    <c:if test="${ultima.rowCount > 0}">
      <div class="aviso">
        <p><strong>Observaciones de la última revisión</strong>
           (<c:out value="${ultima.rows[0].fase}"/> · <c:out value="${ultima.rows[0].resultado == 'APROBADO' ? 'Aprobado' : 'Aplazado'}"/>):</p>
        <p><c:out value="${ultima.rows[0].comentarios}"/></p>
      </div>
    </c:if>

    <c:if test="${esCorreccion}">
      <p class="aviso">Ya existe una versión anterior de este documento en esta fase. Al enviar se registrará una nueva versión y el proyecto volverá al revisor.</p>
    </c:if>

    <form class="formulario" method="post" action="${pageContext.request.contextPath}/estudiante/guardar-entrega.jsp" data-validar-url>
      <input type="hidden" name="id_proyecto" value="<c:out value='${idNum}'/>">
      <c:choose>
        <c:when test="${esPropuesta}">
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Documento principal</legend>
            <div class="campo">
              <label class="etiqueta" for="url_propuesta">Propuesta (F-DC-124) — URL</label>
              <input class="entrada" type="text" id="url_propuesta" name="url_propuesta" maxlength="500" data-tipo-url required
                     placeholder="https://...">
              <p class="ayuda">Obligatoria. Debe empezar por http:// o https:// y no contener espacios ni comillas.</p>
            </div>
          </fieldset>
        </c:when>
        <c:otherwise>
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Documento principal</legend>
            <div class="campo">
              <label class="etiqueta" for="url_informe">Informe final (F-DC-125) — URL</label>
              <input class="entrada" type="text" id="url_informe" name="url_informe" maxlength="500" data-tipo-url required
                     placeholder="https://...">
              <p class="ayuda">Obligatorio. Debe empezar por http:// o https:// y no contener espacios ni comillas.</p>
            </div>
          </fieldset>
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Anexos</legend>
            <div class="campo">
              <label class="etiqueta" for="url_manual_usuario">Manual de usuario (opcional)</label>
              <input class="entrada" type="text" id="url_manual_usuario" name="url_manual_usuario" maxlength="500" data-tipo-url
                     placeholder="https://...">
            </div>
            <div class="campo">
              <label class="etiqueta" for="url_manual_tecnico">Manual técnico (opcional)</label>
              <input class="entrada" type="text" id="url_manual_tecnico" name="url_manual_tecnico" maxlength="500" data-tipo-url
                     placeholder="https://...">
            </div>
            <div class="campo">
              <label class="etiqueta" for="url_repositorio">Repositorio (opcional)</label>
              <input class="entrada" type="text" id="url_repositorio" name="url_repositorio" maxlength="500" data-tipo-url
                     placeholder="https://...">
            </div>
            <p class="ayuda">Solo el informe es obligatorio; manual de usuario, manual técnico y repositorio son anexos opcionales.</p>
          </fieldset>
        </c:otherwise>
      </c:choose>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit"><c:out value="${esCorreccion ? 'Enviar versión corregida' : 'Enviar a revisión'}"/></button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyecto.jsp?id=<c:out value='${idNum}'/>">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
<script src="${pageContext.request.contextPath}/js/url-valida.js"></script>
</body>
</html>
