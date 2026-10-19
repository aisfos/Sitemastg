<%--
  url-valida.jsp — Validación de una URL (req. 17, 20d).
  Reglas: no vacía, máximo 500 caracteres, empieza por http:// o https://,
  sin espacios, sin comillas dobles ni simples y sin < ni >.
  Entradas : url        -> la cadena a validar (recortada antes con fn:trim)
  Salida   : urlValida  -> Boolean (true si cumple todas las reglas)
  Este fragmento no declara taglibs: usa los de la página que lo incluye.
--%>
<c:set var="cMenor" value="<"/>
<c:set var="cMayor" value=">"/>
<c:set var="cComillaD" value='"'/>
<c:set var="cComillaS" value="'"/>
<c:set var="urlValida" value="${not empty url
  and fn:length(url) le 500
  and (fn:startsWith(url, 'http://') or fn:startsWith(url, 'https://'))
  and not fn:contains(url, ' ')
  and not fn:contains(url, cComillaD)
  and not fn:contains(url, cComillaS)
  and not fn:contains(url, cMenor)
  and not fn:contains(url, cMayor)}"/>
