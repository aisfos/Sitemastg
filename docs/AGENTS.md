# AGENTS.md — Sistemas TG (gestión del trabajo de grado)

Este archivo manda sobre cualquier otra instrucción. Léelo completo antes de escribir código y vuelve a él cuando dudes.

## 1. Qué se construye

Réplica simplificada del software institucional "Sistemas TG": gestión del trabajo de grado en seis fases, con cinco roles de inicio de sesión (Administrador, Comité, Docente, Estudiante) y los roles de proceso Director y Evaluador, que se asignan por proyecto.

Fuentes de verdad:
- `docs/sistemas_tg.sql` (~820 líneas): base ya diseñada (tablas, vistas, triggers, datos de ejemplo). Sus líneas 770–817 contienen los patrones de consulta canónicos. **No se modifica** (§11).
- `docs/requerimientos.md`: requerimientos numerados 1–97 (el encabezado dice 98, pero son 97). Cítalos por número (ej. "req. 38").
- `PLAN.md`: plan de módulos M1–M10 con trazabilidad de requerimientos.

Si algo contradice al SQL, detente y pregunta; no inventes.

## 2. Estado actual (verificado 2026-10-14)

M1–M8 parte A hechos; **M8 parte B (Docente) y M9–M10 por hacer.** La base `sistemas_tg` **ya está importada** y limpia (11 usuarios, 5 ideas, 0 proyectos/entregas/revisiones); la estructura está completa (`web.xml`, `css/`, `js/`, `WEB-INF/fragmentos/`, las cuatro carpetas por rol, `docs/`).

- El detalle por módulo (requerimientos, archivos y resultados de las pruebas) está en `PLAN.md`; **léelo antes de tocar nada**.
- Cada sesión ejecuta una *parte* de un módulo guiada por `docs/prompt-M<n>-opencode.md` (hoy el M8; los M6/M7 quedan como referencia) y termina con verificación `curl` y limpieza de los datos de prueba. Ese archivo es el contrato de la tarea.
- Falta M8-B: `docente/mis-proyectos.jsp` (o `proyectos.jsp`), `docente/gestionar-fase.jsp` y `docente/guardar-calificacion.jsp`; reutiliza `documentos-proyecto.jsp` y `seguimiento-fases.jsp`. En `menu.jsp`, el bloque del rol 3 tiene el marcador `M8: el Docente agrega aquí "Mis proyectos"`.
- M10 añadirá `META-INF/context.xml` y `Dockerfile` (**hoy no existen**).

## 3. Entorno (verificado; no re-comprobar)

| Dato | Valor |
|---|---|
| Contexto | `http://localhost:8080/sistemastg/` |
| Tomcat | 8.5.96 (XAMPP, `C:\xampp\tomcat`), puerto 8080, se arranca desde el panel de XAMPP |
| Java | JDK 25.0.2 (`C:\Program Files\Java\jdk-25.0.2`); `JAVA_HOME` y `CATALINA_HOME` **no** están definidos |
| BD | MariaDB 10.4.32, `localhost:3306`, `root` sin contraseña |

- `mysql` **no** está en PATH: usa `C:\xampp\mysql\bin\mysql.exe` o phpMyAdmin (`http://localhost/phpmyadmin`).
- Importar la base (¡destructivo: hace `DROP DATABASE`!), desde la raíz del proyecto:
  ```powershell
  Get-Content sistemas_tg.sql | & C:\xampp\mysql\bin\mysql.exe -u root
  ```
  PowerShell no admite `<`. El script usa `DELIMITER` (triggers): impórtalo por el cliente mysql o phpMyAdmin, **nunca por JDBC**.
- Los `.bat` de Tomcat necesitan `$env:CATALINA_HOME = "C:\xampp\tomcat"` primero.
- Tomcat recarga las JSP al instante; cambios en `web.xml` o `WEB-INF/lib` exigen reiniciar Tomcat. Si Jasper falla con `ClassNotFoundException: org.apache.jsp.<Pagina>_jsp` o "instancia de aplicación web ya ha sido detenida" tras renombrar una página, borra `C:\xampp\tomcat\work\Catalina\localhost\sistemastg`.
- Logs: `C:\xampp\tomcat\logs\catalina.<yyyy-MM-dd>.log`.

## 4. Stack y reglas duras (no negociables)

