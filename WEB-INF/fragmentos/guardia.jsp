<%--
  guardia.jsp — Control de acceso (req. 38, 20e).
  Cada página protegida declara el rol que exige ANTES de incluir este fragmento:
      <c:set var="rolRequerido" value="1"/>
      <%@ include file="/WEB-INF/fragmentos/guardia.jsp" %>
  Casos:
    - Sin sesión  -> flashError "Debes iniciar sesión" y redirige a login.jsp.
    - Rol que no es el suyo -> flashError "No tienes permiso para acceder a
      esta página" (req. 20e) y redirige al panel del rol en sesión.
  Además envía Cache-Control: no-store para que el botón Atrás no muestre una
  página protegida después de cerrar sesión.
  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<c:set var="cabecerasIgnoradas" value="${pageContext.response.setHeader('Cache-Control','no-store')}"/>
<c:set var="panelPropio" value="${sessionScope.rolId == 1 ? '/admin/panel.jsp' : (sessionScope.rolId == 2 ? '/comite/panel.jsp' : (sessionScope.rolId == 3 ? '/docente/panel.jsp' : '/estudiante/panel.jsp'))}"/>
<c:choose>
  <c:when test="${empty sessionScope.usuarioId}">
    <c:set var="flashError" value="Debes iniciar sesión" scope="session"/>
    <c:redirect url="/login.jsp"/>
  </c:when>
  <c:when test="${sessionScope.rolId != rolRequerido}">
    <c:set var="flashError" value="No tienes permiso para acceder a esta página" scope="session"/>
    <c:redirect url="${panelPropio}"/>
  </c:when>
</c:choose>
