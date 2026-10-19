/* confirmar.js — Confirmación en el cliente para los formularios de eliminación (M4, req. 42).
   El nombre se lee de data-nombre (atributo HTML), nunca se inyecta en JS. */
(function () {
  function init() {
    var forms = document.querySelectorAll('form.form-eliminar');
    Array.prototype.forEach.call(forms, function (form) {
      form.addEventListener('submit', function (evento) {
        var mensaje = form.getAttribute('data-mensaje')
          || ('¿Seguro que deseas eliminar a ' + (form.getAttribute('data-nombre') || 'este registro') + '?');
        if (!window.confirm(mensaje)) {
          evento.preventDefault();
        }
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