- JSP + JSTL 1.2 + JDBC mediante las etiquetas `sql:` de JSTL. URIs de JSTL 1.2: `http://java.sun.com/jsp/jstl/core|fmt|sql|functions` (nunca `jakarta.tags.*`, que es JSTL 2.x de Tomcat 10+).
- JavaScript solo del lado del cliente. Sin Node.js.
- PROHIBIDO: scriptlets (`<% ... %>`, `<%= %>`, `<%! %>`), Maven, Gradle, frameworks y Servlets. Las directivas `<%@ page %>`, `<%@ taglib %>` e `<%@ include %>` sí están permitidas.
- Única excepción: la página de aterrizaje puede ser un Servlet (una clase `.java` compilada con `javac`). Por defecto hazla como JSP; solo usa servlet si te lo pido.
- SÍ se usan fragmentos reutilizables (req. 12): encabezado, pie, menú por rol, guardia de sesión y conexión. Viven en `WEB-INF/fragmentos/` como `.jsp` y se incluyen de forma estática con `<%@ include file="/WEB-INF/fragmentos/..." %>`. **No crees archivos `.jspf`**: todos los fragmentos son `.jsp` (así lo aplica el prelude de `web.xml`, que solo mira `*.jsp`).
- Sin dependencias externas de runtime: CSS/JS propios en `css/` y `js/` (sin CDN salvo que lo apruebe). Cada página lleva `contentType="text/html; charset=UTF-8"`.
- Trampas JSP/EL ya diagnosticadas en el proyecto hermano `../JSTLejercicios2` (misma pila; ver también su `AGENTS.md`): `${...}` en texto de plantilla siempre se evalúa; en EL `+` es aritmético, no concatena; `c:redirect` debe ir antes de emitir HTML; `fn:match` **no existe** en este JAR (valida prefijos URL con `fn:startsWith`); en `sql:update` el SQL no lleva `;` final.

## 5. Estructura de carpetas y rutas

El proyecto vive directamente en `C:\xampp\tomcat\webapps\sistemastg`: esa carpeta ES la raíz del contexto (`/sistemastg`); no hay subcarpeta `webapp/`.

```
sistemastg/                 = raíz del contexto /sistemastg (no hay META-INF/ ni Dockerfile aún)
  AGENTS.md, PLAN.md
  docs/                      requerimientos.md, sistemas_tg.sql, prompt-M{6,7,8}-opencode.md
                             (docs/ se bloquea o saca del contexto en M10)
  index.jsp, login.jsp, logout.jsp, error.jsp
  css/estilo.css   js/       (login, usuario-form, confirmar, url-valida, revision-fase1)
  admin/  comite/  docente/  estudiante/    (una carpeta por rol)
  WEB-INF/
    web.xml
    lib/                     jstl-1.2.jar, mysql-connector-j-8.0.33.jar
    fragmentos/              conexion, taglibs, encabezado, pie, menu, guardia,
                             error-bd, url-valida, seguimiento-fases, documentos-proyecto
  META-INF/context.xml       (M10)
  Dockerfile                 (M10)
```

- Todos los enlaces, redirecciones y recursos usan `${pageContext.request.contextPath}` (o `c:url`), nunca rutas absolutas como `/login.jsp`.
- Tomcat distingue mayúsculas aunque Windows no: `Index.jsp` y `index.jsp` son el mismo archivo en disco pero URLs distintas. Nombra cada archivo exactamente como lo enlazas.

## 6. Catálogos y datos de prueba (del SQL)

Usuarios de prueba (id — rol — contraseña): 1 Administrador `admin123`; 2 Comité `comite123`; 3–6 Docente `docente123`; 7–11 Estudiante `estudiante123`.

- `id_rol`: 1 Administrador, 2 Comité, 3 Docente, 4 Estudiante.
- `id_rol_proceso`: 1 Estudiante, 2 Director, 3 Evaluador, 4 Comité.
- Fases: 1 Idea y pago, 2 Propuesta I, 3 Propuesta II, 4 Informe I, 5 Informe II, 6 Cierre.
- `entrega.tipo`: IDEA, SOPORTE_PAGO, PROPUESTA, INFORME, MANUAL_USUARIO, MANUAL_TECNICO, REPOSITORIO.
- `revision.resultado` es ENUM('APROBADO','APLAZADO') y un CHECK exige `id_rol_proceso IN (2,3,4)`: solo Director, Evaluador o Comité califican.
- CHECKs de `proyecto` a tener en cuenta: evaluador ≠ director; pasar de la fase 1 exige director y evaluador asignados; finalizar exige radicado.

## 7. Reglas de seguridad y acceso

1. Toda consulta con parámetros usa `<sql:param>` o `<sql:dateParam>`. NUNCA concatenes entradas del usuario en el SQL.
2. Cada página protegida declara `<c:set var="rolRequerido" value="N"/>` y luego incluye el único `/WEB-INF/fragmentos/guardia.jsp` (valida sesión y rol con `c:if` y `c:redirect` y envía `Cache-Control: no-store`; req. 38, 20e). Ocultar opciones del menú NO basta.
3. Ante falta de sesión o de permiso, redirige con un mensaje claro (req. 20e).
4. Toda salida de texto del usuario o de la BD va con `<c:out>` (o `fn:escapeXml`) para evitar XSS.
5. El estudiante consulta SOLO la vista `v_proyecto_estudiante`, nunca `v_proyecto`: no puede ver al evaluador (req. 95).
6. Un proyecto solo lo ve el estudiante 1. Toda consulta del estudiante filtra por `id_estudiante1 = usuario en sesión`. Si el estudiante 2 abre el id a mano, mensaje de "sin permiso" (req. 97).
7. Claves en texto plano y **visibles en la lista de usuarios de prueba** (`login.jsp`, bloque desplegable): es una limitación aceptada (req. 36, 39). No agregues hashing.
8. Los enlaces (idea, pago, propuesta, informe, anexos) se guardan como URL y se validan con formato `http://` o `https://` antes de insertar (req. 17, 20d). Se muestran como enlaces clicables con `target="_blank"` y `rel="noopener"`. (La BD también lo exige: CHECK en `entrega.url`.)

