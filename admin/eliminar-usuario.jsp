<%@ page contentType="text/html; charset=UTF-8" %>
<c:set var="rolRequerido" value="1"/>
<%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%-- eliminar-usuario.jsp — Manejador POST para eliminar usuarios (req. 42, 46, 20g).
     Decisión (b): el administrador no puede eliminar su propio usuario. --%>
<c:if test="${pageContext.request.method ne 'POST'}">
  <c:set var="flashError" value="Acción no permitida" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>

<c:set var="idUsuario" value="${fn:trim(param.id_usuario)}"/>
<c:set var="idNum" value="-1"/>
<c:catch var="errId"><c:set var="idNum" value="${idUsuario + 0}"/></c:catch>
<c:if test="${not empty errId or idNum <= 0}">
  <c:set var="flashError" value="Usuario no válido" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>
<c:if test="${idNum == sessionScope.usuarioId}">
  <c:set var="flashError" value="No puedes eliminar tu propio usuario" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>

<c:set var="mensajeAsociados" value="No se puede eliminar un usuario que tiene proyectos asociados"/>
<c:catch var="err">
  <sql:update var="filas" dataSource="${db}" sql="DELETE FROM usuario WHERE id_usuario = ?">
    <sql:param value="${idNum}"/>
  </sql:update>
</c:catch>

<%@ include file="/WEB-INF/fragmentos/error-bd.jsp" %>
<c:if test="${not empty err}">
  <c:set var="flashError" value="${mensajeBd}" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>
<c:if test="${filas == 0}">
  <c:set var="flashError" value="El usuario no existe" scope="session"/>
  <c:redirect url="/admin/usuarios.jsp"/>
</c:if>

<c:set var="flashOk" value="Usuario eliminado correctamente" scope="session"/>
<c:redirect url="/admin/usuarios.jsp"/>
