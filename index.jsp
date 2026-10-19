<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="/WEB-INF/fragmentos/conexion.jsp" %>
<%--
  index.jsp - Pagina de aterrizaje (req. 32, 33).
  Publica: responde 200 con o sin sesion. Conserva los textos y enlaces que
  comprueba la demostracion verificada: el titulo "Sistemas TG", la frase
  "Estudiante, es tu oportunidad para desarrollar el mejor proyecto y destacar.",
  el boton "Sistemas TG" que lleva a login.jsp y las seis fases con su nombre.

  Las cifras de la franja son consultas de solo lectura (agregadas, sin datos
  personales) envueltas en c:catch: si la base de datos falla, la franja se
  oculta y la pagina se ve igual. Sin JavaScript la pagina se ve completa y
  usable (cifras con su valor final, carrusel como lista y acordeon nativo).
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:catch var="errCifras">
  <sql:query var="qIdeasBanco" dataSource="${db}"
             sql="SELECT COUNT(*) AS n FROM v_idea_docente v
                  WHERE v.estado = 'APROBADA' AND v.disponibilidad = 'DISPONIBLE'
                    AND NOT EXISTS (SELECT 1 FROM proyecto p WHERE p.id_idea_docente = v.id_idea_docente)"/>
  <sql:query var="qEnCurso" dataSource="${db}"
             sql="SELECT COUNT(*) AS n FROM proyecto WHERE finalizado = 0"/>
  <sql:query var="qFinalizados" dataSource="${db}"
             sql="SELECT COUNT(*) AS n FROM proyecto WHERE finalizado = 1"/>
</c:catch>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sistemas TG — Gestión del trabajo de grado</title>
  <link rel="icon" type="image/svg+xml" href="${ctx}/img/favicon.svg">
  <script src="${ctx}/js/tema.js"></script>
  <link rel="stylesheet" href="${ctx}/css/estilo.css">