## 8. Lógica del proceso: vive en la base de datos

El SQL ya implementa el flujo con tablas `fase`, `fase_rol`, `transicion_fase` y triggers (patrones canónicos comentados en el propio script, líneas 770–817). Por eso:

- Para calificar, las JSP solo hacen `INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado)`. Los triggers validan turno, revisor, acta y radicado, y cambian solos la fase y el turno. NO dupliques esas reglas en las JSP ni actualices `id_fase`/`id_rol_proceso` a mano al calificar.
- `acta_numero` va solo en la fase 1 (comité) y `radicado` solo al aprobar el cierre en la fase 6; en las demás fases van NULL.
- Para que el estudiante envíe a revisión: consulta `transicion_fase` con acción `ENVIAR` y luego `UPDATE proyecto SET id_fase = ?, id_rol_proceso = ?`.
- Las inserciones en `proyecto` y `entrega` deben enviar siempre las columnas NOT NULL sin default (los triggers las reemplazan), como indica el comentario del script.
- Envuelve cada operación que pueda fallar en `<c:catch var="err">` y muestra `err.cause.message` tal cual: los mensajes de los triggers (SQLSTATE 45000) están pensados para mostrarse al usuario (req. 18, 20).
- Para varias sentencias que deben ir juntas usa `<sql:transaction>`.
- Eliminar usuario con proyectos o ideas: captura el error de llave foránea (1451) y muestra "No se puede eliminar un usuario que tiene proyectos asociados" (req. 20g, 46).

## 9. Reglas de comportamiento de la interfaz

- Estado del proyecto siempre con el formato `Fase N | Rol` o `Finalizado` (req. 2).
- Calificación solo `Aprobado` o `Aplazado`, siempre con comentarios (req. 4). Nunca "rechazado", "desaprobado" ni "sin revisar".
- Seguimiento de las seis fases en un fragmento reutilizable: fase actual en verde, las demás en gris o blanco (req. 6, 7). Visible para Administrador, Comité, Director y Evaluador aunque no sea su turno.
- Botón "Gestionar fases" (req. 8): solo Comité, Director y Evaluador. Habilitado únicamente si `finalizado = 0` y `rol_turno` coincide con su rol en ese proyecto; deshabilitado en cualquier otro caso. Administrador y Estudiante no lo tienen. Además de deshabilitarlo, la página de gestión valida el turno en el servidor.
- Docente: vista única "Mis proyectos" con columna "Mi rol" (Director o Evaluador). Sin pestañas, secciones desplegables ni menús separados (req. 76).
- Evaluador distinto del director: las listas de evaluadores excluyen al director del proyecto (req. 9, 58, 63).
- Cada rol ve solo su menú y solo sus registros (req. 18, 35).
- Mensajes claros de error en todos los casos del req. 20 (a–i).
- Cierre de sesión que funcione en todos los roles (req. 37): invalida la sesión y redirige al login.
- Página de aterrizaje con mensajes motivadores y botón "Sistemas TG" en el banner superior (req. 32, 33). Lista o botón de usuarios de prueba y sus claves (req. 36).
- Diseño responsive y limpio, con CSS único compartido. Texto de la interfaz en español.

## 10. Conexión a base de datos

- Un solo fragmento `conexion.jsp` define el origen de datos; ninguna otra página escribe credenciales.
- Local: `jdbc:mysql://localhost:3306/sistemas_tg` con `root` sin contraseña.
- En la nube (Render + base MySQL en Aiven) las credenciales llegan por variables de entorno, no hardcodeadas. El mecanismo ya verificado está en `../JSTLejercicios2` (detallado en su `AGENTS.md`): `META-INF/context.xml` con un `<Resource>` (driver `com.mysql.cj.jdbc.Driver`) cuyo `url`/`username`/`password` salen de `DB_URL`, `DB_USER`, `DB_PASS` con `${VAR:-default}` locales; el `Dockerfile` activa el `EnvironmentPropertySource` con un `-D` en `JAVA_OPTS`. Reutilízalo; si no estuviera disponible, propón la opción (por ejemplo, DataSource JNDI) antes de implementarla.
- Deja `conexion.jsp` como único punto de cambio desde el inicio.

## 11. Forma de trabajar

- Trabaja un módulo a la vez, en el orden de `PLAN.md`. No avances al siguiente sin que el actual compile, despliegue y se haya probado.
- Antes de cada módulo, lista los requerimientos que cubre (por número) y los archivos que vas a crear.
- Al terminar un módulo: marca su casilla en `PLAN.md`, anota qué probaste y qué falta. No marques como hecho lo que no probaste.
- No modifiques `docs/sistemas_tg.sql` por tu cuenta. Si crees que hace falta un cambio, propónlo con el motivo y espera mi confirmación.
- Cambios mínimos: no refactorices ni renombres archivos de módulos ya cerrados sin pedírmelo.
- Si un requerimiento es ambiguo o hay conflicto, pregunta; no asumas en silencio.
- No crees archivos de documentación extra (README largos, guías) salvo que los pida.

