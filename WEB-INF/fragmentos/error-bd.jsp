<%--
  error-bd.jsp - Convencion de errores de BD (ver AGENTS.md, seccion 13).
  Traduce la excepcion capturada en "err" a un mensaje amigable para el usuario.
  NUNCA muestra err.message ni mensajes crudos de la BD.

  Entradas : err              -> la excepcion de <c:catch var="err">
             mensajeAsociados  -> (opcional, page scope) mensaje propio para errorCode 1451
             mensajeDuplicado  -> (opcional, page scope) mensaje propio para errorCode 1062
  Salida   : mensajeBd       -> (page scope) mostrar con <c:out value="${mensajeBd}"/>
             (vacio si no hubo error)

  Este fragmento no declara taglibs: usa los de la pagina que lo incluye.
--%>
<c:choose>
  <c:when test="${empty err}">
    <c:set var="mensajeBd" value=""/>
  </c:when>
  <c:when test="${err.cause.SQLState == '45000'}">
    <c:set var="mensajeBd" value="${err.cause.message}"/>
  </c:when>
  <c:when test="${err.cause.errorCode == 1451}">
    <c:set var="mensajeBd" value="${empty mensajeAsociados ? 'No se puede realizar la operación: el registro tiene datos asociados.' : mensajeAsociados}"/>
  </c:when>
  <c:when test="${err.cause.errorCode == 1062}">
    <c:set var="mensajeBd" value="${empty mensajeDuplicado ? 'El número de documento ya está registrado' : mensajeDuplicado}"/>
  </c:when>
  <c:otherwise>
    <c:set var="mensajeBd" value="Ocurrió un error inesperado. Intenta de nuevo."/>
    <c:set var="bdDetalleLog" value="${pageContext.servletContext.log(err.message)}"/>
  </c:otherwise>
</c:choose>
