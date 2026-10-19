/* app.js - Capa de interaccion global del M9-D (parte A).
 *
 * Un unico archivo, sin dependencias y sin variables globales: todo vive dentro
 * de la funcion anonima. Es mejora progresiva: sin JavaScript cada pagina sigue
 * funcionando (los formularios se envian, los enlaces navegan y el servidor
 * valida). Nunca cambia lo que se envia al servidor.
 *
 * Atributos data-* que activan cada mejora:
 *   .alerta                        avisos tipo "toast": icono, boton de cerrar,
 *                                  cierre automatico de los de exito a los 6 s.
 *   form.form-eliminar             dialogo <dialog> de confirmacion; conserva
 *                                  data-mensaje y data-nombre; sin <dialog>
 *                                  vuelve al confirm nativo.
 *   data-tabla-interactiva         buscador de filas (sin distinguir mayusculas
 *                                  ni acentos), contador "Mostrando X de Y",
 *                                  mensaje de "Sin resultados" y ordenamiento
 *                                  por encabezado (aria-sort + flecha).
 *   input/textarea[maxlength]      contador de caracteres con aviso cerca del
 *                                  limite.
 *   input[data-tipo-url]           validacion de URL en vivo, junto al campo,
 *                                  con las mismas reglas que js/url-valida.js.
 *   input[type="password"]         boton de mostrar/ocultar y aviso de bloqueo
 *                                  de mayusculas.
 *   data-menu-movil / data-menu-boton  menu de hamburguesa en pantallas
 *                                  estrechas (clases y aria-expanded).
 *   details.detalle-fases          al abrir, el seguimiento se revela, se
 *                                  rellena la linea hasta la fase actual y cada
 *                                  fase muestra una pista con su nombre y los
 *                                  roles que actuan (atributo title).
 *   .contenido > .tarjeta          aparicion suave con IntersectionObserver.
 */
