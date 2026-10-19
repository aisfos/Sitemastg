<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  proyectos.jsp — "Mis proyectos" del Estudiante (req. 93, 94, 97).
  Lista SOLO los proyectos donde el usuario en sesión es estudiante 1
  (v_proyecto_estudiante filtrando por id_estudiante1); nunca aparecen los
  proyectos donde solo es estudiante 2 (req. 97). Nunca muestra al evaluador
  (req. 95). Director "Por asignar" mientras el comité no lo asigne.
--%>
<sql:query var="proyectos" dataSource="${db}"
           sql="SELECT id_proyecto, titulo, estado, finalizado, director, estado_idea, id_fase, rol_turno
                FROM v_proyecto_estudiante
                WHERE id_estudiante1 = ?
                ORDER BY id_proyecto">
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mis proyectos — Sistemas TG</title>
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
      <h1>Mis proyectos</h1>
    </div>
    <c:choose>
      <c:when test="${proyectos.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">Todavía no tienes proyectos</h3>
          <p class="vacio-texto">Puedes tomar una idea del banco o proponer la tuya para empezar tu trabajo de grado.</p>
          <div class="vacio-acciones">
            <a class="boton boton-primario" href="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp">Tomar idea del banco</a>
            <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/idea-propia.jsp">Proponer idea propia</a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Título</th><th>Estado</th><th>Director</th><th>Estado de la idea</th><th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="p" items="${proyectos.rows}">
                <tr>
                  <td><c:out value="${p.id_proyecto}"/></td>
                  <td><c:out value="${p.titulo}"/></td>
                  <td><span class="insignia insignia-rol"><c:out value="${p.estado}"/></span></td>
                  <td><c:out value="${empty p.director ? 'Por asignar' : p.director}"/></td>
                  <td>
                    <c:choose>
                      <c:when test="${p.estado_idea == 'APROBADA'}"><span class="insignia insignia-verde">Aprobada</span></c:when>
                      <c:when test="${p.estado_idea == 'APLAZADA'}"><span class="insignia insignia-rojo">Aplazada</span></c:when>
                      <c:otherwise><span class="insignia insignia-gris">Pendiente</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td class="acciones">
                    <c:if test="${p.rol_turno == 'Estudiante'}">
                      <span class="pastilla-turno"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>Tu turno</span>
                    </c:if>
                    <a class="boton boton-secundario boton-pequeno" href="${pageContext.request.contextPath}/estudiante/proyecto.jsp?id=<c:out value='${p.id_proyecto}'/>">Ver</a>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
        <p>
          <a class="boton boton-primario" href="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp">Tomar otra idea del banco</a>
          <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/idea-propia.jsp">Proponer otra idea</a>
        </p>
      </c:otherwise>
    </c:choose>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
