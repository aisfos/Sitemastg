<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<fmt:requestEncoding value="UTF-8"/>
<%-- M9: cabeceras de seguridad en un solo punto; el include-prelude de
     web.xml lo inyecta al inicio de CADA página JSP (incluidas login, error y
     las que redirigen, que aun no han comprometido la respuesta). Los
     fragmentos de /WEB-INF/fragmentos NO lo reciben: se insertan de forma
     estática (textual) en la página y no se traducen por separado. --%>
<c:set var="m9Nosniff" value="${pageContext.response.setHeader('X-Content-Type-Options','nosniff')}"/>
<c:set var="m9Frame"   value="${pageContext.response.setHeader('X-Frame-Options','DENY')}"/>
<c:set var="m9Ref"     value="${pageContext.response.setHeader('Referrer-Policy','same-origin')}"/>
<c:set var="m9Csp">default-src 'self'; frame-ancestors 'none'; form-action 'self'</c:set>
<c:set var="m9CspSet"  value="${pageContext.response.setHeader('Content-Security-Policy', m9Csp)}"/>
