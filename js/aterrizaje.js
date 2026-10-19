/* aterrizaje.js - Interaccion propia de la pagina de aterrizaje (M9-E, parte B).
 *
 * Se carga SOLO en index.jsp (con defer), despues de js/app.js. El menu movil
 * y la cabecera que se solidifica al desplazarse los aporta js/app.js (mismos
 * ganchos [data-menu-movil] y .banner que el resto de la aplicacion); aqui
 * vive solo lo exclusivo del aterrizaje. Un unico archivo, sin dependencias y
 * sin variables globales: todo vive dentro de la funcion anonima. Es mejora
 * progresiva: sin JavaScript la pagina se ve completa y usable (las cifras con
 * su valor final, el carrusel como lista de mensajes y el acordeon nativo
 * <details> uno por uno).
 *
 * Atributos data-* que activan cada mejora:
 *   [data-progreso]          barra de avance de lectura en la parte superior.
 *   [data-cifras]            franja de cifras; anima cada [data-cifra-final]
 *                            desde 0 hasta su valor al entrar en pantalla.
 *   [data-revelar]           bloque que aparece suavemente al entrar en pantalla.
 *   [data-carrusel]          carrusel de mensajes: puntos creados por el
 *                            script, rotacion automatica cada 6 s, pausa al
 *                            pasar el raton o enfocar y control con las
 *                            flechas del teclado. Con movimiento reducido se
 *                            quedan todos los mensajes en lista y sin rotar.
 *   [data-acordeon]          acordeon de <details>: abrir uno cierra los demas.
 *
 * Si el usuario pide menos movimiento (prefers-reduced-motion) no se anima
 * nada: las cifras muestran su valor final, el carrusel deja de rotar y los
 * bloques aparecen de una vez.
 */
