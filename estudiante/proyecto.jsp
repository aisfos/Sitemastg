<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  proyecto.jsp — Detalle del proyecto para el Estudiante (req. 93, 94, 95, 96, 97).
  Comprueba la propiedad (id_estudiante1 = sesión) con el MISMO mensaje para el
  proyecto inexistente y el ajeno (decisión (e)). Usa SOLO v_proyecto_estudiante y
  nunca consulta id_evaluador ni muestra su nombre (req. 95). Las observaciones del
  evaluador salen sin nombre ("Evaluación"); las del director y del comité sí llevan
  nombre. Solo hay acciones cuando el turno es del Estudiante (req. 96).
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
           sql="SELECT vpe.id_proyecto, vpe.titulo, vpe.descripcion, vpe.linea_investigacion,
                       vpe.estudiante1, vpe.estudiante2, vpe.id_fase, vpe.fase, vpe.estado,
                       vpe.estado_idea, vpe.finalizado, vpe.radicado, vpe.fecha_creacion,
                       vpe.director, p.id_rol_proceso, p.origen, p.id_linea,
                       ROUND((CASE WHEN vpe.finalizado = 1 THEN 6 ELSE vpe.id_fase END) * 100.0 / 6) AS pct
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
<sql:query var="entregas" dataSource="${db}"
           sql="SELECT id_proyecto, fase, tipo, numero_version, url, fecha_entrega
                FROM v_historial_entregas WHERE id_proyecto = ? ORDER BY fecha_entrega, id_entrega">
  <sql:param value="${idNum}"/>
</sql:query>
<sql:query var="observaciones" dataSource="${db}"
           sql="SELECT fase, rol, revisor, resultado, comentarios, fecha_revision
                FROM v_historial_revisiones WHERE id_proyecto = ? ORDER BY fecha_revision, id_revision">
  <sql:param value="${idNum}"/>
