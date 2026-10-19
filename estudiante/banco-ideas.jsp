<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="4"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  banco-ideas.jsp — Banco de Ideas Docente para el Estudiante (req. 86, 18).
  Muestra SOLO las ideas aprobadas y disponibles que ningún proyecto haya tomado.
  Columnas: título, objetivo, línea, nivel académico, periodo y docente (que será
  el director del proyecto, req. 75). Filtro opcional por nivel académico: un valor
  inválido o inexistente se ignora (vuelve a Todas).
--%>
<c:set var="nivelFiltro" value="${fn:trim(param.nivel)}"/>
<c:if test="${not empty nivelFiltro}">
  <c:set var="nivelNum" value="0"/>
  <c:catch var="errNivel"><c:set var="nivelNum" value="${nivelFiltro + 0}"/></c:catch>
  <sql:query var="chkNivel" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM nivel_academico WHERE id_nivel_academico = ?">
    <sql:param value="${nivelFiltro}"/>
  </sql:query>
  <c:if test="${not empty errNivel or nivelNum <= 0 or chkNivel.rows[0].n == 0}">
    <c:set var="nivelFiltro" value=""/>
  </c:if>
</c:if>
<sql:query var="niveles" dataSource="${db}" sql="SELECT id_nivel_academico, nombre FROM nivel_academico ORDER BY id_nivel_academico"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Banco de ideas — Sistemas TG</title>
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
      <h1>Banco de ideas docente</h1>
      <a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/proyectos.jsp">Mis proyectos</a>
    </div>
    <p class="aviso">Estas son las ideas <strong>aprobadas y disponibles</strong>. El docente que propuso la idea será el <strong>director</strong> de tu proyecto.</p>
    <form class="filtro" method="get" action="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp">
      <label class="etiqueta" for="nivel">Nivel académico</label>
      <select class="seleccion" id="nivel" name="nivel">
        <option value=""<c:if test="${empty nivelFiltro}"> selected</c:if>>Todos</option>
        <c:forEach var="n" items="${niveles.rows}">
          <option value="${n.id_nivel_academico}"<c:if test="${nivelFiltro == n.id_nivel_academico}"> selected</c:if>><c:out value="${n.nombre}"/></option>
        </c:forEach>
      </select>
      <button class="boton boton-secundario" type="submit">Filtrar</button>
    </form>
    <sql:query var="ideas" dataSource="${db}"
               sql="SELECT v.id_idea_docente, v.titulo, v.objetivo, v.linea_investigacion,
                           v.nivel_academico, v.periodo_academico, v.docente
                    FROM v_idea_docente v
                    JOIN idea_docente i ON i.id_idea_docente = v.id_idea_docente
                    WHERE v.estado = 'APROBADA' AND v.disponibilidad = 'DISPONIBLE'
                      AND NOT EXISTS (SELECT 1 FROM proyecto p WHERE p.id_idea_docente = v.id_idea_docente)
                      AND (? = '' OR i.id_nivel_academico = ?)
                    ORDER BY v.id_idea_docente">
      <sql:param value="${nivelFiltro}"/>
      <sql:param value="${nivelFiltro}"/>
    </sql:query>
    <c:choose>
      <c:when test="${ideas.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">No hay ideas disponibles que correspondan al filtro seleccionado</h3>
          <p class="vacio-texto">Prueba con otro nivel académico o propone tu propia idea para empezar tu trabajo de grado.</p>
          <div class="vacio-acciones">
            <a class="boton boton-primario" href="${pageContext.request.contextPath}/estudiante/idea-propia.jsp">Proponer tu propia idea</a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="tabla-scroll" data-tabla-interactiva>
          <table class="tabla">
            <thead>
              <tr>
                <th>ID</th><th>Título</th><th>Objetivo</th><th>Línea</th>
                <th>Nivel</th><th>Periodo</th><th>Docente (director)</th><th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="idea" items="${ideas.rows}">
                <tr>
                  <td><c:out value="${idea.id_idea_docente}"/></td>
                  <td><c:out value="${idea.titulo}"/></td>
                  <td><c:out value="${idea.objetivo}"/></td>
                  <td><c:out value="${idea.linea_investigacion}"/></td>
                  <td><c:out value="${idea.nivel_academico}"/></td>
                  <td><c:out value="${idea.periodo_academico}"/></td>
                  <td><c:out value="${idea.docente}"/></td>
                  <td class="acciones">
                    <a class="boton boton-primario boton-pequeno" href="${pageContext.request.contextPath}/estudiante/tomar-idea.jsp?id=<c:out value='${idea.id_idea_docente}'/>">Tomar esta idea</a>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
    <p><a class="boton boton-secundario" href="${pageContext.request.contextPath}/estudiante/idea-propia.jsp">Proponer una idea propia</a></p>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