</head>
<body class="aterrizaje">
  <progress class="barra-progreso" data-progreso max="100" value="0" aria-hidden="true"></progress>

  <header class="banner aterrizaje-cabecera" data-menu-movil>
    <div class="contenedor aterrizaje-cabecera-fila">
      <a class="aterrizaje-marca" href="${ctx}/index.jsp">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-inicio"/></svg>
        <span class="aterrizaje-marca-texto">Sistemas TG</span>
      </a>

      <button type="button" class="menu-boton" data-menu-boton aria-controls="aterrizaje-secciones" aria-expanded="false">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-menu"/></svg>
        Menú
      </button>

      <nav class="aterrizaje-nav" aria-label="Secciones de la página">
        <ul class="menu-lista aterrizaje-enlaces" id="aterrizaje-secciones">
          <li><a class="menu-enlace" href="#como-funciona">Cómo funciona</a></li>
          <li><a class="menu-enlace" href="#tu-rol">Tu rol</a></li>
          <li><a class="menu-enlace" href="#preguntas">Preguntas</a></li>
        </ul>
      </nav>

      <a class="boton boton-aterrizaje" href="${ctx}/login.jsp">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-candado"/></svg>Sistemas TG</a>

      <button type="button" class="tema-boton" data-tema-boton aria-pressed="false" aria-label="Cambiar a tema oscuro" title="Cambiar a tema oscuro">
        <svg class="icono icono-sol" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-sol"/></svg>
        <svg class="icono icono-luna" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-luna"/></svg>
      </button>
    </div>
  </header>

  <section class="aterrizaje-hero">
    <div class="contenedor aterrizaje-hero-contenido">
      <p class="aterrizaje-hero-ceja">Gestión del trabajo de grado</p>
      <h1 class="aterrizaje-hero-titulo">Sistemas TG</h1>
      <p class="aterrizaje-hero-destacado"><c:out value="Estudiante, es tu oportunidad para desarrollar el mejor proyecto y destacar."/></p>
      <p class="aterrizaje-hero-texto">Seis fases, un recorrido claro y acompañamiento en cada paso, desde la idea hasta el título.</p>
      <div class="aterrizaje-hero-acciones">
        <a class="boton boton-primario boton-grande" href="${ctx}/login.jsp">Sistemas TG</a>
        <a class="boton boton-secundario boton-grande boton-sobre-foto" href="#como-funciona">Ver cómo funciona</a>
      </div>
      <a class="aterrizaje-senal" href="#como-funciona" aria-label="Bajar a Cómo funciona">
        <svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-flecha-derecha"/></svg>
      </a>
    </div>

    <c:if test="${empty errCifras}">
      <div class="contenedor">
        <ul class="aterrizaje-cifras" data-cifras>
          <li class="cifra">
            <span class="cifra-numero" data-cifra-final="${qIdeasBanco.rows[0].n}"><c:out value="${qIdeasBanco.rows[0].n}"/></span>
            <span class="cifra-etiqueta">Ideas disponibles en el banco</span>
          </li>
          <li class="cifra">
            <span class="cifra-numero" data-cifra-final="${qEnCurso.rows[0].n}"><c:out value="${qEnCurso.rows[0].n}"/></span>
            <span class="cifra-etiqueta">Proyectos en curso</span>
          </li>
          <li class="cifra">
            <span class="cifra-numero" data-cifra-final="${qFinalizados.rows[0].n}"><c:out value="${qFinalizados.rows[0].n}"/></span>
            <span class="cifra-etiqueta">Trabajos finalizados</span>
          </li>
          <li class="cifra cifra-fija">
            <span class="cifra-numero"><c:out value="6"/></span>
            <span class="cifra-etiqueta">Fases</span>
          </li>
          <li class="cifra cifra-fija">
            <span class="cifra-numero"><c:out value="4"/></span>
            <span class="cifra-etiqueta">Roles</span>
          </li>
        </ul>
      </div>
    </c:if>
  </section>

  <main>
    <section class="aterrizaje-seccion" id="como-funciona">
      <div class="contenedor">
        <header class="aterrizaje-seccion-cabecera" data-revelar>
          <p class="aterrizaje-ceja">Cómo funciona</p>
          <h2 class="aterrizaje-titulo">Las seis fases del trabajo de grado</h2>
          <p class="aterrizaje-entrada">Un recorrido ordenado: cada fase tiene un responsable y un turno, y el proyecto avanza solo cuando la revisión se aprueba.</p>
        </header>

        <ol class="recorrido">
          <li class="recorrido-fase" data-revelar>
            <span class="recorrido-numero">1</span>
            <div class="recorrido-datos">
              <span class="recorrido-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-bombilla"/></svg></span>
              <strong class="recorrido-nombre">Idea y pago</strong>
              <span class="recorrido-roles"><span class="chip">Estudiante</span><span class="chip">Comité</span></span>
              <span class="recorrido-desc">El estudiante carga la idea y el soporte de pago; el Comité lo revisa, lo aprueba con acta y asigna director y evaluador.</span>
            </div>
          </li>
          <li class="recorrido-fase" data-revelar>
            <span class="recorrido-numero">2</span>
            <div class="recorrido-datos">
              <span class="recorrido-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-documento"/></svg></span>
              <strong class="recorrido-nombre">Propuesta I</strong>
              <span class="recorrido-roles"><span class="chip">Estudiante</span><span class="chip">Director</span></span>
              <span class="recorrido-desc">El estudiante carga la propuesta (F-DC-124); la revisa el Director.</span>
            </div>
          </li>
          <li class="recorrido-fase" data-revelar>
            <span class="recorrido-numero">3</span>
            <div class="recorrido-datos">
              <span class="recorrido-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-check"/></svg></span>
              <strong class="recorrido-nombre">Propuesta II</strong>
              <span class="recorrido-roles"><span class="chip">Evaluador</span><span class="chip">Comité</span></span>
              <span class="recorrido-desc">La revisa el Evaluador y luego el Comité.</span>
            </div>
          </li>
          <li class="recorrido-fase" data-revelar>
            <span class="recorrido-numero">4</span>
            <div class="recorrido-datos">
              <span class="recorrido-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-documento"/></svg></span>
              <strong class="recorrido-nombre">Informe I</strong>
              <span class="recorrido-roles"><span class="chip">Estudiante</span><span class="chip">Director</span></span>
              <span class="recorrido-desc">El estudiante carga el informe (F-DC-125); lo revisa el Director.</span>
            </div>
          </li>
          <li class="recorrido-fase" data-revelar>
            <span class="recorrido-numero">5</span>
            <div class="recorrido-datos">
              <span class="recorrido-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-check"/></svg></span>
              <strong class="recorrido-nombre">Informe II</strong>
              <span class="recorrido-roles"><span class="chip">Evaluador</span><span class="chip">Comité</span></span>
              <span class="recorrido-desc">La revisa el Evaluador y luego el Comité.</span>
            </div>
          </li>
          <li class="recorrido-fase" data-revelar>
            <span class="recorrido-numero">6</span>
            <div class="recorrido-datos">
              <span class="recorrido-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-diploma"/></svg></span>
              <strong class="recorrido-nombre">Cierre</strong>
              <span class="recorrido-roles"><span class="chip">Comité</span></span>
              <span class="recorrido-desc">El Comité registra el radicado y finaliza el proyecto.</span>
            </div>
          </li>
        </ol>
      </div>
    </section>

    <section class="aterrizaje-seccion aterrizaje-seccion-alterna" id="tu-rol">
      <div class="contenedor">
        <header class="aterrizaje-seccion-cabecera" data-revelar>
          <p class="aterrizaje-ceja">Tu rol en el proceso</p>
          <h2 class="aterrizaje-titulo">Cuatro roles, un mismo objetivo</h2>
          <p class="aterrizaje-entrada">Cada rol entra con su documento, su contraseña y su rol, y ve solo lo que le corresponde.</p>
        </header>

        <div class="roles">
          <article class="rol-card" data-revelar>
            <span class="rol-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-diploma"/></svg></span>
            <h3 class="rol-titulo">Estudiante</h3>
            <p class="rol-texto">Elige una idea del banco o propone la suya, sube los enlaces de sus entregas y sigue su proyecto fase a fase.</p>
          </article>
          <article class="rol-card" data-revelar>
            <span class="rol-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-bombilla"/></svg></span>
            <h3 class="rol-titulo">Docente</h3>
            <p class="rol-texto">Propone ideas al banco y dirige o evalúa proyectos desde "Mis proyectos", según la fase y su turno.</p>
          </article>
          <article class="rol-card" data-revelar>
            <span class="rol-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-usuarios"/></svg></span>
            <h3 class="rol-titulo">Comité</h3>
            <p class="rol-texto">Revisa ideas y soportes de pago, asigna director y evaluador, y aprueba y cierra con radicado.</p>
          </article>
          <article class="rol-card" data-revelar>
            <span class="rol-icono"><svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-carpeta"/></svg></span>
            <h3 class="rol-titulo">Administrador</h3>
            <p class="rol-texto">Gestiona los usuarios y supervisa todos los proyectos, en modo de solo lectura.</p>
          </article>
        </div>
      </div>
    </section>

    <section class="aterrizaje-seccion" id="motivacion">
      <div class="contenedor">
        <header class="aterrizaje-seccion-cabecera" data-revelar>
          <p class="aterrizaje-ceja">Para empezar con ánimo</p>
          <h2 class="aterrizaje-titulo">Mensajes para tu proceso</h2>
        </header>

        <div class="carrusel" data-carrusel role="region" aria-roledescription="carrusel" aria-label="Mensajes motivadores">
          <ul class="carrusel-pista" data-carrusel-pista>
            <li class="carrusel-item">
              <p class="carrusel-frase">Estudiante, estás a un paso de tu mejor proyecto.</p>
            </li>
            <li class="carrusel-item">
              <p class="carrusel-frase">Tu esfuerzo será tu mejor título.</p>
            </li>
            <li class="carrusel-item">
              <p class="carrusel-frase">Seis fases, un proyecto, tu título.</p>
            </li>
            <li class="carrusel-item">
              <p class="carrusel-frase">Cada entrega te acerca a tu meta.</p>
            </li>
            <li class="carrusel-item">
              <p class="carrusel-frase">Un buen proyecto empieza con una buena idea.</p>
            </li>
            <li class="carrusel-item">
              <p class="carrusel-frase">Organiza, entrega, avanza: tu proyecto te espera.</p>
            </li>
            <li class="carrusel-item">
              <p class="carrusel-frase">El esfuerzo de hoy es el título de mañana.</p>
            </li>
          </ul>
        </div>
      </div>
    </section>

    <section class="aterrizaje-seccion aterrizaje-seccion-alterna" id="preguntas">
      <div class="contenedor aterrizaje-contenedor-angosto">
        <header class="aterrizaje-seccion-cabecera" data-revelar>
          <p class="aterrizaje-ceja">Preguntas frecuentes</p>
          <h2 class="aterrizaje-titulo">Dudas antes de empezar</h2>
        </header>

        <div class="acordeon" data-acordeon>
          <details class="acordeon-item">
            <summary class="acordeon-pregunta">¿Cómo empiezo?</summary>
            <div class="acordeon-respuesta"><p>El administrador registra a los usuarios. Después ingresas con tu número de documento, tu contraseña y tu rol.</p></div>
          </details>
          <details class="acordeon-item">
            <summary class="acordeon-pregunta">¿Qué es el soporte de pago?</summary>
            <div class="acordeon-respuesta"><p>Es el enlace del comprobante que subes junto con tu idea y que revisa el Comité en la Fase 1.</p></div>
          </details>
          <details class="acordeon-item">
            <summary class="acordeon-pregunta">¿Cómo entrego documentos?</summary>
            <div class="acordeon-respuesta"><p>Con enlaces (que empiezan por http:// o https://), no con archivos adjuntos. El sistema valida el formato antes de guardarlos.</p></div>
          </details>
          <details class="acordeon-item">
            <summary class="acordeon-pregunta">¿Qué significa "Aplazado"?</summary>
            <div class="acordeon-respuesta"><p>Que el documento necesita correcciones: el proyecto vuelve al estudiante para que suba una versión corregida.</p></div>
          </details>
          <details class="acordeon-item">
            <summary class="acordeon-pregunta">¿Quién ve mi proyecto?</summary>
            <div class="acordeon-respuesta"><p>Lo ves tú como estudiante principal; el director, el evaluador y el Comité lo revisan según la fase. Cada rol ve solo lo que le corresponde.</p></div>
          </details>
          <details class="acordeon-item">
            <summary class="acordeon-pregunta">¿Qué pasa al terminar?</summary>
            <div class="acordeon-respuesta"><p>El Comité registra el radicado y el proyecto queda "Finalizado", con las seis fases completadas.</p></div>
          </details>
        </div>
      </div>
    </section>

    <section class="aterrizaje-cta">
      <div class="contenedor aterrizaje-cta-contenido" data-revelar>
        <h2 class="aterrizaje-cta-titulo">¿Listo para empezar tu trabajo de grado?</h2>
        <p class="aterrizaje-cta-texto">Entra con tu documento, tu contraseña y tu rol para continuar donde vas.</p>
        <a class="boton boton-primario boton-grande" href="${ctx}/login.jsp">
          <svg class="icono" aria-hidden="true" focusable="false"><use href="${ctx}/img/iconos.svg#i-candado"/></svg>Sistemas TG</a>
      </div>
    </section>
  </main>

  <footer class="aterrizaje-pie">
    <div class="contenedor aterrizaje-pie-contenido">
      <div class="aterrizaje-pie-marca">
        <span class="aterrizaje-marca-texto">Sistemas TG</span>
        <span class="aterrizaje-pie-subtitulo">Gestión del trabajo de grado</span>
      </div>
      <nav class="aterrizaje-pie-enlaces" aria-label="Enlaces del pie de página">
        <a href="#como-funciona">Cómo funciona</a>
        <a href="#tu-rol">Tu rol</a>
        <a href="#preguntas">Preguntas</a>
        <a href="${ctx}/login.jsp">Entrar</a>
      </nav>
      <p class="aterrizaje-pie-nota">Seis fases, un proyecto, tu título.</p>
    </div>
  </footer>

  <script src="${ctx}/js/app.js" defer></script>
  <script src="${ctx}/js/aterrizaje.js" defer></script>
</body>
</html>
