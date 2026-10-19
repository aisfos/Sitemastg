/* tema.js - Selector de tema claro/oscuro de Sistemas TG (M9-E parte C).
 *
 * Se carga SIN defer en el <head> de todas las paginas (despues de abrir
 * <html> y antes de la hoja de estilos) para fijar el atributo data-tema del
 * elemento raiz antes de pintar: sin parpadeo ni cambio visible de tema.
 *
 * El tema inicial es SIEMPRE el claro. No se consulta la preferencia del
 * sistema (ni el esquema de color del sistema operativo): el tema oscuro solo
 * se activa cuando el usuario pulsa el boton [data-tema-boton] y esa eleccion
 * se conserva en localStorage.
 *
 * Orden del valor inicial:
 *   1. la preferencia guardada por el usuario (localStorage, siempre en
 *      try/catch: si el navegador la bloquea se ignora);
 *   2. tema claro.
 *
 * El boton [data-tema-boton] vive en el encabezado. El script lee y escribe el
 * atributo data-tema en <html>; el CSS muestra el icono (sol o luna) que toca
 * y aplica los tokens oscuros. Un unico archivo, sin dependencias y sin
 * variables globales: todo vive dentro de la funcion anonima.
 */
(function () {
  'use strict';

  var CLAVE = 'sistemas-tg-tema';
  var raiz = document.documentElement;

  function guardado() {
    try {
      var v = window.localStorage.getItem(CLAVE);
      if (v === 'claro' || v === 'oscuro') { return v; }
    } catch (e) { /* localStorage bloqueado */ }
    return '';
  }

  function preferido() {
    var g = guardado();
    if (g) { return g; }
    return 'claro';
  }

  function etiqueta(t) {
    return t === 'oscuro' ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro';
  }

  function aplicar(t) {
    raiz.setAttribute('data-tema', t);
    var botones = document.querySelectorAll('[data-tema-boton]');
    for (var i = 0; i < botones.length; i++) {
      botones[i].setAttribute('aria-pressed', t === 'oscuro' ? 'true' : 'false');
      botones[i].setAttribute('title', etiqueta(t));
      botones[i].setAttribute('aria-label', etiqueta(t));
    }
  }

  /* Se aplica de inmediato (el <script> esta en el <head>). */
  aplicar(preferido());

  function alternar() {
    var nuevo = raiz.getAttribute('data-tema') === 'oscuro' ? 'claro' : 'oscuro';
    aplicar(nuevo);
    try { window.localStorage.setItem(CLAVE, nuevo); } catch (e) { /* sin persistencia */ }
  }

  function conectar() {
    var botones = document.querySelectorAll('[data-tema-boton]');
    for (var i = 0; i < botones.length; i++) {
      botones[i].addEventListener('click', alternar);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', conectar);
  } else {
    conectar();
  }
})();
