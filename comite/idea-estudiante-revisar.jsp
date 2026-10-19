<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="2"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  idea-estudiante-revisar.jsp — Formulario del Comité para APROBAR (req. 57, 58)
  o APLAZAR (req. 59) una idea de estudiante en "Fase 1 | Comité".
  La acción llega por GET (?accion=aprobar|aplazar) y se valida contra lista fija;
  el guardado es un POST a guardar-revision-fase1.jsp. Si el proyecto no existe o
  no está en el turno del Comité se redirige con mensaje claro (req. 20f).
  En las ideas del banco el director viene de la idea: solo se elige evaluador.
--%>
<c:set var="urlVolver" value="/comite/ideas-estudiantes.jsp"/>
<c:set var="idProy" value="${fn:trim(param.id)}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idProy + 0}"/></c:catch>
<c:if test="${empty idProy or not empty errIdNum or idNum <= 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:set var="accion" value="${fn:trim(param.accion)}"/>
<c:if test="${accion ne 'aprobar' and accion ne 'aplazar'}">
  <c:set var="flashError" value="Acción no válida" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="d" dataSource="${db}"
           sql="SELECT vp.id_proyecto, vp.origen, vp.titulo, vp.descripcion, vp.linea_investigacion,
                       vp.id_estudiante1, vp.estudiante1, vp.id_estudiante2, vp.estudiante2, na.nombre AS nivel_academico, vp.soporte_pago_url,
                       vp.estado_idea, vp.estado, vp.id_fase, vp.id_rol_proceso, vp.rol_turno, vp.finalizado,
                       vp.id_director, vp.director, vp.id_evaluador, vp.evaluador
                FROM v_proyecto vp
                JOIN usuario e1 ON e1.id_usuario = vp.id_estudiante1
                LEFT JOIN nivel_academico na ON na.id_nivel_academico = e1.id_nivel_academico
                WHERE vp.id_proyecto = ?">
  <sql:param value="${idNum}"/>
</sql:query>
<c:if test="${d.rowCount == 0}">
  <c:set var="flashError" value="El proyecto solicitado no existe" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<c:if test="${d.rows[0].finalizado or d.rows[0].id_fase != 1 or d.rows[0].id_rol_proceso != 4}">
  <c:set var="flashError" value="No es el turno del Comité en la fase actual del proyecto" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>
