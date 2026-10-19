<%--
  celebracion.jsp — Tarjeta de celebración al finalizar el trabajo de grado (M9-E C3).
  Aparece SOLO cuando el proyecto está finalizado (finalizado = 1), en el panel del
  Estudiante y en el detalle del proyecto. Muestra un check animado, el radicado y
  confeti hecho únicamente con CSS (spans posicionados y animados por clase, sin
  imágenes, sin estilos en línea y sin JavaScript).
  Con prefers-reduced-motion (o sin animación) el check se ve completo y el confeti
  queda quieto; la tarjeta conserva su texto.

  Entradas (las define la página antes de incluir este fragmento):
    celebracionRadicado -> radicado del proyecto (puede venir vacío)

  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<article class="celebracion" data-celebracion="finalizado">
  <div class="celebracion-confeti" aria-hidden="true">
    <span class="confeti confeti-1"></span>
    <span class="confeti confeti-2"></span>
    <span class="confeti confeti-3"></span>
    <span class="confeti confeti-4"></span>
    <span class="confeti confeti-5"></span>
    <span class="confeti confeti-6"></span>
    <span class="confeti confeti-7"></span>
    <span class="confeti confeti-8"></span>
    <span class="confeti confeti-9"></span>
    <span class="confeti confeti-10"></span>
    <span class="confeti confeti-11"></span>
    <span class="confeti confeti-12"></span>
  </div>
  <span class="celebracion-check" aria-hidden="true">
    <svg class="celebracion-check-svg" viewBox="0 0 52 52" focusable="false">
      <circle class="celebracion-check-circulo" cx="26" cy="26" r="24" fill="none" stroke-width="4"/>
      <path class="celebracion-check-trazo" fill="none" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" d="M14.1 27.2 l7.1 7.2 16.7 -16.8"/>
    </svg>
  </span>
  <div class="celebracion-contenido">
    <h3 class="celebracion-titulo">Trabajo de grado finalizado</h3>
    <p class="celebracion-mensaje">¡Felicitaciones! Completaste las seis fases de tu trabajo de grado.</p>
    <c:if test="${not empty celebracionRadicado}">
      <p class="celebracion-radicado">Radicado <strong><c:out value="${celebracionRadicado}"/></strong></p>
    </c:if>
  </div>
</article>
