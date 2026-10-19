<%--
  grafico-anillo.jsp — Anillo de progreso "Fase N de 6" del Estudiante (M9-E C1).
  Dibujado con atributos SVG (stroke-dasharray / stroke-dashoffset sobre un
  círculo de r=15.9155, cuya circunferencia es 100, así el porcentaje es directo).
  Sin estilos en línea y sin librerías: los colores van por clase CSS.
  Cuando el proyecto está finalizado el porcentaje es 100 (6 de 6).
  Nunca muestra al director ni al evaluador (req. 95): solo la fase.

  Entradas (las define la página antes de incluir este fragmento):
    anilloId       -> id del proyecto (data-anillo)
    anilloFase     -> fase actual (1..6)
    anilloPct      -> porcentaje 0..100 (data-pct)
    anilloEtiqueta -> texto accesible y visible ("Fase 3 de 6")

  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<span class="anillo" data-anillo="${anilloId}" data-fase="${anilloFase}" data-pct="${anilloPct}" role="img" aria-label="<c:out value='${anilloEtiqueta}'/>">
  <svg class="anillo-svg" viewBox="0 0 36 36" aria-hidden="true" focusable="false">
    <circle class="anillo-pista" cx="18" cy="18" r="15.9155" fill="none" stroke-width="3"/>
    <circle class="anillo-valor" cx="18" cy="18" r="15.9155" fill="none" stroke-width="3" stroke-dasharray="${anilloPct} 100" stroke-dashoffset="25"/>
  </svg>
  <span class="anillo-texto"><c:out value="${anilloEtiqueta}"/></span>
</span>
