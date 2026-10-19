<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  login.jsp — Inicio de sesión (req. 34, 35, 36, 39, 20a, 20b).
  Una sola consulta con sql:param (documento + contraseña + rol). Credenciales
  incorrectas dan un único mensaje, sin decir cuál dato falló. La contraseña
  nunca se conserva ni se refleja.
--%>

<%-- Si ya hay sesión, al panel del rol (antes de emitir HTML). --%>
<c:if test="${not empty sessionScope.usuarioId}">
  <c:choose>
    <c:when test="${sessionScope.rolId == 1}"><c:redirect url="/admin/panel.jsp"/></c:when>
    <c:when test="${sessionScope.rolId == 2}"><c:redirect url="/comite/panel.jsp"/></c:when>
    <c:when test="${sessionScope.rolId == 3}"><c:redirect url="/docente/panel.jsp"/></c:when>
    <c:otherwise><c:redirect url="/estudiante/panel.jsp"/></c:otherwise>
  </c:choose>
</c:if>

<%-- Procesar el envío del formulario (req. 34, 20a, 20b). --%>
<c:set var="documento" value="${param.documento}"/>
<c:set var="idRol" value="${param.idRol}"/>
<c:if test="${not empty param.enviar}">
  <c:choose>
    <c:when test="${empty documento or empty param.clave or empty idRol}">
      <c:set var="errorLogin" value="Debes completar el número de documento, la contraseña y el rol"/>
    </c:when>
    <c:otherwise>
      <sql:query var="usuarioLogin" dataSource="${db}"
                 sql="SELECT u.id_usuario, u.nombre_completo, u.id_rol, r.nombre AS rol_nombre FROM usuario u INNER JOIN rol r ON r.id_rol = u.id_rol WHERE u.numero_documento = ? AND u.contrasena = ? AND u.id_rol = ?">
        <sql:param value="${documento}"/>
        <sql:param value="${param.clave}"/>
        <sql:param value="${idRol}"/>
      </sql:query>
      <c:choose>
        <c:when test="${usuarioLogin.rowCount == 0}">
          <c:set var="errorLogin" value="Usuario, contraseña o rol incorrectos"/>
        </c:when>
        <c:otherwise>
          <%-- Evita la fijación de sesión: id nuevo antes de guardar los datos. --%>
          <c:set var="sesionRenovada" value="${pageContext.request.changeSessionId()}"/>
          <c:set var="usuarioId" value="${usuarioLogin.rows[0].id_usuario}" scope="session"/>
          <c:set var="usuarioNombre" value="${usuarioLogin.rows[0].nombre_completo}" scope="session"/>
          <c:set var="rolId" value="${usuarioLogin.rows[0].id_rol}" scope="session"/>
          <c:set var="rolNombre" value="${usuarioLogin.rows[0].rol_nombre}" scope="session"/>
          <c:choose>
            <c:when test="${usuarioLogin.rows[0].id_rol == 1}"><c:redirect url="/admin/panel.jsp"/></c:when>
            <c:when test="${usuarioLogin.rows[0].id_rol == 2}"><c:redirect url="/comite/panel.jsp"/></c:when>
            <c:when test="${usuarioLogin.rows[0].id_rol == 3}"><c:redirect url="/docente/panel.jsp"/></c:when>
            <c:otherwise><c:redirect url="/estudiante/panel.jsp"/></c:otherwise>
          </c:choose>
        </c:otherwise>
      </c:choose>
    </c:otherwise>
  </c:choose>
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesión — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body class="login-fondo">
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <div class="login-marca" aria-hidden="true">
      <svg class="icono" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-diploma"/></svg>
    </div>
    <h1 class="login-titulo">Sistemas TG</h1>
    <p class="login-subtitulo">Gestión del trabajo de grado</p>
    <p class="login-ayuda">Selecciona tu rol, escribe tu documento y tu contraseña para entrar.</p>
    <c:if test="${param.salio == '1'}">
      <p class="alerta alerta-ok" role="status">Sesión cerrada</p>
    </c:if>
    <c:if test="${not empty errorLogin}">
      <p class="alerta alerta-error" role="alert"><c:out value="${errorLogin}"/></p>
    </c:if>
    <form id="form-login" class="formulario" method="post" action="${pageContext.request.contextPath}/login.jsp">
      <input type="hidden" name="enviar" value="1">
      <div class="campo">
        <label class="etiqueta" for="documento">Número de documento</label>
        <input class="entrada" type="text" id="documento" name="documento" maxlength="20"
               autocomplete="username" value="<c:out value='${documento}'/>">
      </div>
      <div class="campo">
        <label class="etiqueta" for="clave">Contraseña</label>
        <input class="entrada" type="password" id="clave" name="clave" maxlength="100"
               autocomplete="current-password" value="">
      </div>
      <div class="campo">
        <label class="etiqueta" for="idRol">Rol</label>
        <select class="seleccion" id="idRol" name="idRol">
          <option value="">-- Selecciona tu rol --</option>
          <sql:query var="roles" dataSource="${db}" sql="SELECT id_rol, nombre FROM rol ORDER BY id_rol"/>
          <c:forEach var="r" items="${roles.rows}">
            <option value="${r.id_rol}"<c:if test="${r.id_rol eq idRol}"> selected</c:if>><c:out value="${r.nombre}"/></option>
          </c:forEach>
        </select>
      </div>
      <p><button class="boton boton-primario" type="submit">Entrar</button></p>
    </form>
  </section>

  <details class="tarjeta">
    <summary>Usuarios de prueba (claves en texto plano)</summary>
    <p class="ayuda">Pulsa una tarjeta para rellenar el formulario con sus datos.</p>
    <sql:query var="pruebas" dataSource="${db}"
               sql="SELECT u.numero_documento, u.contrasena, u.nombre_completo, u.id_rol, r.nombre AS rol FROM usuario u INNER JOIN rol r ON r.id_rol = u.id_rol ORDER BY u.id_rol, u.id_usuario"/>
    <ul class="rejilla-prueba">
      <c:forEach var="p" items="${pruebas.rows}">
        <c:choose>
          <c:when test="${p.id_rol == 1}"><c:set var="iconoRol" value="i-candado"/></c:when>
          <c:when test="${p.id_rol == 2}"><c:set var="iconoRol" value="i-check"/></c:when>
          <c:when test="${p.id_rol == 3}"><c:set var="iconoRol" value="i-bombilla"/></c:when>
          <c:otherwise><c:set var="iconoRol" value="i-diploma"/></c:otherwise>
        </c:choose>
        <li class="fila-prueba tarjeta-prueba" tabindex="0"
            data-documento="<c:out value='${p.numero_documento}'/>"
            data-clave="<c:out value='${p.contrasena}'/>"
            data-rol="${p.id_rol}">
          <span class="tarjeta-prueba-rol">
            <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#${iconoRol}"/></svg>
            <c:out value="${p.rol}"/>
          </span>
          <span class="tarjeta-prueba-nombre"><c:out value="${p.nombre_completo}"/></span>
          <span class="tarjeta-prueba-datos">Documento: <strong><c:out value="${p.numero_documento}"/></strong> · Clave: <strong><c:out value="${p.contrasena}"/></strong></span>
        </li>
      </c:forEach>
    </ul>
  </details>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
<script src="${pageContext.request.contextPath}/js/login.js"></script>
</body>
</html>