<sql:query var="docentes" dataSource="${db}"
           sql="SELECT id_usuario, nombre_completo FROM usuario WHERE id_rol = 3 ORDER BY nombre_completo"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${accion == 'aprobar' ? 'Aprobar idea de estudiante' : 'Aplazar idea de estudiante'} — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>${accion == 'aprobar' ? 'Aprobar idea de estudiante' : 'Aplazar idea de estudiante'}</h1>
    <p class="aviso">
      <strong><c:out value="${d.rows[0].titulo}"/></strong><br>
      Estudiante(s):
      <span class="celda-persona"><c:set var="avatarId" value="${d.rows[0].id_estudiante1}"/><c:set var="avatarNombre" value="${d.rows[0].estudiante1}"/><%@ include file="/WEB-INF/fragmentos/avatar.jsp" %><c:out value="${d.rows[0].estudiante1}"/></span><c:if test="${not empty d.rows[0].estudiante2}"> / <span class="celda-persona"><c:set var="avatarId" value="${d.rows[0].id_estudiante2}"/><c:set var="avatarNombre" value="${d.rows[0].estudiante2}"/><%@ include file="/WEB-INF/fragmentos/avatar.jsp" %><c:out value="${d.rows[0].estudiante2}"/></span></c:if>
      · Línea: <c:out value="${d.rows[0].linea_investigacion}"/>
      · Nivel: <c:out value="${d.rows[0].nivel_academico}"/><br>
      Estado del proyecto: <span class="insignia insignia-rol"><c:out value="${d.rows[0].estado}"/></span>
    </p>
    <p class="aviso">
      Soporte de pago:
      <c:choose>
        <c:when test="${not empty d.rows[0].soporte_pago_url}">
          <a href="<c:out value='${d.rows[0].soporte_pago_url}'/>" target="_blank" rel="noopener noreferrer">Ver soporte de pago</a>
        </c:when>
        <c:otherwise><strong>Sin soporte de pago.</strong> Una idea sin soporte de pago no se puede aprobar.</c:otherwise>
      </c:choose>
    </p>
    <c:choose>
      <c:when test="${accion == 'aprobar'}">
        <p class="aviso">Al aprobar, el Comité asigna el director y el evaluador y se registra la calificación <strong>Aprobado</strong> con comentarios. El evaluador no puede ser el director.</p>
        <form class="formulario" method="post" action="${pageContext.request.contextPath}/comite/guardar-revision-fase1.jsp">
          <input type="hidden" name="id_proyecto" value="<c:out value='${d.rows[0].id_proyecto}'/>">
          <input type="hidden" name="accion" value="aprobar">
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Acta y comentarios</legend>
            <div class="campo">
              <label class="etiqueta" for="acta_numero">Número de acta</label>
              <input class="entrada" type="text" id="acta_numero" name="acta_numero" maxlength="30" value="">
              <p class="ayuda">Obligatorio, máximo 30 caracteres.</p>
            </div>
            <div class="campo">
              <label class="etiqueta" for="comentarios">Comentarios</label>
              <textarea class="area" id="comentarios" name="comentarios" rows="4" maxlength="1000"></textarea>
              <p class="ayuda">Obligatorios, máximo 1000 caracteres.</p>
            </div>
          </fieldset>
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Director y evaluador</legend>
            <div class="campo">
              <label class="etiqueta" for="id_director">Director</label>
              <c:choose>
                <c:when test="${d.rows[0].origen == 'BANCO_DOCENTE'}">
                  <select class="seleccion" id="id_director" disabled>
                    <option value="<c:out value='${d.rows[0].id_director}'/>"><c:out value="${d.rows[0].director}"/></option>
                  </select>
                  <p class="ayuda">El director viene de la idea del banco; el Comité solo asigna al evaluador.</p>
                </c:when>
                <c:otherwise>
                  <select class="seleccion" id="id_director" name="id_director">
                    <option value="">Selecciona un docente</option>
                    <c:forEach var="doc" items="${docentes.rows}">
                      <option value="${doc.id_usuario}"><c:out value="${doc.nombre_completo}"/></option>
                    </c:forEach>
                  </select>
                </c:otherwise>
              </c:choose>
            </div>
            <div class="campo">
              <label class="etiqueta" for="id_evaluador">Evaluador</label>
              <select class="seleccion" id="id_evaluador" name="id_evaluador" data-director="<c:out value='${d.rows[0].id_director}'/>">
                <option value="">Selecciona un docente</option>
                <c:forEach var="doc" items="${docentes.rows}">
                  <option value="${doc.id_usuario}"><c:out value="${doc.nombre_completo}"/></option>
                </c:forEach>
              </select>
              <p class="ayuda">La lista excluye al director elegido; el evaluador no puede ser el director.</p>
            </div>
          </fieldset>
          <p class="formulario-acciones">
            <button class="boton boton-primario" type="submit">Aprobar idea</button>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp">Cancelar</a>
          </p>
        </form>
        <script src="${pageContext.request.contextPath}/js/revision-fase1.js"></script>
      </c:when>
      <c:otherwise>
        <p class="aviso">Al aplazar, el proyecto vuelve al estudiante en la misma fase para que corrija. No se usa la palabra "rechazar".</p>
        <form class="formulario" method="post" action="${pageContext.request.contextPath}/comite/guardar-revision-fase1.jsp">
          <input type="hidden" name="id_proyecto" value="<c:out value='${d.rows[0].id_proyecto}'/>">
          <input type="hidden" name="accion" value="aplazar">
          <fieldset class="formulario-seccion">
            <legend class="formulario-seccion-titulo">Acta y motivo</legend>
            <div class="campo">
              <label class="etiqueta" for="acta_numero">Número de acta</label>
              <input class="entrada" type="text" id="acta_numero" name="acta_numero" maxlength="30" value="">
              <p class="ayuda">Obligatorio, máximo 30 caracteres.</p>
            </div>
            <div class="campo">
              <label class="etiqueta" for="motivo">Motivo del aplazamiento</label>
              <textarea class="area" id="motivo" name="motivo" rows="5" maxlength="1000"></textarea>
              <p class="ayuda">Obligatorio, máximo 1000 caracteres. Se guarda como comentario de la revisión.</p>
            </div>
          </fieldset>
          <p class="formulario-acciones">
            <button class="boton boton-primario" type="submit">Aplazar idea</button>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp">Cancelar</a>
          </p>
        </form>
      </c:otherwise>
    </c:choose>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
