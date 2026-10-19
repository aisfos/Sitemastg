<header class="banner">
  <div class="contenedor banner-fila">
    <a class="banner-marca" href="${pageContext.request.contextPath}/index.jsp">
      <span class="banner-marca-titulo">Sistemas TG</span>
      <span class="banner-marca-subtitulo">Gestión del trabajo de grado</span>
    </a>
    <div class="banner-derecha">
      <c:if test="${not empty sessionScope.usuarioNombre}">
        <span class="banner-usuario">
          <c:set var="avatarId" value="${sessionScope.usuarioId}"/>
          <c:set var="avatarNombre" value="${sessionScope.usuarioNombre}"/>
          <%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>
          <c:out value="${sessionScope.usuarioNombre}"/>
          <span class="insignia insignia-rol"><c:out value="${sessionScope.rolNombre}"/></span>
        </span>
      </c:if>
      <%-- M9-E parte C: cambio de tema claro/oscuro (js/tema.js, cargado en el
           <head>). Decorativo y accesible; el icono lo alterna el CSS. --%>
      <button type="button" class="tema-boton" data-tema-boton aria-pressed="false" aria-label="Cambiar a tema oscuro" title="Cambiar a tema oscuro">
        <svg class="icono icono-sol" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-sol"/></svg>
        <svg class="icono icono-luna" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-luna"/></svg>
      </button>
    </div>
  </div>
</header>
<c:if test="${not empty sessionScope.flashError}">
  <div class="contenedor"><p class="alerta alerta-error" role="alert"><c:out value="${sessionScope.flashError}"/></p></div>
  <c:remove var="flashError" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.flashOk}">
  <div class="contenedor"><p class="alerta alerta-ok" role="status"><c:out value="${sessionScope.flashOk}"/></p></div>
  <c:remove var="flashOk" scope="session"/>
</c:if>
