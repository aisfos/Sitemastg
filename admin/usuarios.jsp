<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Listado de usuarios (req. 43, 18, 19). No se muestra la contraseña. --%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Usuarios — Sistemas TG</title>
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
      <h1>Usuarios</h1>
      <a class="boton boton-primario" href="${pageContext.request.contextPath}/admin/usuario-form.jsp">Nuevo usuario</a>
    </div>
    <sql:query var="usuarios" dataSource="${db}"
               sql="SELECT u.id_usuario, u.nombre_completo, td.nombre AS tipo_documento, u.numero_documento, r.nombre AS rol, na.nombre AS nivel_academico
                    FROM usuario u
                    JOIN tipo_documento td ON td.id_tipo_documento = u.id_tipo_documento
                    JOIN rol r ON r.id_rol = u.id_rol
                    LEFT JOIN nivel_academico na ON na.id_nivel_academico = u.id_nivel_academico
                    ORDER BY u.id_usuario"/>
    <c:choose>
      <c:when test="${usuarios.rowCount == 0}">
        <div class="vacio">
          <img class="vacio-ilustracion" src="${pageContext.request.contextPath}/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">
          <h3 class="vacio-titulo">No hay usuarios registrados</h3>
          <p class="vacio-texto">Crea el primer usuario para empezar a gestionar la plataforma.</p>
          <div class="vacio-acciones">
            <a class="boton boton-primario" href="${pageContext.request.contextPath}/admin/usuario-form.jsp">Nuevo usuario</a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <table class="tabla" data-tabla-interactiva>
          <thead>
            <tr>
              <th>ID</th><th>Nombre completo</th><th>Tipo de documento</th><th>Número</th>
              <th>Rol</th><th>Nivel académico</th><th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="f" items="${usuarios.rows}">
              <tr>
                <td><c:out value="${f.id_usuario}"/></td>
                <td>
                  <span class="celda-persona">
                    <c:set var="avatarId" value="${f.id_usuario}"/>
                    <c:set var="avatarNombre" value="${f.nombre_completo}"/>
                    <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
                    <c:out value="${f.nombre_completo}"/>
                  </span>
                </td>
                <td><c:out value="${f.tipo_documento}"/></td>
                <td><c:out value="${f.numero_documento}"/></td>
                <td><c:out value="${f.rol}"/></td>
                <td>
                  <c:choose>
                    <c:when test="${empty f.nivel_academico}">—</c:when>
                    <c:otherwise><c:out value="${f.nivel_academico}"/></c:otherwise>
                  </c:choose>
                </td>
                <td class="acciones">
                  <a class="boton boton-secundario boton-pequeno" href="${pageContext.request.contextPath}/admin/usuario-form.jsp?id=<c:out value='${f.id_usuario}'/>">Editar</a>
                  <form class="form-eliminar" method="post" action="${pageContext.request.contextPath}/admin/eliminar-usuario.jsp" data-nombre="<c:out value='${f.nombre_completo}'/>">
                    <input type="hidden" name="id_usuario" value="<c:out value='${f.id_usuario}'/>">
                    <button class="boton boton-peligro boton-pequeno" type="submit">Eliminar</button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </c:otherwise>
    </c:choose>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
</body>
</html>