</sql:query>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Proyecto — Sistemas TG</title>
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
      <h1>Proyecto #<c:out value="${d.rows[0].id_proyecto}"/></h1>
      <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyectos.jsp">Volver a Mis proyectos</a>
    </div>
    <p class="destacado"><c:out value="${d.rows[0].titulo}"/></p>
    <p>
      <span class="insignia insignia-rol insignia-grande">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>
        <c:out value="${d.rows[0].estado}"/>
      </span>
    </p>
    <div class="proyecto-progreso">
      <c:set var="anilloId" value="${d.rows[0].id_proyecto}"/>
      <c:set var="anilloFase" value="${d.rows[0].id_fase}"/>
      <c:set var="anilloPct" value="${d.rows[0].pct}"/>
      <c:set var="anilloEtiqueta" value="Fase ${d.rows[0].id_fase} de 6"/>
      <%@ include file="/WEB-INF/fragmentos/grafico-anillo.jsp" %>
    </div>
    <c:if test="${d.rows[0].finalizado}">
      <c:set var="celebracionRadicado" value="${d.rows[0].radicado}"/>
      <%@ include file="/WEB-INF/fragmentos/celebracion.jsp" %>
    </c:if>
    <dl>
      <dt>Descripción</dt><dd><c:out value="${d.rows[0].descripcion}"/></dd>
      <dt>Línea de investigación</dt><dd><c:out value="${d.rows[0].linea_investigacion}"/></dd>
      <dt>Estudiante 1</dt><dd><c:out value="${d.rows[0].estudiante1}"/></dd>
      <c:if test="${not empty d.rows[0].estudiante2}">
        <dt>Estudiante 2</dt><dd><c:out value="${d.rows[0].estudiante2}"/></dd>
      </c:if>
      <dt>Director</dt><dd><c:out value="${empty d.rows[0].director ? 'Por asignar' : d.rows[0].director}"/></dd>
    </dl>

    <details class="detalle-fases" open>
      <summary>Seguimiento de las seis fases</summary>
      <c:set var="faseActual" value="${d.rows[0].id_fase}"/>
      <c:set var="finalizado" value="${d.rows[0].finalizado}"/>
      <%@ include file="/WEB-INF/fragmentos/seguimiento-fases.jsp" %>
    </details>

    <%-- Acciones: solo cuando el turno es del Estudiante y no está finalizado (req. 96) --%>
    <c:choose>
      <c:when test="${d.rows[0].finalizado}">
        <p class="aviso">El proyecto está finalizado; no admite más documentos.</p>
      </c:when>
      <c:when test="${d.rows[0].id_rol_proceso == 1}">
        <c:choose>
          <c:when test="${d.rows[0].id_fase == 1}">
            <p class="aviso">El comité aplazó tu idea. Corrige y reenvía para que la revise de nuevo.</p>
            <p><a class="boton boton-primario" href="${pageContext.request.contextPath}/estudiante/corregir-idea.jsp?id=<c:out value='${d.rows[0].id_proyecto}'/>">Corregir y reenviar</a></p>
          </c:when>
          <c:otherwise>
            <%-- Fases 2-5: el turno es del Estudiante. El formulario de envío vive en
                 enviar-documento.jsp (req. 90, 91, 92, 96); aquí solo se ofrece la acción. --%>
            <sql:query var="versP" dataSource="${db}"
                       sql="SELECT COUNT(*) AS n FROM entrega WHERE id_proyecto = ? AND tipo = ?">
              <sql:param value="${d.rows[0].id_proyecto}"/>
              <sql:param value="${(d.rows[0].id_fase == 2 or d.rows[0].id_fase == 3) ? 'PROPUESTA' : 'INFORME'}"/>
            </sql:query>
            <c:set var="esPropuestaActual" value="${d.rows[0].id_fase == 2 or d.rows[0].id_fase == 3}"/>
            <p class="aviso">Es tu turno en la Fase <c:out value="${d.rows[0].id_fase}"/>:
              puedes enviar <c:out value="${esPropuestaActual ? 'la propuesta (F-DC-124)' : 'el informe final (F-DC-125) y sus anexos'}"/>.</p>
            <p><a class="boton boton-primario" href="${pageContext.request.contextPath}/estudiante/enviar-documento.jsp?id=<c:out value='${d.rows[0].id_proyecto}'/>"><c:out value="${versP.rows[0].n > 0 ? 'Subir versión corregida' : 'Enviar documento a revisión'}"/></a></p>
          </c:otherwise>
        </c:choose>
      </c:when>
      <c:otherwise>
        <p class="aviso">En revisión: <c:out value="${d.rows[0].estado}"/>. No puedes cargar documentos ahora.</p>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="tarjeta">
    <h2>Historial de entregas</h2>
    <c:choose>
      <c:when test="${entregas.rowCount == 0}">
        <p class="aviso">Todavía no hay entregas registradas.</p>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll">
          <table class="tabla">
            <thead>
              <tr><th>ID proyecto</th><th>Fase</th><th>Tipo</th><th>Versión</th><th>Enlace</th><th>Fecha</th></tr>
            </thead>
            <tbody>
              <c:forEach var="e" items="${entregas.rows}">
                <tr>
                  <td><c:out value="${e.id_proyecto}"/></td>
                  <td><c:out value="${e.fase}"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${e.tipo == 'IDEA'}">Idea</c:when>
                      <c:when test="${e.tipo == 'SOPORTE_PAGO'}">Soporte de pago</c:when>
                      <c:when test="${e.tipo == 'PROPUESTA'}">Propuesta F-DC-124</c:when>
                      <c:when test="${e.tipo == 'INFORME'}">Informe F-DC-125</c:when>
                      <c:when test="${e.tipo == 'MANUAL_USUARIO'}">Manual de usuario</c:when>
                      <c:when test="${e.tipo == 'MANUAL_TECNICO'}">Manual técnico</c:when>
                      <c:when test="${e.tipo == 'REPOSITORIO'}">Repositorio</c:when>
                      <c:otherwise><c:out value="${e.tipo}"/></c:otherwise>
                    </c:choose>
                  </td>
                  <td><c:out value="${e.numero_version}"/></td>
                  <td><a href="<c:out value='${e.url}'/>" target="_blank" rel="noopener noreferrer">Ver</a></td>
                  <td><c:out value="${e.fecha_entrega}"/></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </section>

  <section class="tarjeta">
    <h2>Observaciones</h2>
    <c:choose>
      <c:when test="${observaciones.rowCount == 0}">
        <p class="aviso">Todavía no hay observaciones.</p>
      </c:when>
      <c:otherwise>
        <ol class="linea-tiempo">
          <c:forEach var="o" items="${observaciones.rows}">
            <li class="${o.resultado == 'APROBADO' ? '' : 'linea-tiempo-aplazado'}">
              <div class="linea-tiempo-encabezado">
                <span class="insignia insignia-gris">Fase <c:out value="${o.fase}"/></span>
                <span class="linea-tiempo-quien">
                  <%-- req. 95: el evaluador se muestra sin nombre --%>
                  <c:choose>
                    <c:when test="${o.rol == 'Evaluador'}">Evaluación</c:when>
                    <c:otherwise><c:out value="${o.revisor}"/></c:otherwise>
                  </c:choose>
                </span>
                <c:choose>
                  <c:when test="${o.resultado == 'APROBADO'}"><span class="insignia insignia-verde">Aprobado</span></c:when>
                  <c:otherwise><span class="insignia insignia-ambar">Aplazado</span></c:otherwise>
                </c:choose>
                <span class="linea-tiempo-fecha"><c:out value="${o.fecha_revision}"/></span>
              </div>
              <p class="linea-tiempo-comentario"><c:out value="${o.comentarios}"/></p>
            </li>
          </c:forEach>
        </ol>
      </c:otherwise>
    </c:choose>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
