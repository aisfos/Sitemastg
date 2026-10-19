/* revision-fase1.js — Filtro de cliente del Comité en la Fase 1 (M6 parte B, req. 9).
   El evaluador no puede ser el director: al cambiar el director, la opción que
   coincide con él se deshabilita en la lista de evaluadores. El servidor vuelve a
   validarlo (req. 20h); esto es solo comodidad. Nada se inyecta en el DOM: se leen
   valores de los propios controles. */
(function () {
  function init() {
    var director = document.getElementById('id_director');
    var evaluador = document.getElementById('id_evaluador');
    if (!evaluador) {
      return;
    }

    function valorDirector() {
      if (director && director.value) {
        return director.value;
      }
      return evaluador.getAttribute('data-director') || '';
    }

    function filtrar() {
      var elegido = valorDirector();
      Array.prototype.forEach.call(evaluador.options, function (opcion) {
        if (opcion.value && opcion.value === elegido) {
          opcion.disabled = true;
          if (evaluador.value === elegido) {
            evaluador.value = '';
          }
        } else {
          opcion.disabled = false;
        }
      });
    }

    if (director) {
      director.addEventListener('change', filtrar);
    }
    filtrar();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
