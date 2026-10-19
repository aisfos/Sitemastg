<%--
  avatar.jsp - Avatar con iniciales (M9-E parte C).
  Variables de entrada (las define la pagina que incluye este fragmento):
     avatarId     -> id del usuario; decide el color de la paleta (avatar-1..8)
     avatarNombre -> nombre completo; decide las iniciales
  Salida: <span class="avatar avatar-N"> con las dos primeras letras en
  mayusculas. Es decorativo (aria-hidden): el nombre siempre aparece al lado.
  Sin JavaScript y sin imagenes externas: todo CSS.
  Este fragmento no declara taglibs: usa los de la pagina que lo incluye.
--%>
<c:if test="${not empty avatarNombre}">
  <c:set var="avatarNombreLimpio" value="${fn:trim(avatarNombre)}"/>
  <c:if test="${not empty avatarNombreLimpio}">
    <c:set var="avatarPartes" value="${fn:split(avatarNombreLimpio, ' ')}"/>
    <c:set var="avatarPrimera" value="${avatarPartes[0]}"/>
    <c:set var="avatarUltima" value="${avatarPartes[fn:length(avatarPartes) - 1]}"/>
    <span class="avatar avatar-${(avatarId % 8) + 1}" aria-hidden="true"><c:out value="${fn:toUpperCase(fn:substring(avatarPrimera, 0, 1))}"/><c:out value="${fn:toUpperCase(fn:substring(avatarUltima, 0, 1))}"/></span>
  </c:if>
</c:if>
