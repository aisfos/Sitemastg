<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  guardar-usuario.jsp — Manejador POST para crear (req. 40, 48) y editar
  (req. 41) usuarios. Redirigir-después-de-enviar con mensajes flash.
  Validación con trim y largos máximos (req. 20b); la BD no debe ser quien
  detecte el nivel académico (el CHECK) ni el documento repetido (1062, req. 20c).
--%>
<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>

<c:set var="idUsuario" value="${fn:trim(param.id_usuario)}"/>
<c:set var="modoEdicion" value="${not empty idUsuario}"/>
<c:set var="idNum" value="0"/>
<c:catch var="errIdNum"><c:set var="idNum" value="${idUsuario + 0}"/></c:catch>
<c:if test="${modoEdicion and (not empty errIdNum or idNum <= 0)}">
  <c:set var="flashError" value="El usuario solicitado no existe" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>
<c:set var="nombre" value="${fn:trim(param.nombre_completo)}"/>
<c:set var="idTipo" value="${fn:trim(param.id_tipo_documento)}"/>
<c:set var="numero" value="${fn:trim(param.numero_documento)}"/>
<c:set var="clave" value="${fn:trim(param.contrasena)}"/>
<c:set var="idRolNuevo" value="${fn:trim(param.id_rol)}"/>
<c:set var="idNivel" value="${fn:trim(param.id_nivel_academico)}"/>

<c:choose>
  <c:when test="${modoEdicion}"><c:set var="urlVolver" value="/admin/usuario-form.jsp?id=${idNum}"/></c:when>
  <c:otherwise><c:set var="urlVolver" value="/admin/usuario-form.jsp"/></c:otherwise>
</c:choose>

<%-- Campos obligatorios (req. 20b) y largos máximos --%>
<c:set var="error" value=""/>
<c:if test="${empty error and empty nombre}"><c:set var="error" value="El nombre completo es obligatorio"/></c:if>
<c:if test="${empty error and empty idTipo}"><c:set var="error" value="El tipo de documento es obligatorio"/></c:if>
<c:if test="${empty error and empty numero}"><c:set var="error" value="El número de documento es obligatorio"/></c:if>
<c:if test="${empty error and not modoEdicion and empty clave}"><c:set var="error" value="La contraseña es obligatoria"/></c:if>
<c:if test="${empty error and empty idRolNuevo}"><c:set var="error" value="El rol es obligatorio"/></c:if>
<c:if test="${empty error and fn:length(nombre) > 150}"><c:set var="error" value="El nombre completo no puede superar los 150 caracteres"/></c:if>
<c:if test="${empty error and fn:length(numero) > 20}"><c:set var="error" value="El número de documento no puede superar los 20 caracteres"/></c:if>
<c:if test="${empty error and fn:length(clave) > 100}"><c:set var="error" value="La contraseña no puede superar los 100 caracteres"/></c:if>

<%-- Catálogos: validar que tipo y rol existan (y así poder comparar el rol con seguridad) --%>
<c:if test="${empty error}">
  <sql:query var="chkTipo" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM tipo_documento WHERE id_tipo_documento = ?">
    <sql:param value="${idTipo}"/>
  </sql:query>
  <c:if test="${chkTipo.rows[0].n == 0}"><c:set var="error" value="El tipo de documento seleccionado no es válido"/></c:if>
</c:if>
<c:if test="${empty error}">
  <sql:query var="chkRol" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM rol WHERE id_rol = ?">
    <sql:param value="${idRolNuevo}"/>
  </sql:query>
  <c:if test="${chkRol.rows[0].n == 0}"><c:set var="error" value="El rol seleccionado no es válido"/></c:if>
</c:if>

<%-- Nivel académico: obligatorio solo para estudiantes (rol 4) --%>
<c:if test="${empty error and idRolNuevo == 4 and empty idNivel}">
  <c:set var="error" value="Debes seleccionar el nivel académico del estudiante"/>
</c:if>
<c:if test="${empty error and idRolNuevo == 4}">
  <sql:query var="chkNivel" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM nivel_academico WHERE id_nivel_academico = ?">
    <sql:param value="${idNivel}"/>
  </sql:query>
  <c:if test="${chkNivel.rows[0].n == 0}"><c:set var="error" value="El nivel académico seleccionado no es válido"/></c:if>
</c:if>

<%-- Usuario actual (solo al editar) --%>
<c:if test="${modoEdicion}">
  <sql:query var="actual" dataSource="${db}" sql="SELECT id_usuario, id_rol FROM usuario WHERE id_usuario = ?">
    <sql:param value="${idNum}"/>
  </sql:query>
  <c:if test="${actual.rowCount == 0}">
    <c:set var="error" value="El usuario solicitado no existe"/>
    <c:set var="urlVolver" value="/admin/usuarios.jsp"/>
  </c:if>
</c:if>

