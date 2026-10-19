<c:set var="rutaActual" value="${pageContext.request.servletPath}"/>
<%--
  menu.jsp - Menu principal por rol (M9-D parte A) con insignias de pendientes
  (M9-E parte C). Las consultas de las insignias son de solo lectura, baratas y
  solo se ejecutan cuando hay sesión, con el rol que corresponde. El texto de
  cada enlace no cambia: la burbuja va aparte, como hermano del <a>.
  Este fragmento no declara taglibs: usa los de la pagina que lo incluye.
--%>
<c:if test="${not empty sessionScope.usuarioId}">
  <c:if test="${sessionScope.rolId == 2}">
    <sql:query var="insComIdeasDoc" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM idea_docente WHERE estado = 'PENDIENTE'"/>
    <sql:query var="insComIdeasEst" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_fase = 1 AND id_rol_proceso = 4 AND finalizado = 0"/>
    <sql:query var="insComProy" dataSource="${db}" sql="SELECT COUNT(*) AS n FROM proyecto WHERE id_rol_proceso = 4 AND finalizado = 0"/>
    <c:set var="insComIdeasDoc" value="${insComIdeasDoc.rows[0].n}"/>
    <c:set var="insComIdeasEst" value="${insComIdeasEst.rows[0].n}"/>
    <c:set var="insComProy" value="${insComProy.rows[0].n}"/>
  </c:if>
  <c:if test="${sessionScope.rolId == 3}">
    <sql:query var="insDocProy" dataSource="${db}"
               sql="SELECT COUNT(*) AS n FROM v_proyecto WHERE finalizado = 0 AND ((id_director = ? AND rol_turno = 'Director') OR (id_evaluador = ? AND rol_turno = 'Evaluador'))">
      <sql:param value="${sessionScope.usuarioId}"/>
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <c:set var="insDocProy" value="${insDocProy.rows[0].n}"/>
  </c:if>
  <c:if test="${sessionScope.rolId == 4}">
    <sql:query var="insEstProy" dataSource="${db}"
               sql="SELECT COUNT(*) AS n FROM v_proyecto_estudiante WHERE id_estudiante1 = ? AND rol_turno = 'Estudiante' AND finalizado = 0">
      <sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <c:set var="insEstProy" value="${insEstProy.rows[0].n}"/>
  </c:if>
</c:if>
<nav class="menu" aria-label="Menú principal" data-menu-movil>
  <div class="contenedor menu-barra">
    <button type="button" class="menu-boton" data-menu-boton aria-controls="menu-principal" aria-expanded="false">
      <svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-menu"/></svg>
      Menú
    </button>
    <ul class="menu-lista" id="menu-principal">
      <li><a class="menu-enlace${rutaActual == '/index.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/index.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-inicio"/></svg>Inicio</a></li>
      <c:choose>
        <c:when test="${sessionScope.rolId == 1}">
          <li><a class="menu-enlace${rutaActual == '/admin/panel.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/admin/panel.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-carpeta"/></svg>Mi panel</a></li>
          <li><a class="menu-enlace${rutaActual == '/admin/usuarios.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/admin/usuarios.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-usuarios"/></svg>Usuarios</a></li>
          <li><a class="menu-enlace${rutaActual == '/admin/recursos.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/admin/recursos.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-reloj"/></svg>Calendario y formatos</a></li>
          <li><a class="menu-enlace${rutaActual == '/admin/proyectos.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/admin/proyectos.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg>Proyectos</a></li>
        </c:when>
        <c:when test="${sessionScope.rolId == 2}">
          <li><a class="menu-enlace${rutaActual == '/comite/panel.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/comite/panel.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-carpeta"/></svg>Mi panel</a></li>
          <li>
            <a class="menu-enlace${rutaActual == '/comite/ideas-docentes.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/comite/ideas-docentes.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-bombilla"/></svg>Banco de ideas docente</a>
            <span class="menu-insignia${insComIdeasDoc > 0 ? '' : ' menu-insignia-cero'}" data-insignia="comite-ideas-docentes" title="Ideas de docentes por revisar"><c:out value="${insComIdeasDoc}"/></span>
          </li>
          <li>
            <a class="menu-enlace${rutaActual == '/comite/ideas-estudiantes.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/comite/ideas-estudiantes.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-bombilla"/></svg>Ideas de estudiantes</a>
            <span class="menu-insignia${insComIdeasEst > 0 ? '' : ' menu-insignia-cero'}" data-insignia="comite-ideas-estudiantes" title="Ideas de estudiantes en Fase 1"><c:out value="${insComIdeasEst}"/></span>
          </li>
          <li>
            <a class="menu-enlace${rutaActual == '/comite/proyectos.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/comite/proyectos.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg>Proyectos</a>
            <span class="menu-insignia${insComProy > 0 ? '' : ' menu-insignia-cero'}" data-insignia="comite-proyectos" title="Proyectos en el turno del Comité"><c:out value="${insComProy}"/></span>
          </li>
        </c:when>
        <c:when test="${sessionScope.rolId == 3}">
          <li><a class="menu-enlace${rutaActual == '/docente/panel.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/docente/panel.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-carpeta"/></svg>Mi panel</a></li>
          <li><a class="menu-enlace${rutaActual == '/docente/ideas.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/docente/ideas.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-bombilla"/></svg>Mis ideas</a></li>
          <li>
            <a class="menu-enlace${rutaActual == '/docente/proyectos.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/docente/proyectos.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg>Mis proyectos</a>
            <span class="menu-insignia${insDocProy > 0 ? '' : ' menu-insignia-cero'}" data-insignia="docente-proyectos" title="Proyectos en tu turno"><c:out value="${insDocProy}"/></span>
          </li>
        </c:when>
        <c:when test="${sessionScope.rolId == 4}">
          <li><a class="menu-enlace${rutaActual == '/estudiante/panel.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/estudiante/panel.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-carpeta"/></svg>Mi panel</a></li>
          <li>
            <a class="menu-enlace${rutaActual == '/estudiante/proyectos.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/estudiante/proyectos.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-documento"/></svg>Mis proyectos</a>
            <span class="menu-insignia${insEstProy > 0 ? '' : ' menu-insignia-cero'}" data-insignia="estudiante-proyectos" title="Es tu turno en estos proyectos"><c:out value="${insEstProy}"/></span>
          </li>
          <li><a class="menu-enlace${rutaActual == '/estudiante/banco-ideas.jsp' ? ' menu-enlace-actual' : ''}" href="${pageContext.request.contextPath}/estudiante/banco-ideas.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-bombilla"/></svg>Banco de ideas</a></li>
        </c:when>
      </c:choose>
      <c:if test="${not empty sessionScope.usuarioId}">
        <li><a class="menu-enlace" href="${pageContext.request.contextPath}/logout.jsp"><svg class="icono" aria-hidden="true" focusable="false"><use href="${pageContext.request.contextPath}/img/iconos.svg#i-salir"/></svg>Cerrar sesión</a></li>
      </c:if>
    </ul>
  </div>
</nav>
