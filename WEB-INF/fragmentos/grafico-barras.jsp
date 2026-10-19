<%--
  grafico-barras.jsp — Gráfico de barras horizontales de solo lectura (M9-E C1).
  Reutilizable por los paneles de Administrador, Comité y Docente.
  El SVG se dibuja SOLO con atributos de presentación (x, y, width, height, rx,
  font-size); los colores van por clase CSS, nunca con style en línea (la CSP
  default-src 'self' bloquea los estilos en línea).
  Si no hay datos (total 0) muestra un estado vacío y nunca un SVG con NaN.
  Cada gráfico lleva una tabla de datos oculta visualmente (.solo-lectores) como
  alternativa de texto accesible.

  Entradas (las define la página antes de incluir este fragmento):
    barrasId          -> id único del gráfico (data-grafico)
    barrasTitulo      -> título visible
    barrasColEtiqueta -> encabezado de la columna de categorías (tabla oculta)
    barrasColValor    -> encabezado de la columna de valores (tabla oculta)
    barrasRows        -> filas con .etiqueta, .n y .pct (0..100)
    barrasTotal       -> número total; 0 -> estado vacío

  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<c:set var="barrasAlto" value="${fn:length(barrasRows) * 16}"/>
<figure class="grafico" data-grafico="${barrasId}">
  <figcaption class="grafico-titulo"><c:out value="${barrasTitulo}"/></figcaption>
  <c:choose>
    <c:when test="${barrasTotal > 0}">
      <svg class="grafico-svg" viewBox="0 0 250 ${barrasAlto}" role="img" aria-label="Gráfico de barras: ${barrasTitulo}. Los valores están en la tabla de datos del gráfico." preserveAspectRatio="xMinYMin meet">
        <c:forEach var="b" items="${barrasRows}" varStatus="bs">
          <c:set var="yFila" value="${bs.index * 16}"/>
          <text class="grafico-etiqueta" x="0" y="${yFila + 11}" font-size="8"><c:out value="${b.etiqueta}"/></text>
          <rect class="grafico-pista" x="110" y="${yFila + 3}" width="100" height="10" rx="5"/>
          <rect class="grafico-barra" x="110" y="${yFila + 3}" width="${b.pct}" height="10" rx="5"/>
          <text class="grafico-numero" x="216" y="${yFila + 11}" font-size="8"><c:out value="${b.n}"/></text>
        </c:forEach>
      </svg>
    </c:when>
    <c:otherwise>
      <p class="grafico-vacio">Sin datos todavía.</p>
    </c:otherwise>
  </c:choose>
  <table class="solo-lectores">
    <caption><c:out value="${barrasTitulo}"/></caption>
    <thead>
      <tr><th scope="col"><c:out value="${barrasColEtiqueta}"/></th><th scope="col"><c:out value="${barrasColValor}"/></th></tr>
    </thead>
    <tbody>
      <c:forEach var="b" items="${barrasRows}">
        <tr data-etiqueta="<c:out value='${b.etiqueta}'/>" data-valor="<c:out value='${b.n}'/>"><th scope="row"><c:out value="${b.etiqueta}"/></th><td><c:out value="${b.n}"/></td></tr>
      </c:forEach>
    </tbody>
  </table>
</figure>
