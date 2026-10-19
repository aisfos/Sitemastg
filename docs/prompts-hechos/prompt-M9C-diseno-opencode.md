# Prompt M9-C para opencode: rediseño visual (paleta verde UTS y login con foto)

Antes de usarlo, el usuario debe:
1. Guardar la foto de la entrada de la universidad en C:\xampp\tomcat\webapps\sistemastg\img\login-fondo.jpg (crea la carpeta img si no existe). Mientras más grande, mejor (ideal 1600 px de ancho o más).
2. Opcional: si tiene el logo de la universidad, guardarlo como img\logo.png o img\logo.svg.
3. Guardar este archivo en docs/ del proyecto, con MySQL y Tomcat encendidos.

Luego abre una sesión NUEVA de opencode en la carpeta sistemastg y escribe solo esto:

    Lee docs/prompt-M9C-diseno-opencode.md y ejecútalo completo, desde la línea "RETOMAR" hasta el final. Usa las herramientas de verdad; no imprimas llamadas como texto.

---

RETOMAR. Esta es una sesión nueva: no tienes memoria de las anteriores. Lee primero AGENTS.md (reglas, incluida la sección 13) y PLAN.md (estado: M1 a M9 hechos). Si el contexto se compacta, relee PLAN.md y este archivo en vez de reconstruir de memoria.

Comprobación previa (no modifiques nada todavía): la base está en el baseline (usuario 11 con AUTO_INCREMENT 12; idea_docente 5 con AUTO_INCREMENT 6; proyecto, entrega y revision en 0 con AUTO_INCREMENT 1; SELECT * de idea_docente con SHA-256 39845BD019304696000C3F52747F038DCCD3C219F38295C5D8D91517C2779058 y 1524 bytes), Tomcat responde y existe C:\sistemastg-tests\run-all.ps1. Comprueba si existe img\login-fondo.jpg (tamaño y dimensiones si puedes) e img\logo.png o logo.svg. Si falta login-fondo.jpg, detente y avísame.

OBJETIVO
El diseño actual se ve crudo (el usuario dice "muy verde", es decir, sin pulir). Quiere un aspecto profesional con la paleta verde de la UTS, y el login con la foto de la entrada de la universidad como fondo. Las decisiones de diseño quedan a tu criterio dentro de estas reglas. Esto es SOLO presentación: no cambies lógica, consultas, mensajes ni textos funcionales.

REGLAS DURAS
- Sin CDN, sin librerías, sin fuentes externas (la política CSP del proyecto es default-src 'self'): usa una pila de fuentes del sistema (por ejemplo "Segoe UI", system-ui, Roboto, "Helvetica Neue", Arial, sans-serif). Sin estilos en línea (style="..."), sin scripts ni manejadores en línea: todo en css/ y js/.
- Las pruebas automáticas comprueban clases CSS, estructura y textos de la aplicación (por ejemplo las seis casillas del seguimiento de fases con la clase de fase actual, insignias, botones con el atributo disabled, mensajes). Conserva los nombres de clase, la estructura HTML y los textos que usan. Para cambiar el aspecto, cambia el CSS; si necesitas agregar clases o envoltorios nuevos, añádelos sin quitar los existentes. Si algo en las pruebas debe actualizarse porque el cambio es legítimo, díselo al usuario y actualízalo en C:\sistemastg-tests dejando constancia.
- Responsive de verdad (probado mentalmente en 360, 768 y 1280 px): sin desbordes horizontales de página; las tablas dentro de un contenedor con desplazamiento horizontal propio.
- Accesibilidad: contraste mínimo 4.5:1 en textos, foco de teclado visible en enlaces, botones y campos, y respeto de prefers-reduced-motion.

PALETA
- Abre la foto img\login-fondo.jpg con la herramienta Read para verla y toma de ella el verde dominante del arco de la entrada como verde principal de la marca. Si no puedes ver la imagen, usa como referencia aproximada: principal #1E8E3E, oscuro #0E5A2A, muy oscuro #0A3D1D, tinte claro #E8F5EC, y avísame para que el usuario ajuste si tiene el manual de marca.
- Define todo como variables en :root (verdes de 50 a 900, neutros, semánticos). Uso del verde: banner, botones primarios, acentos y estados. Fondo general neutro muy claro (no verdoso), tarjetas blancas, texto gris muy oscuro. Colores semánticos para las insignias de estado: Pendiente ámbar, Aprobada verde, Aplazada naranja o rojo suave, Finalizado verde oscuro, Disponible y No disponible diferenciados; texto legible sobre cada fondo.

