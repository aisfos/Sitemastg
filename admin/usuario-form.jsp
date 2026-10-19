<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- Crear (req. 40, 48) y editar (req. 41) usuarios. El ID no es editable. --%>
<c:set var="idUsuario" value="${param.id}"/>
<c:set var="modoEdicion" value="${not empty idUsuario}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idUsuario + 0}"/></c:catch>
<c:if test="${modoEdicion and (not empty errIdNum or idNum <= 0)}">
  <c:set var="flashError" value="El usuario solicitado no existe" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>
<c:if test="${modoEdicion}">
  <sql:query var="u" dataSource="${db}"
             sql="SELECT id_usuario, nombre_completo, id_tipo_documento, numero_documento, id_rol, id_nivel_academico FROM usuario WHERE id_usuario = ?">
    <sql:param value="${idNum}"/>
  </sql:query>
  <c:if test="${u.rowCount == 0}">
    <c:set var="flashError" value="El usuario solicitado no existe" scope="session"/>
    <c:redirect url="/admin/usuarios.jsp"/>
  </c:if>
</c:if>
<sql:query var="tipos" dataSource="${db}" sql="SELECT id_tipo_documento, nombre FROM tipo_documento ORDER BY id_tipo_documento"/>
<sql:query var="roles" dataSource="${db}" sql="SELECT id_rol, nombre FROM rol ORDER BY id_rol"/>
<sql:query var="niveles" dataSource="${db}" sql="SELECT id_nivel_academico, nombre FROM nivel_academico ORDER BY id_nivel_academico"/>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${modoEdicion ? 'Editar' : 'Nuevo'} usuario — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<%@ include file="/WEB-INF/fragmentos/encabezado.jsp" %>
<%@ include file="/WEB-INF/fragmentos/menu.jsp" %>
<main class="contenedor contenido">
  <section class="tarjeta">
    <h1>${modoEdicion ? 'Editar usuario' : 'Nuevo usuario'}</h1>
    <form class="formulario" method="post" action="${pageContext.request.contextPath}/admin/guardar-usuario.jsp">
      <input type="hidden" name="id_usuario" value="<c:out value='${u.rows[0].id_usuario}'/>">
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Datos del usuario</legend>
        <c:if test="${modoEdicion}">
          <div class="campo">
            <label class="etiqueta" for="id_mostrado">ID</label>
            <input class="entrada" type="text" id="id_mostrado" value="<c:out value='${u.rows[0].id_usuario}'/>" readonly>
            <p class="ayuda">El ID no es editable.</p>
          </div>
        </c:if>
        <div class="campo">
          <label class="etiqueta" for="nombre_completo">Nombre completo</label>
          <input class="entrada" type="text" id="nombre_completo" name="nombre_completo" maxlength="150"
                 value="<c:out value='${u.rows[0].nombre_completo}'/>">
        </div>
        <div class="campo">
          <label class="etiqueta" for="id_tipo_documento">Tipo de documento</label>
          <select class="seleccion" id="id_tipo_documento" name="id_tipo_documento">
            <option value="">-- Selecciona --</option>
            <c:forEach var="t" items="${tipos.rows}">
              <option value="${t.id_tipo_documento}"<c:if test="${t.id_tipo_documento eq u.rows[0].id_tipo_documento}"> selected</c:if>><c:out value="${t.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
        <div class="campo">
          <label class="etiqueta" for="numero_documento">Número de documento</label>
          <input class="entrada" type="text" id="numero_documento" name="numero_documento" maxlength="20"
                 value="<c:out value='${u.rows[0].numero_documento}'/>">
        </div>
      </fieldset>
      <fieldset class="formulario-seccion">
        <legend class="formulario-seccion-titulo">Acceso y rol</legend>
        <div class="campo">
          <label class="etiqueta" for="contrasena">Contraseña</label>
          <input class="entrada" type="password" id="contrasena" name="contrasena" maxlength="100" value="" autocomplete="new-password">
          <c:if test="${modoEdicion}">
            <p class="ayuda">Déjala vacía para conservar la contraseña actual.</p>
          </c:if>
        </div>
        <div class="campo">
          <label class="etiqueta" for="id_rol">Rol</label>
          <select class="seleccion" id="id_rol" name="id_rol">
            <option value="">-- Selecciona --</option>
            <c:forEach var="r" items="${roles.rows}">
              <option value="${r.id_rol}"<c:if test="${r.id_rol eq u.rows[0].id_rol}"> selected</c:if>><c:out value="${r.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
        <div class="campo" id="bloque-nivel"<c:if test="${u.rows[0].id_rol != 4}"> hidden</c:if>>
          <label class="etiqueta" for="id_nivel_academico">Nivel académico (solo estudiantes)</label>
          <select class="seleccion" id="id_nivel_academico" name="id_nivel_academico">
            <option value="">-- Selecciona --</option>
            <c:forEach var="n" items="${niveles.rows}">
              <option value="${n.id_nivel_academico}"<c:if test="${n.id_nivel_academico eq u.rows[0].id_nivel_academico}"> selected</c:if>><c:out value="${n.nombre}"/></option>
            </c:forEach>
          </select>
        </div>
      </fieldset>
      <p class="formulario-acciones">
        <button class="boton boton-primario" type="submit">Guardar</button>
        <a class="boton boton-secundario" href="${pageContext.request.contextPath}/admin/usuarios.jsp">Cancelar</a>
      </p>
    </form>
  </section>
</main>
<%@ include file="/WEB-INF/fragmentos/pie.jsp" %>
<script src="${pageContext.request.contextPath}/js/usuario-form.js"></script>
</body>
</html>
