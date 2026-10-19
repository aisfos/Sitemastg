/* login.js — Rellena el formulario de acceso al pulsar una fila de "Usuarios de
   prueba" (req. 36). JavaScript solo del lado del cliente; los datos ya vienen
   renderizados por el servidor en los atributos data-*. */
document.addEventListener('DOMContentLoaded', function () {
  var filas = document.querySelectorAll('.fila-prueba');
  var formulario = document.getElementById('form-login');
  if (!formulario || filas.length === 0) {
    return;
  }

  function rellenar(fila) {
    formulario.elements.documento.value = fila.getAttribute('data-documento') || '';
    formulario.elements.clave.value = fila.getAttribute('data-clave') || '';
    formulario.elements.idRol.value = fila.getAttribute('data-rol') || '';
    formulario.elements.documento.focus();
  }

  Array.prototype.forEach.call(filas, function (fila) {
    fila.addEventListener('click', function () { rellenar(fila); });
    fila.addEventListener('keydown', function (evento) {
      if (evento.key === 'Enter' || evento.key === ' ') {
        evento.preventDefault();
        rellenar(fila);
      }
    });
  });
});
