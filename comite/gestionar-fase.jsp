<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  gestionar-fase.jsp — Gestión de fases del Comité (req. 63 a 68, 20f, 67).
  Valida en el servidor: id numérico y existente, proyecto no finalizado (req. 67) y
  turno del Comité ("Fase N | Comité"); si no, redirige con mensaje claro.
  Según la fase:
    - Fase 1: reutiliza el flujo de M6 (comite/idea-estudiante-revisar.jsp), sin
      duplicar la lógica de aprobar/aplazar la idea ni de asignar director/evaluador.
    - Fases 3 y 5: califica la propuesta/informe con resultado, acta y comentarios.
    - Fase 6: cierra el proyecto con radicado y comentarios.
  Los documentos, el historial y las observaciones salen de documentos-proyecto.jsp.
--%>
<c:set var="urlVolver" value="/comite/proyectos.jsp"/>
<c:set var="idProy" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="d" dataSource="${db}"
           sql="SELECT id_proyecto, origen, titulo, descripcion, linea_investigacion,
                       estudiante1, estudiante2, director, evaluador, estado, fase, id_fase,
                       id_rol_proceso, rol_turno, finalizado, radicado
                FROM v_proyecto WHERE id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 67: un proyecto finalizado no puede gestionarse --%>
<c:if test="${d.rows[0].finalizado}">
  <c:set var="flashError" value="El proyecto está finalizado y no puede gestionarse" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<%-- req. 20f: el Comité solo actúa cuando su turno es el actual --%>
<c:if test="${d.rows[0].id_rol_proceso != 4}">
  <c:set var="flashError" value="No es el turno del Comité en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="fase" value="${d.rows[0].id_fase + 0}"/>
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
      <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/proyectos.jsp">Volver a Proyectos</a>
    </div>
    <p class="destacado"><c:out value="${d.rows[0].titulo}"/></p>
    <p>
      <span class="insignia insignia-rol insignia-grande">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>
        <c:out value="${d.rows[0].estado}"/>
      </span>
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

  <c:if test="${fase != 1}">
    <%@ include file="/WEB-INF/fragmentos/documentos-proyecto.jsp" %>
  </c:if>

  <c:choose>

    <%-- ===================== Fase 1: reutiliza M6 ===================== --%>
    <c:when test="${fase == 1}">
      <section class="tarjeta">
        <h2>Revisión de la Fase 1 | Comité</h2>
        <p class="aviso">La revisión del soporte de pago y la calificación con acta (asignando director y evaluador en los proyectos propios, o solo el evaluador en los del banco) se realiza en la pantalla de ideas de estudiantes. Elige la acción:</p>
        <p>
          <a class="boton boton-primario" href="${pageContext.request.contextPath}/comite/idea-estudiante-revisar.jsp?id=<c:out value='${idNum}'/>&amp;accion=aprobar">Aprobar idea</a>
          <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/idea-estudiante-revisar.jsp?id=<c:out value='${idNum}'/>&amp;accion=aplazar">Aplazar idea</a>
          <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp">Ver todas las ideas</a>
        </p>
      </section>
    </c:when>

    <%-- ================== Fases 3 y 5: comité califica ================== --%>
    <c:when test="${fase == 3 or fase == 5}">
      <section class="tarjeta">
        <h2>Calificación de la Fase <c:out value="${fase}"/> | Comité</h2>
        <p class="aviso">
          <c:choose>
            <c:when test="${fase == 3}">Revisa la propuesta F-DC-124. Al aprobar, el proyecto pasa a <strong>Fase 4 | Estudiante</strong>; al aplazar, vuelve al estudiante.</c:when>
            <c:otherwise>Revisa el informe F-DC-125 con sus anexos. Al aprobar, el proyecto pasa a <strong>Fase 6 | Comité</strong>; al aplazar, vuelve al estudiante.</c:otherwise>
          </c:choose>
        </p>
        <form class="formulario" method="post" action="${pageContext.request.contextPath}/comite/guardar-calificacion.jsp">
          <input type="hidden" name="id_proyecto" value="<c:out value='${idNum}'/>">
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Decisión del Comité</legend>
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
              <label class="etiqueta" for="acta_numero">Número de acta</label>
              <input class="entrada" type="text" id="acta_numero" name="acta_numero" maxlength="30" required>
              <p class="ayuda">Obligatorio, máximo 30 caracteres.</p>
            </div>
            <div class="campo">
              <label class="etiqueta" for="comentarios">Comentarios</label>
              <textarea class="area" id="comentarios" name="comentarios" rows="4" maxlength="1000" required></textarea>
              <p class="ayuda">Obligatorios, máximo 1000 caracteres.</p>
            </div>
          </fieldset>
          <p class="formulario-acciones">
            <button class="boton boton-primario" type="submit">Registrar calificación</button>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/proyectos.jsp">Cancelar</a>
          </p>
        </form>
      </section>
    </c:when>

    <%-- ====================== Fase 6: cerrar ====================== --%>
    <c:otherwise>
      <section class="tarjeta">
        <h2>Cierre del proyecto — Fase 6 | Comité</h2>
        <p class="aviso">Registra el radicado y cierra el proyecto. Al cerrar, el proyecto queda <strong>Finalizado</strong>. En esta fase no existe el aplazamiento.</p>
        <dl>
          <dt>Título</dt><dd><c:out value="${d.rows[0].titulo}"/></dd>
          <dt>Estudiante(s)</dt>
          <dd>
            <c:out value="${d.rows[0].estudiante1}"/>
            <c:if test="${not empty d.rows[0].estudiante2}"> / <c:out value="${d.rows[0].estudiante2}"/></c:if>
          </dd>
          <dt>Director</dt><dd><c:out value="${empty d.rows[0].director ? 'Por asignar' : d.rows[0].director}"/></dd>
          <dt>Evaluador</dt><dd><c:out value="${empty d.rows[0].evaluador ? 'Por asignar' : d.rows[0].evaluador}"/></dd>
        </dl>
        <form class="formulario" method="post" action="${pageContext.request.contextPath}/comite/guardar-calificacion.jsp">
          <input type="hidden" name="id_proyecto" value="<c:out value='${idNum}'/>">
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Radicado y cierre</legend>
            <div class="campo">
              <label class="etiqueta" for="radicado">Número de radicado</label>
              <input class="entrada" type="text" id="radicado" name="radicado" maxlength="50" required>
              <p class="ayuda">Obligatorio, máximo 50 caracteres.</p>
            </div>
            <div class="campo">
              <label class="etiqueta" for="comentarios">Comentarios</label>
              <textarea class="area" id="comentarios" name="comentarios" rows="4" maxlength="1000" required></textarea>
              <p class="ayuda">Obligatorios, máximo 1000 caracteres.</p>
            </div>
          </fieldset>
          <p class="formulario-acciones">
            <button class="boton boton-primario" type="submit">Cerrar proyecto</button>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/proyectos.jsp">Cancelar</a>
          </p>
        </form>
      </section>
    </c:otherwise>

  </c:choose>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