<%-- Decisión (d): el administrador no puede cambiar su propio rol --%>
<c:if test="${empty error and modoEdicion and idNum == sessionScope.usuarioId and idRolNuevo != actual.rows[0].id_rol}">
  <c:set var="error" value="No puedes cambiar tu propio rol"/>
</c:if>

<%-- Decisión (c): un solo usuario de Comité --%>
<c:if test="${empty error and not modoEdicion and idRolNuevo == 2}">
  <sql:query var="cuentaComite" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM usuario WHERE id_rol = 2"/>
  <c:if test="${cuentaComite.rows[0].n > 0}">
    <c:set var="error" value="Ya existe un usuario de Comité; el sistema solo admite uno"/>
  </c:if>
</c:if>
<c:if test="${empty error and modoEdicion and idRolNuevo == 2 and actual.rows[0].id_rol != 2}">
  <sql:query var="cuentaComite2" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM usuario WHERE id_rol = 2 AND id_usuario != ?">
    <sql:param value="${idNum}"/>
  </sql:query>
  <c:if test="${cuentaComite2.rows[0].n > 0}">
    <c:set var="error" value="Ya existe un usuario de Comité; el sistema solo admite uno"/>
  </c:if>
</c:if>

<%-- Decisión (a): no cambiar el rol de un usuario con registros asociados --%>
<c:if test="${empty error and modoEdicion and idRolNuevo != actual.rows[0].id_rol}">
  <sql:query var="asociados" dataSource="${db}"
             sql="SELECT (SELECT COUNT(*) FROM idea_docente WHERE id_docente = ?)
                       + (SELECT COUNT(*) FROM proyecto WHERE id_estudiante1 = ? OR id_estudiante2 = ? OR id_director = ? OR id_evaluador = ?)
                       + (SELECT COUNT(*) FROM entrega WHERE id_usuario = ?)
                       + (SELECT COUNT(*) FROM revision WHERE id_revisor = ?) AS total">
    <sql:param value="${idNum}"/><sql:param value="${idNum}"/><sql:param value="${idNum}"/>
    <sql:param value="${idNum}"/><sql:param value="${idNum}"/><sql:param value="${idNum}"/>
    <sql:param value="${idNum}"/>
  </sql:query>
  <c:if test="${asociados.rows[0].total > 0}">
    <c:set var="error" value="No se puede cambiar el rol de un usuario que tiene proyectos, ideas, entregas o revisiones asociadas"/>
  </c:if>
</c:if>

<c:if test="${not empty error}">
  <c:set var="flashError" value="${error}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<%-- Nivel a guardar: NULL para roles que no son Estudiante (NULLIF('','') -> NULL) --%>
<c:set var="nivelFinal" value="${idNivel}"/>
<c:if test="${idRolNuevo != 4}"><c:set var="nivelFinal" value=""/></c:if>

<c:choose>
  <c:when test="${not modoEdicion}">
    <c:catch var="err">
      <sql:update dataSource="${db}"
                  sql="INSERT INTO usuario (nombre_completo, id_tipo_documento, numero_documento, contrasena, id_rol, id_nivel_academico) VALUES (?, ?, ?, ?, ?, NULLIF(?, ''))">
        <sql:param value="${nombre}"/>
        <sql:param value="${idTipo}"/>
        <sql:param value="${numero}"/>
        <sql:param value="${clave}"/>
        <sql:param value="${idRolNuevo}"/>
        <sql:param value="${nivelFinal}"/>
      </sql:update>
    </c:catch>
  </c:when>
  <c:when test="${empty clave}">
    <c:catch var="err">
      <sql:update dataSource="${db}"
                  sql="UPDATE usuario SET nombre_completo = ?, id_tipo_documento = ?, numero_documento = ?, id_rol = ?, id_nivel_academico = NULLIF(?, '') WHERE id_usuario = ?">
        <sql:param value="${nombre}"/>
        <sql:param value="${idTipo}"/>
        <sql:param value="${numero}"/>
        <sql:param value="${idRolNuevo}"/>
        <sql:param value="${nivelFinal}"/>
        <sql:param value="${idNum}"/>
      </sql:update>
    </c:catch>
  </c:when>
  <c:otherwise>
    <c:catch var="err">
      <sql:update dataSource="${db}"
                  sql="UPDATE usuario SET nombre_completo = ?, id_tipo_documento = ?, numero_documento = ?, contrasena = ?, id_rol = ?, id_nivel_academico = NULLIF(?, '') WHERE id_usuario = ?">
        <sql:param value="${nombre}"/>
        <sql:param value="${idTipo}"/>
        <sql:param value="${numero}"/>
        <sql:param value="${clave}"/>
        <sql:param value="${idRolNuevo}"/>
        <sql:param value="${nivelFinal}"/>
        <sql:param value="${idNum}"/>
      </sql:update>
    </c:catch>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="${urlVolver}"/>
</c:if>

<c:set var="flashOk" value="${modoEdicion ? 'Usuario actualizado correctamente' : 'Usuario creado correctamente'}" scope="session"/>
<c:redirect url="/admin/usuarios.jsp"/>