## 12. Definición de "terminado" para un módulo

1. Las páginas abren sin errores en Tomcat 8.5.96.
2. Cada página con acceso restringido rechaza sesión ausente y rol equivocado (probado escribiendo la URL a mano).
3. Los casos de error aplicables del req. 20 muestran su mensaje.
4. No hay scriptlets ni SQL concatenado (búsqueda rápida: `<%` que no sea `<%@`, y `+` o `${}` dentro de sentencias SQL).
5. `PLAN.md` actualizado.

## 13. Convenciones de código

- Sesión: `sessionScope.usuarioId`, `sessionScope.usuarioNombre`, `sessionScope.rolId` (1 Administrador, 2 Comité, 3 Docente, 4 Estudiante) y `sessionScope.rolNombre`.
- Mensajes entre páginas (una sola vez, patrón redirigir-después-de-enviar): `sessionScope.flashError` y `sessionScope.flashOk`; `encabezado.jsp` los muestra con `<c:out>` y luego los borra con `<c:remove>`.
- Preludio de taglibs: `web.xml` aplica `/WEB-INF/fragmentos/taglibs.jsp` (include-prelude) a todo `*.jsp`; los fragmentos reutilizables NO declaran taglibs (usan los de la página que los incluye).
- **JDBC URL en atributos JSP: `&` crudo, NO `&amp;`**. En sintaxis JSP estándar el contenedor NO desescapa entidades: `&amp;` llega literal al driver y rompe la URL (`WrongArgumentException: Malformed database URL`). `&amp;` solo en archivos XML (`context.xml`, `web.xml`).
- **Trampa M4: entidades en atributos JSP.** Dentro de un atributo (por ejemplo `sql="..."`) las entidades como `&lt;` y `&gt;` NO se decodifican: llegan literales al driver y dan `SQLSyntaxErrorException`. Escribe el comparador con el carácter literal (`=`, `<>`, `!=`), nunca como entidad.
- **MySQL convierte cadenas a entero con criterio laxo** ("13 OR 1=1" → 13). Antes de usar un id que llega por parámetro, valídalo numéricamente (`<c:catch>` + `${id + 0}`), como en `admin/guardar-usuario.jsp` y `admin/eliminar-usuario.jsp`.
- **Los alias `AS` de `sql:query` sí funcionan**: la URL JDBC lleva `useOldAliasMetadataBehavior=true`, así `SELECT r.nombre AS rol_nombre` deja la columna accesible como `${fila.rol_nombre}` (verificado en M4). Sin ese parámetro, la clave de la fila es el nombre real de la columna y el alias se pierde.
- Mensajes de triggers (SQLSTATE 45000): mostrar **`${err.cause.message}`** (verificado en M2: sale el mensaje limpio, ej. "El proyecto no existe"). `${err.message}` incluye el prefijo con el SQL y no se debe mostrar.
- `error.jsp` NO muestra detalles técnicos (mensaje de excepción, SQL, nombres de tablas): el detalle queda solo en el log de Tomcat. (Dato: el objeto de excepción en EL es `${pageContext.exception}`, no `exception`.)
- **Errores de BD: nunca `err.message` ni mensajes crudos.** Tras `<c:catch var="err">` incluye `/WEB-INF/fragmentos/error-bd.jsp` (a nivel de página); deja el mensaje en `mensajeBd` (mostrar con `<c:out>`). Reglas: `err.cause.SQLState == '45000'` → `${err.cause.message}` (triggers); `err.cause.errorCode == 1451` → mensaje propio del módulo en `mensajeAsociados` (si falta: "…tiene datos asociados", req. 20g); `err.cause.errorCode == 1062` → mensaje propio del módulo en `mensajeDuplicado` (por defecto "El número de documento ya está registrado", req. 20c); cualquier otro → "Ocurrió un error inesperado. Intenta de nuevo." (el detalle va al log con `servletContext.log(err.message)`, nunca a pantalla).
- **`proyecto.finalizado` y `v_proyecto.finalizado` (TINYINT(1)) llegan a EL como Boolean, no como número** (hallazgo del M6): compara con la verdad del valor (`${not ...finalizado}`, `${...finalizado}` o `== false`), nunca con `${...finalizado == 0}`, que lanza `ELException` y responde 500.
- Todo recurso y enlace con `${pageContext.request.contextPath}` (o `c:url`).
- **M9-D parte B — "Tu turno" en listados.** La fila cuyo botón de acción está habilitado se marca con `<span class="pastilla-turno"><svg…/><use …#i-reloj/></svg>Tu turno</span>` dentro de `.acciones`; el resaltado de la fila lo da el CSS con `.tabla tbody tr:has(.pastilla-turno)` (borde izquierdo ámbar). Texto exacto de la píldora: **"Tu turno"** (los paneles usan "Es tu turno" en `.contador-estado`, que es otra cosa). No se toca el atributo `disabled` ni la regla de turno.
- **M9-D parte B — contadores de panel.** Tarjeta `.tarjeta-contador` con `data-contador="<nombre>"` y `.contador-numero`; ámbar con `.tarjeta-contador-pendiente` cuando hay pendientes y neutra con `.tarjeta-contador-al-dia` ("Todo al día"). Son consultas de solo lectura con `sql:param`; cada rol ve solo lo suyo y el estudiante solo `v_proyecto_estudiante`.
- **M9-D parte B — formularios.** Secciones con `<fieldset class="formulario-seccion">` + `<legend class="formulario-seccion-titulo">`; ayuda bajo el campo con `.ayuda`; acciones en `<p class="formulario-acciones">`; mensajes junto al campo con `.campo-mensaje-error` (textos del servidor sin cambios).
- **M9-D parte B — estados y detalle.** Estados vacíos con `.vacio` + `<svg class="vacio-ilustracion"><use …#i-vacio/>` y `.vacio-acciones`; `error.jsp` usa el estilo de página de estado `.pagina-estado` (la falta de permiso es un `flashError` + redirección de `guardia.jsp`, no una página). Observaciones como `.linea-tiempo` (`li.linea-tiempo-aplazado` para Aplazado) en `estudiante/proyecto.jsp` y `documentos-proyecto.jsp`; estado en `.insignia-grande`.
- **M9-D parte B — sprite.** Iconos añadidos: `i-vacio` (`viewBox="0 0 48 34"`, el resto 24) e `i-diploma` (26 `<symbol>` en total en `img/iconos.svg`).
- **M9-D parte B — pruebas.** `C:\sistemastg-tests\m9d-tests.ps1` (UTF-8 con BOM, `-BaseUrl`/`-MysqlPath`) siembra `datos_demo.sql` y **siempre** limpia con `quitar_demo.sql` en un `finally`; está registrada en `run-all.ps1` como suite `M9D`.
- **M9-E parte B — aterrizaje autocontenido (`index.jsp`).** La portada es una página propia: encabezado `<header class="banner aterrizaje-cabecera" data-menu-movil>` (transparente sobre el bloque principal y sólido al desplazarse) y pie propio (`.aterrizaje-pie`, **con enlaces**). **No** incluye `pie.jsp` ni `app.js` desde el pie: carga `js/app.js` y `js/aterrizaje.js` con `<script src="${ctx}/js/…" defer>` (el menú móvil y la cabecera con `.banner-scroll` los aporta `app.js`; lo exclusivo, `aterrizaje.js`). Marca y enlaces con `${pageContext.request.contextPath}`.
- **M9-E parte B — clases nuevas solo del aterrizaje.** `body.aterrizaje`; `.aterrizaje-cabecera`, `.aterrizaje-hero` (foto `login-fondo.jpg` con degradado 115° y recorte distinto al login), `.aterrizaje-senal`, `.aterrizaje-cifras`/`.cifra`/`.cifra-numero`/`.cifra-etiqueta`/`.cifra-fija`, `.aterrizaje-seccion`(`-alterna`), `.aterrizaje-ceja`, `.aterrizaje-titulo`, `.aterrizaje-entrada`, `.recorrido`/`.recorrido-fase`/`.recorrido-numero`/`.recorrido-datos`/`.recorrido-icono`/`.recorrido-nombre`/`.recorrido-roles`/`.recorrido-desc`, `.chip`, `.roles`/`.rol-card`/`.rol-icono`/`.rol-titulo`/`.rol-texto`, `.carrusel`/`.carrusel-pista`/`.carrusel-item`/`.carrusel-frase`/`.carrusel-puntos`/`.carrusel-punto`, `.acordeon`/`.acordeon-item`/`.acordeon-pregunta`/`.acordeon-respuesta`, `.aterrizaje-cta`, `.aterrizaje-pie`, `.revelar`/`.revelar-visible`, `.boton-grande`, `.boton-sobre-foto`. Sin acentos en el CSS (0 bytes no ASCII).
- **M9-E parte B — recorrido de las seis fases.** `.recorrido` es un recorrido **horizontal conectado** (`grid-template-columns: repeat(6, 1fr)`, `gap: 0`): cada `.recorrido-fase::before` dibuja su tramo de línea y el círculo del número (`.recorrido-numero`, `z-index: 1`) lo tapa; `:first-child`/`:last-child` recortan el tramo a su centro. Por debajo de **1024px** se vuelve vertical (`grid-template-columns: 44px 1fr`, línea a `left: 21px`). Los nombres y descripciones de las fases no cambian.
- **M9-E parte B — franja de cifras.** Tres consultas agregadas de solo lectura (`v_idea_docente` estado `APROBADA` + `DISPONIBLE` + `NOT EXISTS` en `proyecto`; `proyecto WHERE finalizado = 0`; `finalizado = 1`) dentro de `<c:catch var="errCifras">`, más «6 fases» y «4 roles» fijas. La franja va dentro de `<c:if test="${empty errCifras}">`: si la base falla, se oculta y el aterrizaje responde 200 igual. Cada número lleva `data-cifra-final` con el valor del servidor (visible sin JS).
- **M9-E parte B — mejora progresiva (`js/aterrizaje.js`).** IIFE sin globales, cargado solo en `index.jsp`: `[data-progreso]` es un `<progress>` (se fija con `.value`, **sin** estilos en línea: inmune a la CSP), `[data-cifras]` anima los `[data-cifra-final]`, `[data-revelar]` revela al desplazarse, `[data-carrusel]` crea los puntos y rota cada 6 s (pausa al pasar el ratón o enfocar; flechas ← →), `[data-acordeon]` cierra los hermanos. Con `prefers-reduced-motion` (o sin JS) se ven **todos** los mensajes en lista, los números con su valor final y el acordeón `<details>` nativo.
- **M9-E parte B — pruebas.** `C:\sistemastg-tests\m9e-tests.ps1` (UTF-8 con BOM, `-BaseUrl`/`-MysqlPath`) comprueba el aterrizaje por HTTP (200 con y sin sesión, cabeceras de seguridad, cero recursos externos, cero estilos/scripts/manejadores en línea), los textos conservados, las cifras contra SQL (baseline y con `datos_demo.sql`), el patrón `c:catch` (origen + una JSP temporal de prueba) y `node --check` de `js/aterrizaje.js`; siembra la demo y **siempre** la quita con `quitar_demo.sql` en un `finally`. Registrada en `run-all.ps1` como suite `M9E`. **El volcado canónico de `idea_docente` se mide forzando la codificación de consola 437** alrededor del `mysql` (igual que `run-all.ps1` y `guion-verificado.ps1`): con UTF-8 el SHA-256 cambia (bytes 1545 ≠ 1524); `$script:log.Add(...)` siempre con `$null =` para no emitir el índice.
- **Aislamiento entre suites (M9-E parte B; corregido el 2026-10-17).** `run-all.ps1` es la única autoridad del estado de la base entre suites y, antes de **cada** una: (1) hace un `Reset-Baseline` **determinista** — reimporta `docs/sistemas_tg.sql` con `cmd /c mysql --default-character-set=utf8mb4 < archivo` (nunca por JDBC) y aplica `baseline-fechas.sql`, que devuelve a `idea_docente` las fechas canónicas 2026-10-12 10:51:14 (el SQL las deja en `NOW()`) —; (2) borra **todos** los artefactos de sesión (`*_ck_*.txt`, `*_jar_*.txt`, `m9d_*.txt`, `m9e_*.txt`, `m3_*.txt`…`m9_*.txt`); (3) comprueba el baseline (11/5/0/0/0, `AUTO_INCREMENT` 12/6/1/1/1 y SHA-256 **completo** del volcado de `idea_docente` medido con la consola en 437); y (4) aplica el escenario de la suite si lo declara (M6A `m6a_seed.sql`, M6B `m6b_seed.sql`) **después** de verificar el baseline. Vuelve a comprobar el baseline después de cada suite y registra «deja la base sucia: X» cuando la suite deja datos (M5, M6A, M6B, M7A, M7B, M7C, M8A, M8B); el reset determinista los limpia antes de la siguiente. Sale 0 solo si **todas** dan 0 FAIL, el baseline final es OK y los guiones pasan la comprobación de integridad; escribe `run-all_summary.log` y un `run-all_<suite>.log` por suite.
- **Ninguna suite reutiliza cookies de corridas anteriores.** Guardar los ficheros de cookies (`*_ck_*.txt`, `*_jar_*.txt`) y volver a usarlos produce **falsos fallos** en cuanto Tomcat reinicia (borra las sesiones en memoria): la suite se salta los `login` y consulta páginas protegidas con sesiones muertas (302 al login). Es la causa real de los **57 falsos fallos de M9D** del 2026-10-16, y también de los fallos de M5/M6A/M6B con cookies viejas. `m9d-tests.ps1` borra sus `m9d_ck_*.txt` al empezar y otra vez en el `finally`.
- **Integridad de los guiones de prueba.** Después de escribir o editar un guion de `C:\sistemastg-tests`, comprobar que no quedó vacío ni truncado: **más de 1 KB** y **BOM al inicio** (`EF BB BF`) en los `.ps1`; los `.sql` también pueden llevar BOM (el cliente `mysql` lo tolera; verificado), pero no es obligatorio. Si el guion es PowerShell, validar además la sintaxis con `[System.Management.Automation.Language.Parser]::ParseFile`. `run-all.ps1` lo verifica de cada suite antes de ejecutarla.
- **Los recuentos esperados por suite son la referencia; no se debilitan aserciones.** `run-all.ps1` compara cada resultado con el esperado (M3 45, M4 79, M5 62, M6A 82, M6B 94, M7A 152, M7B 104, M7C 65, M8A 92, M8B 130, M9 705, M9B 89, M9D 477, M9E 99 = **2275**) e imprime `esperado N` o `NUMERO DISTINTO`. Un número distinto se explica con evidencia, no se ajusta la prueba: así se estableció que M9D son **477** y no 456 (la corrida con cookies viejas se saltaba 21 `login` de demostración).
- **M9-E parte C — avatares (`/WEB-INF/fragmentos/avatar.jsp`).** Dibuja las iniciales en un `<span class="avatar avatar-N" aria-hidden="true">` (paleta `avatar-1`…`avatar-8` según `(id % 8) + 1`). La página que lo incluye define **`avatarId`** y **`avatarNombre`** y luego `<%@ include file="/WEB-INF/fragmentos/avatar.jsp" %>`. Va **dentro de un `<td>` existente** (clase `.celda-persona` = avatar + nombre), nunca en la celda del id (índice 0), para no desplazar los `Cells[]` de las pruebas (`RowOf`/`Cells[0]`). Sin id o sin nombre no se pinta avatar: las ramas "—" y "Por asignar" van sin él, y las páginas del estudiante no usan avatar (no debe ver director/evaluador, req. 95). Humano: 8 páginas de listado + `encabezado.jsp`.
- **M9-E parte C — insignias del menú (`menu.jsp`).** Contadores de solo lectura por rol en `c:set` (`insComIdeasDoc`, `insComIdeasEst`, `insComProy`, `insDocProy`, `insEstProy`) que se pintan como `<span class="menu-insignia" data-insignia="…">N</span>` **hermano** del enlace: el texto del enlace NO cambia (req. 76). Con 0 pendientes se añade `menu-insignia-cero` (oculta) y con pendientes queda ámbar. Claves `data-insignia`: `comite-ideas-docentes`, `comite-ideas-estudiantes`, `comite-proyectos`, `docente-proyectos`, `estudiante-proyectos`.
- **M9-E parte C — tema claro/oscuro (`js/tema.js`).** Un único IIFE sin globales, cargado **sin `defer`** en el `<head>` de las 29 páginas HTML, entre el favicon y la hoja de estilos (fija `<html data-tema="…">` antes de pintar: sin parpadeo). Orden: preferencia guardada (`localStorage`, clave `sistemas-tg-tema`, en try/catch) → `prefers-color-scheme` → claro. El botón `[data-tema-boton]` (en `encabezado.jsp`; también en la cabecera de `index.jsp`) alterna el atributo y `aria-pressed`. Todo vive dentro de `[data-tema="oscuro"]` en el CSS y todos los pares texto/fondo del modo oscuro cumplen contraste ≥ 4.5:1.
- **M9-E parte C — acabado (C6).** Patrón decorativo `img/patron.svg` en `.banner` y en `.aterrizaje-cta`; `--elev-1` con verde suave; transición de entrada de página `paginaEntra`; estados vacíos con `<img class="vacio-ilustracion" src="…/img/vacio.svg" alt="" aria-hidden="true" width="156" height="104">` (10 páginas); favicon `img/favicon.svg` en las 29 páginas. Se conserva la CSP `default-src 'self'`: cero recursos externos y cero estilos/scripts/manejadores en línea.
- **M9-E parte C — pruebas.** `m9e-tests.ps1` pasó de 63 a **99** comprobaciones (secciones nuevas 4b, 6 y 7: avatares, insignias, tema y acabado) y `run-all.ps1` usa `Esperado = 99`. Regresión completa: **2275 PASS / 0 FAIL**, baseline intacto.
- **M9-E parte C — C1: gráficos SVG de solo lectura (paneles y anillo).** El Administrador muestra un donut de proyectos en curso/finalizados y barras de "Proyectos por fase" y "Usuarios por rol"; el Comité, barras de "Ideas del banco por estado" y "Proyectos por fase"; el Docente, barras de "Mis proyectos por fase" y "Mis proyectos por rol"; y el Estudiante, un **anillo de progreso** "Fase N de 6" por proyecto. Fragmentos reutilizables: `grafico-barras.jsp` (contrato: `barrasId`, `barrasTitulo`, `barrasColEtiqueta`, `barrasColValor`, `barrasRows`, `barrasTotal`) y `grafico-anillo.jsp` (`anilloId`, `anilloFase`, `anilloPct`, `anilloEtiqueta`); el donut queda en línea en `admin/panel.jsp`. **Reglas:** el SVG usa SOLO atributos de presentación (`x`, `y`, `width`, `height`, `rx`, `font-size`, `stroke-dasharray`, `stroke-dashoffset`) y los colores salen de clases CSS (0 `style="…"`); los porcentajes los calcula la base (`ROUND(n*100.0/GREATEST(MAX(n) OVER (),1))`; el anillo, `ROUND((CASE WHEN finalizado=1 THEN 6 ELSE id_fase END)*100.0/6)`) porque en EL `/` es división entera; cada gráfico lleva una **tabla oculta** (`.solo-lectores`) con `data-etiqueta`/`data-valor` como alternativa de texto, `role="img"` + `aria-label` en el SVG y estado vacío (`grafico-vacio`, sin SVG) cuando no hay datos. El Estudiante usa solo `v_proyecto_estudiante` (nunca ve al evaluador, req. 95).
- **M9-E parte C — C3: tarjeta de celebración (`celebracion.jsp`).** `data-celebracion="finalizado"` en el panel del Estudiante (`estudiante/panel.jsp`) y en el detalle (`estudiante/proyecto.jsp`), SOLO si `finalizado` es verdadero; conserva el texto **"Trabajo de grado finalizado"** y el radicado. Contiene un check SVG animado (`celebracion-check-circulo`/`celebracion-check-trazo`) y 12 `<span class="confeti confeti-N">` de confeti **solo CSS**. Con `@media (prefers-reduced-motion: reduce)` se desactiva la animación y el check se ve completo (`stroke-dashoffset: 0`); el bloque de C3 empieza por `.celebracion-check-circulo`. **Nunca** aparece en un proyecto no finalizado.
- **M9-E parte C — atributos de datos para las pruebas.** Los gráficos usan `data-grafico` (id), `data-etiqueta`/`data-valor` (filas de la tabla oculta), `data-anillo`/`data-fase`/`data-pct` (anillo) y `data-celebracion`; **no** `data-contador` (lo parsea `m9d-tests.ps1`). Clases CSS nuevas: `.solo-lectores` (visualmente oculta), `.rejilla-graficos`, `.grafico*`, `.donut*`, `.anillo*`, `.celebracion*`, `.confeti*` y `@keyframes celebracionCirculo`/`celebracionTrazo`/`confetiCae`; el CSS sigue siendo solo ASCII.
- **M9-E parte C — pruebas (C1 y C3).** `m9e-tests.ps1` pasa de 99 a **231** comprobaciones: sección **4c** (C1 en baseline: valores contra SQL y estado vacío de los 4 paneles; reutiliza la sesión de admin y crea comité/docente/estudiante), sección **9** (C1 con la demo: los 3 paneles y el anillo del Estudiante contra SQL, reutilizando las sesiones de 4c) y sección **10** (C3: tarjeta en panel y detalle del proyecto finalizado, radicado vs base, check SVG, 12 confetis, sin estilos/scripts en línea, ausente en no finalizado, y CSS/fragmentos). `run-all.ps1` usa `Esperado = 231`. Regresión completa: **2407 PASS / 0 FAIL**, baseline intacto.
- **Tema claro/oscuro — arranque SIEMPRE claro (auditoría 2026-10-18).** `js/tema.js` **no** consulta la preferencia del sistema: prohibido `prefers-color-scheme` y `matchMedia`. Orden del valor inicial: la preferencia guardada en `localStorage` (clave `sistemas-tg-tema`, siempre en try/catch) → **claro**. El oscuro solo se activa al pulsar `[data-tema-boton]` y se persiste; un usuario sin elección guardada siempre entra en claro.
- **CSS "solo tokens" (auditoría 2026-10-18).** En `css/estilo.css` **ningún color literal** (hex `#rgb`/`#rrggbb`, `rgb()`, `rgba()`, `hsl()`, `hsla()` ni nombres de color) fuera de los bloques de tokens: el primer `:root` y el bloque `[data-tema="oscuro"] { … }`. Solo se admiten `transparent`, `currentColor` e `inherit`. Cada token nuevo se declara con valor claro **y** su vuelta en `[data-tema="oscuro"]`; las reglas `[data-tema="oscuro"] .selector { … }` NO son bloque de tokens. No uses un tono de la paleta que no voletee como fondo o texto (crea el token semántico equivalente), y evita `var(--x)` sin definir. Al tocar colores, revisa el componente en **ambos** temas.
- **Tema — el login es su propia superficie.** `body.login-fondo .tarjeta`, `.entrada`, `.seleccion`, `.tarjeta-prueba` y el pie usan los tokens `--login-*` (no los genéricos `--texto`/`--superficie`): claro = tarjeta blanca con texto oscuro; oscuro = tarjeta oscura semitransparente (`rgba(23,30,26,.94)`) con texto claro y campos oscuros con borde visible. El error fue un `rgba(255,255,255,.97)` literal en `body.login-fondo .tarjeta` con `--texto` volteado a claro: cualquier componente nuevo sobre la foto del login necesita token propio y comprobarse en los dos temas.
- **Pruebas de tema.** `m9e-tests.ps1` sección **4d** (+50): (a) 0 colores literales fuera de los tokens, (b) `js/tema.js` sin `prefers-color-scheme` y arrancando en claro, y (c) contraste **>= 4.5:1 en ambos temas** para 23 pares reales de tokens (46 comprobaciones; el `rgba()` de la tarjeta del login se compone sobre `--c-verde-900`). `run-all.ps1` usa `Esperado = 281`. Regresión completa: **2457 PASS / 0 FAIL**, baseline intacto. Al añadir tokens o reglas de color, amplía la lista de pares de 4d (no se debilitan aserciones).