(function () {
  'use strict';

  var SVGNS = 'http://www.w3.org/2000/svg';
  var ANCHO_ESCRITORIO = 720;

  /* --------------------------------------------------------------- ayudas */
  function cada(lista, fn) {
    Array.prototype.forEach.call(lista, fn);
  }

  function seguro(fn) {
    try { fn(); } catch (e) { /* una mejora nunca debe romper la pagina */ }
  }

  function reducirMovimiento() {
    return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  }

  /* Ruta del contexto (/sistemastg) tomada de la hoja de estilos. */
  function rutaContexto() {
    var link = document.querySelector('link[rel="stylesheet"][href*="/css/"]');
    if (link) {
      var href = link.getAttribute('href') || '';
      var corte = href.indexOf('/css/');
      if (corte >= 0) { return href.slice(0, corte); }
    }
    var primero = window.location.pathname.split('/')[1];
    return primero ? '/' + primero : '';
  }

  function icono(nombre, clase) {
    var svg = document.createElementNS(SVGNS, 'svg');
    svg.setAttribute('class', clase ? 'icono ' + clase : 'icono');
    svg.setAttribute('aria-hidden', 'true');
    svg.setAttribute('focusable', 'false');
    var use = document.createElementNS(SVGNS, 'use');
    use.setAttribute('href', rutaContexto() + '/img/iconos.svg#i-' + nombre);
    svg.appendChild(use);
    return svg;
  }

  function texto(textoPlano) {
    return document.createTextNode(textoPlano);
  }

  function limpiarHijos(nodo) {
    while (nodo.firstChild) { nodo.removeChild(nodo.firstChild); }
  }

  function sinAcentos(cadena) {
    var base = (cadena || '').toLowerCase();
    if (base.normalize) { base = base.normalize('NFD').replace(/[\u0300-\u036f]/g, ''); }
    return base;
  }

  /* Junta el texto de una fila ignorando el contenido de <details>. */
  function acumularTexto(nodo, partes) {
    if (nodo.nodeType === 3) { partes.push(nodo.nodeValue); return; }
    if (nodo.nodeType !== 1) { return; }
    var etiqueta = nodo.tagName;
    if (etiqueta === 'DETAILS' || etiqueta === 'SCRIPT' || etiqueta === 'STYLE') { return; }
    for (var i = 0; i < nodo.childNodes.length; i++) { acumularTexto(nodo.childNodes[i], partes); }
  }

  function textoFila(fila) {
    var partes = [];
    for (var i = 0; i < fila.childNodes.length; i++) { acumularTexto(fila.childNodes[i], partes); }
    return sinAcentos(partes.join(' '));
  }

  /* ------------------------------------------------------------- 1. avisos */
  function cerrarAviso(aviso) {
    if (aviso.getAttribute('data-aviso-saliendo') === '1') { return; }
    aviso.setAttribute('data-aviso-saliendo', '1');
    var quitar = function () {
      if (aviso.parentNode) { aviso.parentNode.removeChild(aviso); }
    };
    if (reducirMovimiento()) { quitar(); return; }
    aviso.classList.add('aviso-saliendo');
    window.setTimeout(quitar, 260);
  }

  function prepararAvisos() {
    cada(document.querySelectorAll('.alerta'), function (aviso) {
      if (aviso.getAttribute('data-aviso') === '1') { return; }
      aviso.setAttribute('data-aviso', '1');

      var tipo = aviso.classList.contains('alerta-error') ? 'alerta'
               : aviso.classList.contains('alerta-ok') ? 'check'
               : 'informacion';
      aviso.insertBefore(icono(tipo, 'icono-aviso'), aviso.firstChild);
      aviso.classList.add('aviso-js');

      var cerrar = document.createElement('button');
      cerrar.type = 'button';
      cerrar.className = 'alerta-cerrar';
      cerrar.setAttribute('aria-label', 'Cerrar aviso');
      cerrar.appendChild(icono('cerrar'));
      cerrar.addEventListener('click', function () { cerrarAviso(aviso); });
      aviso.appendChild(cerrar);

      aviso.addEventListener('keydown', function (evento) {
        if (evento.key === 'Escape') { cerrarAviso(aviso); }
      });

      /* Los de exito se cierran solos a los 6 segundos. */
      if (aviso.classList.contains('alerta-ok')) {
        window.setTimeout(function () { cerrarAviso(aviso); }, 6000);
      }
    });
  }

  /* ------------------------------------------------------------ 2. dialogos */
  function prepararDialogos() {
    var formularios = document.querySelectorAll('form.form-eliminar');
    if (!formularios.length) { return; }

    var soporta = typeof HTMLDialogElement !== 'undefined' &&
      typeof document.createElement('dialog').showModal === 'function';
    var dialogo = null;
    var nodoMensaje = null;
    var pendiente = null;
    var origen = null;

    function crearDialogo() {
      dialogo = document.createElement('dialog');
      dialogo.className = 'dialogo';

      var titulo = document.createElement('h2');
      titulo.className = 'dialogo-titulo';
      titulo.appendChild(icono('alerta', 'icono-dialogo'));
      titulo.appendChild(document.createTextNode('Confirmar eliminación'));

      nodoMensaje = document.createElement('p');
      nodoMensaje.className = 'dialogo-mensaje';

      var acciones = document.createElement('div');
      acciones.className = 'dialogo-acciones';

      var cancelar = document.createElement('button');
      cancelar.type = 'button';
      cancelar.className = 'boton boton-secundario';
      cancelar.appendChild(document.createTextNode('Cancelar'));

      var confirmar = document.createElement('button');
      confirmar.type = 'button';
      confirmar.className = 'boton boton-peligro';
      confirmar.appendChild(icono('borrar'));
      confirmar.appendChild(document.createTextNode('Eliminar'));

      var cerrar = document.createElement('button');
      cerrar.type = 'button';
      cerrar.className = 'dialogo-cerrar';
      cerrar.setAttribute('aria-label', 'Cerrar');
      cerrar.appendChild(icono('cerrar'));

      acciones.appendChild(cancelar);
      acciones.appendChild(confirmar);
      dialogo.appendChild(titulo);
      dialogo.appendChild(nodoMensaje);
      dialogo.appendChild(acciones);
      dialogo.appendChild(cerrar);
      document.body.appendChild(dialogo);

      cancelar.addEventListener('click', function () { dialogo.returnValue = 'cancelar'; dialogo.close(); });
      confirmar.addEventListener('click', function () { dialogo.returnValue = 'confirmar'; dialogo.close(); });
      cerrar.addEventListener('click', function () { dialogo.returnValue = 'cancelar'; dialogo.close(); });
      dialogo.addEventListener('click', function (evento) {
        if (evento.target === dialogo) { dialogo.returnValue = 'cancelar'; dialogo.close(); }
      });
      dialogo.addEventListener('cancel', function () { dialogo.returnValue = 'cancelar'; });
      dialogo.addEventListener('close', function () {
        var form = pendiente;
        var confirmo = dialogo.returnValue === 'confirmar';
        pendiente = null;
        if (origen && origen.focus) { origen.focus(); }
        origen = null;
        if (confirmo && form) {
          form.setAttribute('data-confirmado', '1');
          form.submit();
        }
      });
    }

    cada(formularios, function (form) {
      form.addEventListener('submit', function (evento) {
        if (form.getAttribute('data-confirmado') === '1') { return; }
        var mensaje = form.getAttribute('data-mensaje');
        if (!mensaje) {
          mensaje = '¿Seguro que deseas eliminar a ' +
            (form.getAttribute('data-nombre') || 'este registro') + '?';
        }
        if (!soporta) {
          if (!window.confirm(mensaje)) { evento.preventDefault(); }
          return;
        }
        evento.preventDefault();
        if (!dialogo) { crearDialogo(); }
        nodoMensaje.textContent = mensaje;
        pendiente = form;
        origen = document.activeElement;
        dialogo.returnValue = 'cancelar';
        dialogo.showModal();
      });
    });
  }

  /* ------------------------------------------------------------- 3. tablas */
  function esNumero(valor) {
    return /^-?\d+([.,]\d+)?$/.test(valor);
  }

  function prepararTabla(host) {
    var tabla = host.tagName === 'TABLE' ? host : host.querySelector('table');
    if (!tabla || !tabla.tBodies || !tabla.tBodies.length || !tabla.tHead) { return; }
    var cuerpo = tabla.tBodies[0];

    var filas = [];
    cada(cuerpo.rows, function (fila) {
      if (!fila.classList.contains('tabla-sin-resultados')) { filas.push(fila); }
    });
    if (!filas.length) { return; }
    var total = filas.length;

    /* --- caja de busqueda y contador --- */
    var herramientas = document.createElement('div');
    herramientas.className = 'tabla-herramientas';

    var etiqueta = document.createElement('label');
    etiqueta.className = 'tabla-buscador';
    etiqueta.appendChild(icono('buscar', 'icono-buscador'));

    var entrada = document.createElement('input');
    entrada.type = 'search';
    entrada.className = 'tabla-buscador-entrada';
    entrada.setAttribute('placeholder', 'Buscar en la tabla...');
    entrada.setAttribute('aria-label', 'Buscar en la tabla');
    etiqueta.appendChild(entrada);

    var contador = document.createElement('p');
    contador.className = 'tabla-contador';
    contador.setAttribute('role', 'status');

    herramientas.appendChild(etiqueta);
    herramientas.appendChild(contador);
    host.parentNode.insertBefore(herramientas, host);

    var vacia = null;

    function filaSinResultados() {
      if (vacia) { return vacia; }
      var columnas = tabla.tHead.rows.length ? tabla.tHead.rows[0].cells.length : 1;
      vacia = document.createElement('tr');
      vacia.className = 'tabla-sin-resultados';
      var celda = document.createElement('td');
      celda.colSpan = columnas;
      celda.appendChild(icono('filtro'));
      celda.appendChild(document.createTextNode(' Sin resultados para la búsqueda.'));
      vacia.appendChild(celda);
      cuerpo.appendChild(vacia);
      return vacia;
    }

    function filtrar() {
      var consulta = sinAcentos((entrada.value || '').trim());
      var visibles = 0;
      cada(filas, function (fila) {
        var coincide = !consulta || textoFila(fila).indexOf(consulta) >= 0;
        fila.classList.toggle('fila-oculta', !coincide);
        if (coincide) { visibles++; }
      });
      contador.textContent = 'Mostrando ' + visibles + ' de ' + total;
      if (visibles === 0) {
        filaSinResultados().classList.remove('fila-oculta');
      } else if (vacia) {
        vacia.classList.add('fila-oculta');
      }
    }

    entrada.addEventListener('input', filtrar);
    entrada.addEventListener('search', filtrar);
    filtrar();

    /* --- ordenamiento --- */
    var encabezados = tabla.tHead.rows[0].cells;

    function valorCelda(fila, indice) {
      var celda = fila.cells[indice];
      return celda ? (celda.textContent || '').trim() : '';
    }

    function columnaNumerica(indice) {
      var alguno = false;
      for (var i = 0; i < filas.length; i++) {
        var valor = valorCelda(filas[i], indice).replace(/\s+/g, '');
        if (valor === '') { continue; }
        if (!esNumero(valor)) { return false; }
        alguno = true;
      }
      return alguno;
    }

    function limpiarMarcas() {
      cada(encabezados, function (celda) {
        if (celda.classList && celda.classList.contains('th-ordenable')) {
          celda.setAttribute('aria-sort', 'none');
          celda.classList.remove('th-asc');
          celda.classList.remove('th-desc');
        }
      });
    }

    function ordenar(celda, indice) {
      var ascendente = celda.getAttribute('aria-sort') !== 'ascending';
      limpiarMarcas();
      celda.setAttribute('aria-sort', ascendente ? 'ascending' : 'descending');
      celda.classList.add(ascendente ? 'th-asc' : 'th-desc');

      var numerica = columnaNumerica(indice);
      var copia = filas.slice();
      copia.sort(function (a, b) {
        var va = valorCelda(a, indice);
        var vb = valorCelda(b, indice);
        var resultado;
        if (numerica) {
          resultado = (parseFloat(va.replace(',', '.')) || 0) - (parseFloat(vb.replace(',', '.')) || 0);
        } else {
          resultado = va.localeCompare(vb, 'es', { sensitivity: 'base', numeric: true });
        }
        return ascendente ? resultado : -resultado;
      });
      cada(copia, function (fila) { cuerpo.appendChild(fila); });
      if (vacia) { cuerpo.appendChild(vacia); }
    }

    cada(encabezados, function (celda, indice) {
      if (!celda.tagName || celda.tagName !== 'TH') { return; }
      if (celda.colSpan > 1) { return; }
      var titulo = (celda.textContent || '').trim();
      if (!titulo || /^acciones$/i.test(titulo) || /^seguimiento$/i.test(titulo)) { return; }

      celda.classList.add('th-ordenable');
      celda.setAttribute('aria-sort', 'none');

      var boton = document.createElement('button');
      boton.type = 'button';
      boton.className = 'th-ordenar';
      boton.setAttribute('title', 'Ordenar por ' + titulo);
      while (celda.firstChild) { boton.appendChild(celda.firstChild); }
      var marca = document.createElement('span');
      marca.className = 'th-marca';
      marca.setAttribute('aria-hidden', 'true');
      boton.appendChild(marca);
      celda.appendChild(boton);

      boton.addEventListener('click', function () { ordenar(celda, indice); });
    });
  }

  function prepararTablas() {
    cada(document.querySelectorAll('[data-tabla-interactiva]'), function (host) {
      prepararTabla(host);
    });
  }

  /* ------------------------------------------- 4a. contador de caracteres */
  function crearContador(campo) {
    var maximo = parseInt(campo.getAttribute('maxlength'), 10);
    if (!maximo || maximo < 1) { return null; }
    var contador = document.createElement('span');
    contador.className = 'contador-campo';
    contador.setAttribute('aria-hidden', 'true');
    var actualizar = function () {
      var usados = (campo.value || '').length;
      contador.textContent = usados + ' / ' + maximo;
      contador.classList.toggle('contador-campo-cerca', usados >= Math.floor(maximo * 0.8) && usados < maximo);
      contador.classList.toggle('contador-campo-limite', usados >= maximo);
    };
    campo.addEventListener('input', actualizar);
    campo.addEventListener('change', actualizar);
    actualizar();
    return contador;
  }

  function prepararContadores() {
    cada(document.querySelectorAll('input[maxlength], textarea[maxlength]'), function (campo) {
      var tipo = (campo.getAttribute('type') || '').toLowerCase();
      if (campo.tagName === 'INPUT' && (tipo === 'hidden' || tipo === 'password' || tipo === 'number')) { return; }
      if (campo.getAttribute('data-con-contador') === '1') { return; }
      var contador = crearContador(campo);
      if (!contador) { return; }
      campo.setAttribute('data-con-contador', '1');
      campo.parentNode.insertBefore(contador, campo.nextSibling);
    });
  }

  /* ----------------------------------------------- 4b. validacion de URL */
  function urlValida(url) {
    if (!url || url.length > 500) { return false; }
    if (url.indexOf('http://') !== 0 && url.indexOf('https://') !== 0) { return false; }
    if (url.indexOf(' ') !== -1) { return false; }
    if (url.indexOf('"') !== -1 || url.indexOf("'") !== -1) { return false; }
    if (url.indexOf('<') !== -1 || url.indexOf('>') !== -1) { return false; }
    return true;
  }

  function prepararUrls() {
    cada(document.querySelectorAll('input[data-tipo-url]'), function (campo) {
      if (campo.getAttribute('data-con-url') === '1') { return; }
      campo.setAttribute('data-con-url', '1');

      var mensaje = document.createElement('span');
      mensaje.className = 'campo-mensaje';
      campo.parentNode.insertBefore(mensaje, campo.nextSibling);

      var revisar = function () {
        var valor = (campo.value || '').trim();
        if (valor === '') {
          mensaje.textContent = '';
          mensaje.classList.remove('campo-mensaje-ok', 'campo-mensaje-error');
          return;
        }
        var bien = urlValida(valor);
        mensaje.textContent = bien
          ? 'Enlace con formato correcto'
          : 'La URL no tiene un formato válido (debe empezar por http:// o https://)';
        mensaje.classList.toggle('campo-mensaje-ok', bien);
        mensaje.classList.toggle('campo-mensaje-error', !bien);
      };

      campo.addEventListener('input', revisar);
      campo.addEventListener('blur', revisar);
      revisar();
    });
  }

  /* --------------------------- 4c. contrasena: ojo y bloqueo de mayusculas */
  function prepararClaves() {
    cada(document.querySelectorAll('input[type="password"]'), function (campo) {
      if (campo.getAttribute('data-con-ojo') === '1') { return; }
      campo.setAttribute('data-con-ojo', '1');

      var fila = document.createElement('div');
      fila.className = 'campo-clave-fila';
      campo.parentNode.insertBefore(fila, campo);
      fila.appendChild(campo);

      var boton = document.createElement('button');
      boton.type = 'button';
      boton.className = 'boton-ojo';
      boton.setAttribute('aria-pressed', 'false');
      boton.setAttribute('aria-label', 'Mostrar contraseña');
      boton.setAttribute('title', 'Mostrar contraseña');
      boton.appendChild(icono('ojo'));
      boton.addEventListener('click', function () {
        var visible = campo.getAttribute('type') === 'text';
        campo.setAttribute('type', visible ? 'password' : 'text');
        boton.setAttribute('aria-pressed', visible ? 'false' : 'true');
        boton.setAttribute('aria-label', visible ? 'Mostrar contraseña' : 'Ocultar contraseña');
        boton.setAttribute('title', visible ? 'Mostrar contraseña' : 'Ocultar contraseña');
        while (boton.firstChild) { boton.removeChild(boton.firstChild); }
        boton.appendChild(icono(visible ? 'ojo' : 'ojo-tachado'));
        campo.focus();
      });
      fila.appendChild(boton);

      var aviso = document.createElement('span');
      aviso.className = 'clave-bloqueo';
      aviso.appendChild(icono('alerta'));
      aviso.appendChild(document.createTextNode(' Bloqueo de mayúsculas activado'));

      var revisar = function (evento) {
        var hay = !!(evento && typeof evento.getModifierState === 'function' &&
          evento.getModifierState('CapsLock'));
        aviso.classList.toggle('clave-bloqueo-visible', hay);
      };
      campo.addEventListener('keydown', revisar);
      campo.addEventListener('keyup', revisar);
      campo.addEventListener('blur', function () {
        aviso.classList.remove('clave-bloqueo-visible');
      });
      fila.parentNode.insertBefore(aviso, fila.nextSibling);
    });
  }

  /* ------------------------------- 4e. iconos de acciones y estados vacios */
  /* Los botones de accion principales llevan icono del sprite. La lista esta
     ordenada: se aplica la primera regla que coincide con el texto del boton.
     Los que no coinciden se quedan como estaban (nunca se rompe nada). */
  var ACCIONES = [
    [/^(nuevo usuario|nueva idea|proponer idea|crear proyecto|tomar( esta| otra)? idea)/, 'mas'],
    [/^eliminar$/, 'borrar'],
    [/^(aprobar|registrar calificaci|cerrar proyecto|guardar)/, 'check'],
    [/^aplazar/, 'reloj'],
    [/^entrar$/, 'salir'],
    [/^gestionar fases$/, 'carpeta'],
    [/^mis proyectos$/, 'documento'],
    [/^(enviar|subir|reenviar)/, 'documento'],
    [/^(corregir|editar)/, 'editar']
  ];

  function prepararAcciones() {
    cada(document.querySelectorAll('.boton-primario, .boton-peligro, .boton-secundario.boton-pequeno'), function (boton) {
      if (boton.querySelector('svg') || boton.getAttribute('data-con-icono') === '1') { return; }
      var textoBoton = sinAcentos((boton.textContent || '').replace(/\s+/g, ' ').trim());
      for (var i = 0; i < ACCIONES.length; i++) {
        if (ACCIONES[i][0].test(textoBoton)) {
          boton.setAttribute('data-con-icono', '1');
          boton.insertBefore(icono(ACCIONES[i][1]), boton.firstChild);
          return;
        }
      }
    });
  }

  /* Estados vacios: los parrafos .aviso que dicen que no hay datos. */
  function prepararVacios() {
    var sinDatos = /^(no hay|todavia no|aun no)/;
    cada(document.querySelectorAll('.aviso'), function (aviso) {
      if (aviso.getAttribute('data-vacio-listo') === '1') { return; }
      var contenido = sinAcentos((aviso.textContent || '').replace(/\s+/g, ' ').trim());
      if (!sinDatos.test(contenido)) { return; }
      aviso.setAttribute('data-vacio-listo', '1');
      aviso.classList.add('aviso-vacio');
      aviso.insertBefore(icono('carpeta', 'icono-vacio'), aviso.firstChild);
    });
  }

  /* ------------------------------------------------- 4d. boton de envio */
  function prepararEnvios() {
    cada(document.querySelectorAll('form'), function (form) {
      var metodo = (form.getAttribute('method') || 'get').toLowerCase();
      if (metodo !== 'post') { return; }
      if (form.classList.contains('form-eliminar')) { return; }

      var boton = form.querySelector('button[type="submit"], input[type="submit"], button:not([type])');
      if (!boton) { return; }
      var esEntrada = boton.tagName === 'INPUT';
      var original = esEntrada ? boton.value : boton.innerHTML;

      var restablecer = function () {
        if (boton.getAttribute('data-enviando') !== '1') { return; }
        boton.removeAttribute('data-enviando');
        boton.disabled = false;
        if (esEntrada) { boton.value = original; } else { boton.innerHTML = original; }
      };

      form.addEventListener('submit', function (evento) {
        /* Si url-valida.js ya cancelo el envio, no se toca el boton. */
        if (evento.defaultPrevented) { return; }
        if (boton.getAttribute('data-enviando') === '1') { return; }
        /* Ningun control de envio del proyecto lleva atributo name, asi que
           deshabilitarlo no quita ningun dato al formulario. */
        boton.setAttribute('data-enviando', '1');
        boton.disabled = true;
        if (esEntrada) {
          boton.value = 'Enviando...';
        } else {
          while (boton.firstChild) { boton.removeChild(boton.firstChild); }
          boton.appendChild(document.createTextNode('Enviando...'));
        }
        window.setTimeout(restablecer, 6000);
      });

      form.addEventListener('invalid', restablecer, true);
      window.addEventListener('pageshow', restablecer);
    });
  }

  /* ------------------------------------------------------ 5. apariciones */
  function prepararApariciones() {
    var objetivos = document.querySelectorAll('.contenido > .tarjeta');
    if (!objetivos.length || reducirMovimiento() || typeof window.IntersectionObserver !== 'function') { return; }
    cada(objetivos, function (elemento) { elemento.classList.add('tarjeta-aparece'); });
    var observador = new IntersectionObserver(function (entradas) {
      cada(entradas, function (entrada) {
        if (entrada.isIntersecting) {
          entrada.target.classList.add('tarjeta-visible');
          observador.unobserve(entrada.target);
        }
      });
    }, { threshold: 0.04, rootMargin: '0px 0px -6% 0px' });
    cada(objetivos, function (elemento) { observador.observe(elemento); });
  }

  /* ---------------------------------------------------- 6. menu movil */
  function prepararMenu() {
    cada(document.querySelectorAll('[data-menu-movil]'), function (menu) {
      var boton = menu.querySelector('[data-menu-boton]');
      var lista = menu.querySelector('.menu-lista');
      if (!boton || !lista) { return; }
      menu.classList.add('menu-js');

      var abrir = function (si) {
        menu.classList.toggle('menu-abierto', si);
        boton.setAttribute('aria-expanded', si ? 'true' : 'false');
      };
      boton.addEventListener('click', function () {
        abrir(!menu.classList.contains('menu-abierto'));
      });
      lista.addEventListener('click', function (evento) {
        var enlace = evento.target && evento.target.closest ? evento.target.closest('a') : null;
        if (enlace) { abrir(false); }
      });
      menu.addEventListener('keydown', function (evento) {
        if (evento.key === 'Escape' && menu.classList.contains('menu-abierto')) {
          abrir(false);
          boton.focus();
        }
      });
      window.addEventListener('resize', function () {
        if (window.innerWidth > ANCHO_ESCRITORIO) { abrir(false); }
      });
    });
  }

  /* -------------------------------------------------- 7. seguimiento */
  function prepararSeguimiento() {
    var rolesPorFase = [
      'Estudiante y Comité',
      'Estudiante y Director',
      'Estudiante, Evaluador y Comité',
      'Estudiante y Director',
      'Estudiante, Evaluador y Comité',
      'Comité'
    ];

    cada(document.querySelectorAll('.seguimiento'), function (lista) {
      var fases = lista.querySelectorAll('.seguimiento-fase');
      if (!fases.length) { return; }

      var actual = -1;
      cada(fases, function (fase, indice) {
        if (!fase.getAttribute('title')) {
          var descripcion = fase.querySelector('.fase-descripcion');
          var nombre = descripcion && descripcion.textContent
            ? descripcion.textContent.trim()
            : 'Fase ' + (indice + 1);
          fase.setAttribute('title',
            'Fase ' + (indice + 1) + ': ' + nombre + '. Roles en esta fase: ' + (rolesPorFase[indice] || '') + '.');
        }
        if (fase.classList.contains('actual')) { actual = indice; }
      });

      /* Linea rellena hasta la fase actual (o todas si el proyecto finalizo). */
      var completadas = lista.querySelectorAll('.seguimiento-fase.completada').length;
      if (completadas) {
        cada(fases, function (fase) { fase.classList.add('fase-marcada'); });
      } else if (actual >= 0) {
        cada(fases, function (fase, indice) {
          if (indice < actual) { fase.classList.add('fase-marcada'); }
        });
      }

      var detalles = lista.closest ? lista.closest('details') : null;
      var revelar = function () { lista.classList.add('seguimiento-revelado'); };
      if (!detalles) { revelar(); return; }
      lista.classList.add('seguimiento-js');
      if (detalles.open) { revelar(); }
      detalles.addEventListener('toggle', function () {
        if (detalles.open) { revelar(); }
      });
    });
  }

  /* ------------------------------------------- 8. cabecera con sombra */
  function prepararCabecera() {
    var banner = document.querySelector('.banner');
    if (!banner) { return; }
    var alDesplazar = function () {
      if (window.scrollY > 8) { banner.classList.add('banner-scroll'); }
      else { banner.classList.remove('banner-scroll'); }
    };
    alDesplazar();
    window.addEventListener('scroll', alDesplazar, { passive: true });
  }

  /* ------------------------------------------------------------ arranque */
  function iniciar() {
    seguro(prepararAvisos);
    seguro(prepararDialogos);
    seguro(prepararTablas);
    seguro(prepararContadores);
    seguro(prepararUrls);
    seguro(prepararClaves);
    seguro(prepararAcciones);
    seguro(prepararVacios);
    seguro(prepararEnvios);
    seguro(prepararApariciones);
    seguro(prepararMenu);
    seguro(prepararSeguimiento);
    seguro(prepararCabecera);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', iniciar);
  } else {
    iniciar();
  }
})();
