<%@ tag body-content="empty"  %>

<%@ attribute name="type" required="true" %>
<%@ attribute name="templateQuery" required="true" type="org.intermine.web.TemplateQuery" %>
<%@ attribute name="className" required="false" type="java.lang.String" %>
<%@ attribute name="interMineObject" required="false" type="java.lang.Object" %>

<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

    <c:if test="${!templateQuery.valid}">
      <html:link action="/templateProblems?name=${templateQuery.name}&amp;type=${type}" styleClass="brokenTmplLink">
      <strike><span class="templateDesc"><c:out value="${templateQuery.description}"/></span></strike>
      <img border="0" class="arrow" src="images/right-arrow.gif" alt="->"/>
      </html:link>
    </c:if>
    <c:if test="${templateQuery.valid}">
      <span class="templateDesc"><c:out value="${templateQuery.description}"/></span>
      <fmt:message var="linkTitle" key="templateList.run">
        <fmt:param value="${templateQuery.name}"/>
      </fmt:message>
      <c:set var="extra" value=""/>
      <c:if test="${!empty className}">
        <c:forEach items="${CLASS_TEMPLATE_EXPRS[className][templateQuery.name]}" var="fieldExpr">
          <c:set var="fieldName" value="${fn:split(fieldExpr, '.')[1]}"/>
          <c:set var="fieldValue" value="${interMineObject[fieldName]}"/>
          <c:set var="extra" value="${extra}&amp;${fieldExpr}_value=${fieldValue}"/>
        </c:forEach>
      </c:if>
      <html:link action="/template?name=${templateQuery.name}&amp;type=${type}${extra}" 
                 title="${linkTitle}">
        <img border="0" class="arrow" src="images/right-arrow.gif" alt="-&gt;"/>
      </html:link>
    </c:if>
    <c:if test="${type == 'user'}">
      <%-- pull required messages --%>
      <fmt:message var="confirmMessage" key="templateList.deleteMessage">
       <fmt:param value="${templateQuery.name}"/>
      </fmt:message>
      <fmt:message var="linkTitle" key="templateList.delete">
        <fmt:param value="${templateQuery.name}"/>
      </fmt:message>
      <%-- map of parameters to pass to the confirm action --%>
      <jsp:useBean id="deleteParams" scope="page" class="java.util.TreeMap">
        <c:set target="${deleteParams}" property="message" value="${confirmMessage}" />
        <c:set target="${deleteParams}" property="confirmAction" value="/userTemplateAction?method=delete&amp;name=${templateQuery.name}&amp;type=${templateType}" />
        <c:set target="${deleteParams}" property="cancelAction" value="/begin" />
      </jsp:useBean>
      <html:link action="/confirm" name="deleteParams" title="${linkTitle}">
        <img border="0" class="arrow" src="images/cross.gif" alt="x"/>
      </html:link>
      <c:remove var="deleteParams"/>
      <c:if test="${templateQuery.valid}">
        <fmt:message var="linkTitle" key="templateList.edit">
          <fmt:param value="${templateQuery.name}"/>
        </fmt:message>
        <html:link action="/editTemplate?name=${templateQuery.name}" title="${linkTitle}">
          <img border="0" class="arrow" src="images/edit.gif" alt="[edit]"/>
        </html:link>
      </c:if>
    </c:if>
