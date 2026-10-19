<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Error — Sistemas TG</title>
  <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/img/favicon.svg">
  <script src="${pageContext.request.contextPath}/js/tema.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilo.css">
</head>
<body>
<main class="contenedor contenido">
  <div class="tarjeta tarjeta-error pagina-estado">
    <svg class="pagina-estado-icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-alerta"/></svg>
    <h1>Algo salió mal</h1>
    <p>La página no está disponible o ocurrió un error inesperado. Vuelve a intentarlo; si el problema continúa, cierra sesión y entra de nuevo.</p>
    <c:if test="${not empty requestScope['javax.servlet.error.status_code']}">
      <p>Código de estado: <c:out value="${requestScope['javax.servlet.error.status_code']}"/></p>
    </c:if>
    <p class="pagina-estado-acciones">
      <a class="boton boton-primario" href="${pageContext.request.contextPath}/index.jsp">Volver al inicio</a>
    </p>
  </div>
</main>
</body>
</html>