DISEÑO (aplica a TODAS las páginas mediante css/estilo.css y los JSPF de encabezado, menú y pie)
1. Tipografía: base de 16 px, interlineado 1.5, jerarquía clara de h1, h2 y h3, y una escala de espaciado consistente.
2. Encabezado: banner verde con el nombre "Sistemas TG" y el subtítulo "Gestión del trabajo de grado" (usa el logo si existe img\logo.*; si no, solo texto), y a la derecha el usuario y una insignia de rol, bien alineados.
3. Menú: barra de navegación limpia con el enlace de la página actual resaltado (detéctalo con EL, por ejemplo con pageContext.request.servletPath, sin scriptlets), efecto al pasar el cursor y adaptación a pantallas estrechas (que se envuelva o se desplace, sin JS en línea).
4. Tarjetas con borde redondeado, sombra suave y título con una barra de acento; avisos de error, éxito e información con color y borde izquierdo (sin librerías de iconos; si quieres iconos, SVG en línea en el HTML, sin estilos en línea).
5. Tablas legibles: cabecera verde oscuro o gris con texto claro, filas alternadas suaves, resalte al pasar el cursor, celdas con respiración, columnas de acciones alineadas.
6. Botones: primario sólido verde, secundario con borde, peligroso con rojo; el estado deshabilitado (el de "Gestionar fases") bien visible: gris, sin efecto de hover, cursor not-allowed y conservando la pista del estado.
7. Formularios: etiquetas claras, campos grandes y consistentes, foco visible, mensajes de error junto al campo o arriba, agrupación ordenada en dos columnas en pantallas anchas cuando convenga.
8. Seguimiento de las seis fases: conviértelo en un indicador de pasos conectado (una línea que une las seis casillas), con la fase actual en verde sólido y resaltada, y las demás en gris o blanco; en un proyecto finalizado, las seis aparecen completadas con una marca. Que se vea bien dentro del <details> desplegable y en pantallas estrechas (en vertical).
9. Pie de página discreto en verde muy oscuro, pegado al fondo cuando hay poco contenido.
10. Aterrizaje (index.jsp): conserva el contenido y mejora la presentación con un bloque principal en degradado de la paleta (sin la foto), tarjetas motivadoras y las seis fases con el mismo estilo del indicador. El botón "Sistemas TG" del banner debe seguir siendo claramente un botón.
11. Login (login.jsp): foto img\login-fondo.jpg como fondo de toda la ventana (cover, centrada, fija), con una capa oscura en degradado verde por encima para legibilidad y para disimular la baja resolución (y un leve desenfoque si la foto es pequeña), y la tarjeta del formulario centrada, semitransparente o blanca con sombra, con el título "Sistemas TG" y el subtítulo. El bloque de usuarios de prueba debajo, legible sobre el fondo. En esta página el encabezado puede ser transparente sobre la foto. La imagen se referencia desde el CSS con una ruta relativa que funcione bajo el contexto /sistemastg. Verifica con curl que la imagen responde 200 con image/jpeg y que el CSS la referencia correctamente.
12. Revisa una por una las páginas de los cuatro roles (admin, comité, docente, estudiante; listados, formularios, detalles, gestión de fases, páginas de error) y aplica los componentes anteriores de forma consistente. Entrega la lista de las páginas revisadas. Quita de las pantallas las referencias de desarrollo que se ven al usuario final y no aportan, como "(req. 49-53)" o "se habilita en el M4": primero dime cuáles son y cuántas, y no las quites sin mi confirmación si algún texto lo comprueban las pruebas; si las comprueban, déjalas.

VERIFICACIÓN
- 0 estilos, scripts y manejadores en línea (búsqueda en todos los .jsp y .jspf), 0 scriptlets, y ninguna referencia a recursos externos (http:// o https:// en CSS o HTML que cargue recursos).
- Todas las páginas siguen respondiendo igual por curl (la matriz de acceso de la suite M9 lo cubre) y las cabeceras de seguridad siguen presentes.
- Ejecuta C:\sistemastg-tests\run-all.ps1 completo: debe terminar con todas las suites en verde (la última corrida fue 1699 PASS y 0 FAIL) y el baseline idéntico al inicio y al final. Si alguna prueba falla por un cambio de clase o estructura, restaura esa clase (preferido) en vez de debilitar la prueba.
- Dime el peso de img\login-fondo.jpg y, si es muy pesada (más de 500 KB), propón una versión optimizada.

AL TERMINAR: anota en PLAN.md "M9-C rediseño visual" con lo hecho (paleta, archivos tocados y resultado de run-all.ps1), muestra la lista de archivos modificados y de páginas revisadas, y dile al usuario exactamente qué abrir en Chrome para revisarlo (con Ctrl + 0 para restablecer el zoom): login, aterrizaje, y el panel, un listado y un formulario de cada rol. No avances al M10. Espera mi confirmación y mis capturas para una segunda ronda de ajustes.
