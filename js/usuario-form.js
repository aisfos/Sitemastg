/* usuario-form.js — Muestra/oculta el nivel académico según el rol (M4, req. 40).
   El servidor SIEMPRE vuelve a validar: si el rol no es Estudiante (4) guarda NULL,
   y si es Estudiante y falta el nivel, muestra el error. Esto es solo ayuda visual. */
(function () {
  function init() {
    var rol = document.getElementById('id_rol');
    var bloque = document.getElementById('bloque-nivel');
    var nivel = document.getElementById('id_nivel_academico');
    if (!rol || !bloque) { return; }

    function actualizar() {
      var esEstudiante = (rol.value === '4');
      bloque.hidden = !esEstudiante;
      if (nivel) {
        if (esEstudiante) {
          nivel.setAttribute('required', 'required');
        } else {
          nivel.removeAttribute('required');
          nivel.value = '';
        }
      }
    }

    rol.addEventListener('change', actualizar);
    actualizar();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
