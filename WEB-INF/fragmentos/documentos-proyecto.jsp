<%--
  documentos-proyecto.jsp — Documentos vigentes, historial de versiones y
  observaciones anteriores de un proyecto (req. 21, 64, 65, 66, 68).
  Lo usan las pantallas de gestión (Comité en M8-A; Docente en M8-B).
  Aquí SÍ se muestran los nombres del director y del evaluador que calificaron
  (la restricción del req. 95 aplica solo al estudiante).

  Entrada : docIdProyecto -> id numérico del proyecto (ya validado por la página).

  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<sql:query var="docsVigentes" dataSource="${db}"
           sql="SELECT tipo, numero_version, url, fecha_entrega
                FROM v_ultima_entrega WHERE id_proyecto = ? ORDER BY id_entrega">
  <sql:param value="${docIdProyecto}"/>
</sql:query>
<sql:query var="docsHistorial" dataSource="${db}"
           sql="SELECT id_entrega, fase, tipo, numero_version, url, fecha_entrega, cargado_por
                FROM v_historial_entregas WHERE id_proyecto = ? ORDER BY fecha_entrega, id_entrega">
  <sql:param value="${docIdProyecto}"/>
</sql:query>
<sql:query var="docsObservaciones" dataSource="${db}"
           sql="SELECT fase, rol, revisor, resultado, comentarios, acta_numero, fecha_revision
                FROM v_historial_revisiones WHERE id_proyecto = ? ORDER BY fecha_revision, id_revision">
  <sql:param value="${docIdProyecto}"/>
</sql:query>

<section class="tarjeta">
  <h2>Documentos vigentes</h2>
  <c:choose>
    <c:when test="${docsVigentes.rowCount == 0}">
      <p class="aviso">Todavía no hay documentos cargados.</p>
    </c:when>
    <c:otherwise>
      <div class="tabla-scroll">
        <table class="tabla">
          <thead>
            <tr><th>Tipo</th><th>Versión</th><th>Enlace</th><th>Fecha</th></tr>
          </thead>
          <tbody>
            <c:forEach var="dv" items="${docsVigentes.rows}">
              <tr>
                <td>
                  <c:choose>
                    <c:when test="${dv.tipo == 'IDEA'}">Idea</c:when>
                    <c:when test="${dv.tipo == 'SOPORTE_PAGO'}">Soporte de pago</c:when>
                    <c:when test="${dv.tipo == 'PROPUESTA'}">Propuesta F-DC-124</c:when>
                    <c:when test="${dv.tipo == 'INFORME'}">Informe F-DC-125</c:when>
                    <c:when test="${dv.tipo == 'MANUAL_USUARIO'}">Manual de usuario</c:when>
                    <c:when test="${dv.tipo == 'MANUAL_TECNICO'}">Manual técnico</c:when>
                    <c:when test="${dv.tipo == 'REPOSITORIO'}">Repositorio</c:when>
                    <c:otherwise><c:out value="${dv.tipo}"/></c:otherwise>
                  </c:choose>
                </td>
                <td><c:out value="${dv.numero_version}"/></td>
                <td><a href="<c:out value='${dv.url}'/>" target="_blank" rel="noopener noreferrer">Ver</a></td>
                <td><c:out value="${dv.fecha_entrega}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<section class="tarjeta">
  <h2>Historial de versiones</h2>
  <c:choose>
    <c:when test="${docsHistorial.rowCount == 0}">
      <p class="aviso">Todavía no hay entregas registradas.</p>
    </c:when>
    <c:otherwise>
      <div class="tabla-scroll">
        <table class="tabla">
          <thead>
            <tr><th>Fase</th><th>Tipo</th><th>Versión</th><th>Enlace</th><th>Cargado por</th><th>Fecha</th></tr>
          </thead>
          <tbody>
            <c:forEach var="dh" items="${docsHistorial.rows}">
              <tr>
                <td><c:out value="${dh.fase}"/></td>
                <td>
                  <c:choose>
                    <c:when test="${dh.tipo == 'IDEA'}">Idea</c:when>
                    <c:when test="${dh.tipo == 'SOPORTE_PAGO'}">Soporte de pago</c:when>
                    <c:when test="${dh.tipo == 'PROPUESTA'}">Propuesta F-DC-124</c:when>
                    <c:when test="${dh.tipo == 'INFORME'}">Informe F-DC-125</c:when>
                    <c:when test="${dh.tipo == 'MANUAL_USUARIO'}">Manual de usuario</c:when>
                    <c:when test="${dh.tipo == 'MANUAL_TECNICO'}">Manual técnico</c:when>
                    <c:when test="${dh.tipo == 'REPOSITORIO'}">Repositorio</c:when>
                    <c:otherwise><c:out value="${dh.tipo}"/></c:otherwise>
                  </c:choose>
                </td>
                <td><c:out value="${dh.numero_version}"/></td>
                <td><a href="<c:out value='${dh.url}'/>" target="_blank" rel="noopener noreferrer">Ver</a></td>
                <td><c:out value="${dh.cargado_por}"/></td>
                <td><c:out value="${dh.fecha_entrega}"/></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<section class="tarjeta">
  <h2>Observaciones anteriores</h2>
  <c:choose>
    <c:when test="${docsObservaciones.rowCount == 0}">
      <p class="aviso">Todavía no hay revisiones registradas.</p>
    </c:when>
    <c:otherwise>
      <ol class="linea-tiempo">
        <c:forEach var="dobs" items="${docsObservaciones.rows}">
          <li class="${dobs.resultado == 'APROBADO' ? '' : 'linea-tiempo-aplazado'}">
            <div class="linea-tiempo-encabezado">
              <span class="insignia insignia-gris">Fase <c:out value="${dobs.fase}"/> · <c:out value="${dobs.rol}"/></span>
              <span class="linea-tiempo-quien"><c:out value="${dobs.revisor}"/></span>
              <c:choose>
                <c:when test="${dobs.resultado == 'APROBADO'}"><span class="insignia insignia-verde">Aprobado</span></c:when>
                <c:otherwise><span class="insignia insignia-ambar">Aplazado</span></c:otherwise>
              </c:choose>
              <c:if test="${not empty dobs.acta_numero}">
                <span class="insignia insignia-gris">Acta <c:out value="${dobs.acta_numero}"/></span>
              </c:if>
              <span class="linea-tiempo-fecha"><c:out value="${dobs.fecha_revision}"/></span>
            </div>
            <p class="linea-tiempo-comentario"><c:out value="${dobs.comentarios}"/></p>
          </li>
        </c:forEach>
      </ol>
    </c:otherwise>
  </c:choose>
</section>
