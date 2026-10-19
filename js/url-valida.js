/* url-valida.js — Validación de URL en el cliente (M7, req. 17, 20d).
   Mismas reglas que el servidor (WEB-INF/fragmentos/url-valida.jsp): no vacía, máximo
   500 caracteres, empieza por http:// o https://, sin espacios, sin comillas
   dobles ni simples y sin < ni >. El servidor vuelve a validarlo siempre; esto es
   solo comodidad para el usuario. No se inyecta nada en el DOM. */
(function () {
  var MENSAJE = 'La URL no tiene un formato válido';

  function esValida(url) {
    if (!url || url.length > 500) {
      return false;
    }
    if (url.indexOf('http://') !== 0 && url.indexOf('https://') !== 0) {
      return false;
    }
    if (url.indexOf(' ') !== -1) {
      return false;
    }
    if (url.indexOf('"') !== -1 || url.indexOf("'") !== -1) {
      return false;
    }
    if (url.indexOf('<') !== -1 || url.indexOf('>') !== -1) {
      return false;
    }
    return true;
  }

  function init() {
    var formularios = document.querySelectorAll('form[data-validar-url]');
    Array.prototype.forEach.call(formularios, function (form) {
      form.addEventListener('submit', function (evento) {
        var campos = form.querySelectorAll('input[data-tipo-url]');
        var invalido = null;
        Array.prototype.forEach.call(campos, function (campo) {
          campo.setCustomValidity('');
          var valor = campo.value.trim();
          if (valor !== '' && !esValida(valor)) {
            campo.setCustomValidity(MENSAJE);
            if (!invalido) {
              invalido = campo;
            }
          }
        });
        if (invalido) {
          evento.preventDefault();
          invalido.reportValidity();
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
