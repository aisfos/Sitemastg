<%--
  seguimiento-fases.jsp — Seguimiento de las seis fases (req. 6, 7, 93).
  Genérico y reutilizable: lo usa el Estudiante en M7 y los demás roles en M8.
  Sin lógica de rol ni del estudiante.
  Entradas : faseActual -> número de la fase actual (1..6)
             finalizado -> Boolean; si es verdadero las seis salen completadas
  Salida   : el bloque <ul class="seguimiento"> con la fase actual en verde,
             las demás en gris, y todas en verde si el proyecto está finalizado.
  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<c:set var="nombresFases" value="Idea y pago|Propuesta I|Propuesta II|Informe I|Informe II|Cierre"/>
<ul class="seguimiento" aria-label="Seguimiento de las seis fases">
  <c:forEach var="nombreFase" items="${fn:split(nombresFases, '|')}" varStatus="sf">
    <c:choose>
      <c:when test="${finalizado}"><c:set var="claseFase" value="completada"/></c:when>
      <c:when test="${sf.count == faseActual}"><c:set var="claseFase" value="actual"/></c:when>
      <c:otherwise><c:set var="claseFase" value="pendiente"/></c:otherwise>
    </c:choose>
    <li class="seguimiento-fase ${claseFase}"<c:if test="${claseFase == 'actual'}"> aria-current="step"</c:if>>
      <span class="fase-numero"><c:out value="${sf.count}"/></span>
      <span class="fase-descripcion"><c:out value="${nombreFase}"/></span>
    </li>
  </c:forEach>
</ul>