(function () {
  'use strict';

  var prefiereQuieto = false;
  try {
    prefiereQuieto = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  } catch (e) { prefiereQuieto = false; }

  function porSelector(raiz, selector) {
    return raiz ? Array.prototype.slice.call(raiz.querySelectorAll(selector)) : [];
  }

  /* ------------------------------------------------ barra de progreso */
  function prepararProgreso() {
    var barra = document.querySelector('[data-progreso]');
    if (!barra) { return; }

    var pendiente = false;

    function pintar() {
      pendiente = false;
      var doc = document.documentElement;
      var alto = doc.scrollHeight - doc.clientHeight;
      var avance = alto > 0 ? (doc.scrollTop / alto) : 0;
      if (avance < 0) { avance = 0; }
      if (avance > 1) { avance = 1; }
      barra.value = avance * 100;
    }

    function alDesplazar() {
      if (pendiente) { return; }
      pendiente = true;
      window.requestAnimationFrame(pintar);
    }

    window.addEventListener('scroll', alDesplazar, { passive: true });
    window.addEventListener('resize', alDesplazar);
    pintar();
  }

  /* ------------------------------------------------- cuenta atras de las cifras */
  function prepararCifras() {
    var franja = document.querySelector('[data-cifras]');
    if (!franja) { return; }
    var numeros = porSelector(franja, '[data-cifra-final]');
    if (!numeros.length) { return; }

    function valorFinal(nodo) {
      var n = parseInt(nodo.getAttribute('data-cifra-final'), 10);
      return isNaN(n) ? 0 : n;
    }

    function fijar() {
      numeros.forEach(function (nodo) { nodo.textContent = String(valorFinal(nodo)); });
    }

    if (prefiereQuieto || !('IntersectionObserver' in window)) {
      fijar();
      return;
    }

    /* Parte de 0 para no ensenar el valor final y saltar: el observer lo sube. */
    numeros.forEach(function (nodo) { nodo.textContent = '0'; });

    function animar(nodo) {
      var destino = valorFinal(nodo);
      if (destino === 0) { nodo.textContent = '0'; return; }
      var duracion = 1100;
      var inicio = null;
      function paso(marca) {
        if (inicio === null) { inicio = marca; }
        var t = (marca - inicio) / duracion;
        if (t > 1) { t = 1; }
        var suavizado = 1 - Math.pow(1 - t, 3);
        nodo.textContent = String(Math.round(destino * suavizado));
        if (t < 1) { window.requestAnimationFrame(paso); }
        else { nodo.textContent = String(destino); }
      }
      window.requestAnimationFrame(paso);
    }

    var observador = new IntersectionObserver(function (entradas) {
      entradas.forEach(function (entrada) {
        if (entrada.isIntersecting) {
          observador.disconnect();
          numeros.forEach(animar);
        }
      });
    }, { threshold: 0.35 });

    observador.observe(franja);
  }

  /* ------------------------------------------------------------ aparicion suave */
  function prepararApariciones() {
    var bloques = porSelector(document, '[data-revelar]');
    if (!bloques.length) { return; }

    if (prefiereQuieto || !('IntersectionObserver' in window)) {
      bloques.forEach(function (b) { b.classList.add('revelar-visible'); });
      return;
    }

    bloques.forEach(function (b) { b.classList.add('revelar'); });

    var observador = new IntersectionObserver(function (entradas) {
      entradas.forEach(function (entrada) {
        if (entrada.isIntersecting) {
          entrada.target.classList.add('revelar-visible');
          observador.unobserve(entrada.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

    bloques.forEach(function (b) { observador.observe(b); });
  }

  /* ------------------------------------------------------------------ carrusel */
  function prepararCarrusel() {
    var carrusel = document.querySelector('[data-carrusel]');
    if (!carrusel) { return; }
    var items = porSelector(carrusel, '.carrusel-item');
    if (items.length < 2) { return; }

    /* Con preferencia de menos movimiento se dejan TODOS los mensajes en
       lista y sin rotacion: la pagina se ve completa igual que sin JS. */
    if (prefiereQuieto) { return; }

    carrusel.classList.add('carrusel-js');

    /* El contenedor de los puntos solo lo crea el script: sin el (o con
       movimiento reducido) no queda un hueco vacio al final de la lista. */
    var puntos = document.createElement('div');
    puntos.className = 'carrusel-puntos';
    puntos.setAttribute('data-carrusel-puntos', '');
    puntos.setAttribute('role', 'group');
    puntos.setAttribute('aria-label', 'Navegacion de mensajes');
    carrusel.appendChild(puntos);

    var actual = 0;
    var temporizador = null;
    var botones = [];

    function pintar() {
      items.forEach(function (item, i) {
        if (i === actual) { item.classList.add('carrusel-item-actual'); }
        else { item.classList.remove('carrusel-item-actual'); }
        item.setAttribute('aria-hidden', i === actual ? 'false' : 'true');
      });
      botones.forEach(function (boton, i) {
        boton.setAttribute('aria-current', i === actual ? 'true' : 'false');
      });
    }

    function ir(indice) {
      actual = (indice + items.length) % items.length;
      pintar();
    }

    items.forEach(function (item, i) {
      var boton = document.createElement('button');
      boton.type = 'button';
      boton.className = 'carrusel-punto';
      boton.setAttribute('aria-label', 'Mensaje ' + (i + 1) + ' de ' + items.length);
      boton.addEventListener('click', function () { ir(i); reiniciar(); });
      puntos.appendChild(boton);
      botones.push(boton);
    });

    function parar() {
      if (temporizador) { window.clearInterval(temporizador); temporizador = null; }
    }
    function reiniciar() {
      parar();
      if (prefiereQuieto) { return; }
      temporizador = window.setInterval(function () { ir(actual + 1); }, 6000);
    }

    carrusel.addEventListener('mouseenter', parar);
    carrusel.addEventListener('mouseleave', reiniciar);
    carrusel.addEventListener('focusin', parar);
    carrusel.addEventListener('focusout', reiniciar);

    carrusel.addEventListener('keydown', function (evento) {
      if (evento.key === 'ArrowRight') { ir(actual + 1); reiniciar(); }
      else if (evento.key === 'ArrowLeft') { ir(actual - 1); reiniciar(); }
    });

    pintar();
    reiniciar();
  }

  /* ------------------------------------------------------------------ acordeon */
  function prepararAcordeon() {
    var acordeon = document.querySelector('[data-acordeon]');
    if (!acordeon) { return; }
    var detalles = porSelector(acordeon, 'details');
    if (!detalles.length) { return; }

    detalles.forEach(function (detalle) {
      detalle.addEventListener('toggle', function () {
        if (!detalle.open) { return; }
        detalles.forEach(function (otro) {
          if (otro !== detalle && otro.open) { otro.open = false; }
        });
      });
    });
  }

  function iniciar() {
    var tareas = [
      prepararProgreso,
      prepararCifras,
      prepararApariciones,
      prepararCarrusel,
      prepararAcordeon
    ];
    tareas.forEach(function (tarea) {
      try { tarea(); } catch (e) { /* Cada mejora es independiente: si una falla, el resto sigue. */ }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', iniciar);
  } else {
    iniciar();
  }
})();
