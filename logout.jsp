<%@ page contentType="text/html; charset=UTF-8" %>
<%--
  logout.jsp — Cierre de sesión (req. 37).
  Invalida la sesión y vuelve al login. Debe funcionar en los cuatro roles.
--%>
<c:set var="cierreIgnorado" value="${pageContext.session.invalidate()}"/>
<c:redirect url="/login.jsp?salio=1"/>
