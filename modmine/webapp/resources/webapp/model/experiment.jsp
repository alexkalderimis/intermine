<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im"%>
<%@ taglib tagdir="/WEB-INF/tags" prefix="mm"%>
<%@ taglib uri="http://flymine.org/imutil" prefix="imutil"%>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1"
    prefix="str"%>

<!-- experiment.jsp -->

<html:xhtml />
<script type="text/javascript" src="<html:rewrite page='/js/jquery.qtip-1.0.0-rc3.min.js'/>"></script>
<script type="text/javascript" src="js/tablesort.js"></script>
<link rel="stylesheet" type="text/css" href="css/sorting_experiments.css"/>
<link rel="stylesheet" type="text/css" href="model/css/experiment.css"/>

<tiles:importAttribute />

<div class="body">

<%-- EXPERIMENT --%>

<c:forEach items="${experiments}" var="exp"  varStatus="status">
<%-- for gbrowse: to modify and take the organism from the submission --%>
<c:set var="ncbiftp" value="ftp://ftp.ncbi.nlm.nih.gov"/>
<c:set var="isPrimer" value="primer"/>
<c:set var="wormTracksCounter" value="0"/>
<c:set var="flyTracksCounter" value="0"/>
<c:set var="project" value="${exp.piSurname}"/>
<c:set var="proGFF" value="PianoWaterstonCelniker"/>

  <im:boxarea title="${exp.name}" stylename="gradientbox">

  <table cellpadding="0" cellspacing="0" border="0" class="dbsources">
  <tr>

  <td>
    <c:forEach items="${exp.organisms}" var="organism" varStatus="orgStatus">
      <c:if test="${organism eq 'D. melanogaster'}">
        <img border="0" class="arrow" src="model/images/f_vvs.png" title="fly"/>
            <c:set var="fly" value="1" />
          </c:if>
      <c:if test="${organism eq 'C. elegans'}">
        <img border="0" class="arrow" src="model/images/w_vvs.png" title="worm"/>
            <c:set var="worm" value="1" />
          </c:if>
    </c:forEach>
  </td>

  <td>experiment: <b><c:out value="${exp.name}"/></b></td>
  <td>project: <b><c:out value="${exp.projectName}"></c:out></b></td>
  <td>PI: <b><c:out value="${exp.pi}"></c:out></b></td>
  <td>Labs:
<%-- Note: linking with surname only, 2 Green and Kim  --%>
<%-- whole foreach on one line to avoid spaces before commas --%>
    <c:forEach items="${exp.labs}" var="lab" varStatus="labStatus"><c:if test="${!labStatus.first}">, </c:if><b><html:link href="/${WEB_PROPERTIES['webapp.path']}/portal.do?externalid=*${lab}&class=Lab" title="more info on ${lab}'s lab">${lab}</html:link></b></c:forEach>
  </td>

  </tr>


  <tr>
  <td colspan="5"><c:out value="${exp.description}"></c:out></td>
  </tr>
  </table>

<%-- EXPERIMENT FEATURES --%>
  <c:if test="${! empty exp.featureCountsRecords || !empty tracks[exp.name]}">
  <div id="experimentFeatures">

  <br/>
     <table>
     <tr>
     <td style="width: 45%" align="top">
      <c:choose>
      <c:when test="${!empty exp.featureCountsRecords}">

All features generated by this experiment:

      <table cellpadding="0" cellspacing="0" border="0" class="dbsources">
      <tr>
        <th colspan="3">Feature</th>
        <th colspan="4">Export</th>
      </tr>

      <c:forEach items="${exp.featureCountsRecords}" var="fc" varStatus="status">
          <tr>
            <td><b>${fc.featureType}</b></td>
            <td>
<c:forEach items="${expFeatDescription}" var="fdes" varStatus="fdes_status">
<c:if test="${fn:substringBefore(fdes.key, '+') == exp.name && fn:substringAfter(fdes.key, '+') == fc.featureType}">
<img src="model/images/def_s.png" title="${fdes.value }" />
            </c:if>
</c:forEach>

</td>
            <td align="right">
              <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=results&experiment=${exp.name}&feature=${fc.featureType}"
        title="View all ${fc.featureType}s">${fc.featureCounts}
              <html:img src="images/right-arrow.gif" title="View all ${fc.featureType}s" /></html:link>

<%--TODO find icon for expression levels --%>

<c:forEach items="${expFeatEL}" var="expEL" varStatus="expEL_status">
  <c:if test="${expEL.key == exp.name}" >
  <c:forEach items="${expEL.value}" var="expELF" varStatus="expELF_status">
    <c:if test="${expELF.key == fc.featureType}" >
Expression Levels

  <html:link
    href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=expEL&action=results&experiment=${exp.name}&feature=${fc.featureType}"
        title="View all expression levels for these ${fc.featureType}s">${expELF.value}
              <html:img src="images/right-arrow.gif" title="View all expression levels for these ${fc.featureType}s" /></html:link>

    </c:if>
  </c:forEach>
  </c:if>
</c:forEach>

      <c:if test="${!empty fc.uniqueFeatureCounts && fc.uniqueFeatureCounts != fc.featureCounts}">
      <br>
      <i style="font-size:0.9em;">
      This represents ${fc.uniqueFeatureCounts} unique ${fc.featureType}s
      </i>
      </c:if>
            </td>

            <td align="center">
               <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&feature=${fc.featureType}&format=tab"
        title="Download in tab separated value format">TAB</html:link>

            </td>
            <td align="center">
              <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&feature=${fc.featureType}&format=csv"
        title="Download in comma separated value format">CSV</html:link>

            </td>

       <%--     <c:if test="${!empty exp.unlocated }"> --%>
<c:choose>
<c:when test="${!empty exp.unlocated && fn:contains(exp.unlocated, fc.featureType)}">
<td><i>GFF3</i></td>
<td><i>SEQ</i></td>
</c:when>
<c:otherwise>
            <td align="center">
             <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&feature=${fc.featureType}&format=gff3"
        title="Download in GFF3 format">GFF3</html:link>
            </td>
            <td align="center">
             <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&feature=${fc.featureType}&format=sequence"
        title="Download the sequences">SEQ</html:link>

            </td>
</c:otherwise>
</c:choose>

          </tr>
      </c:forEach>
      <!-- end submission loop -->


    </table>

    </c:when>
    <c:otherwise>
    <c:set var="hasFeat" value="false"/>
     NO FEATURES GENERATED BY THIS EXPERIMENT
    </c:otherwise>
    </c:choose>
   </td>

<%-- EXPERIMENT TRACKS --%>
     <td style="width: 40%" align="top">
     <c:choose>
     <c:when test="${!empty tracks[exp.name]}">
     <c:set var="flylabels" value=""/>
     <c:set var="wormlabels" value=""/>

All GBrowse tracks generated for this experiment:

      <table cellpadding="0" cellspacing="0" border="0" class="dbsources">
      <tr>
        <th>
       <c:choose>
         <c:when test="${fn:length(tracks[exp.name]) == 1}">
         GBrowse track
         </c:when>
         <c:otherwise>
           <c:out value=" "/> GBrowse tracks:
         </c:otherwise>
       </c:choose>
     </th>
     <th colspan="7">by chromosome</th>
     <c:forEach items="${tracks[exp.name]}" var="etrack"  varStatus="status">
     <%-- build the url for getting all the labels in this experiment --%>
     <c:set var="organism" value="${etrack.organism}"/>

<c:choose>
<c:when test="${fn:startsWith(organism,'worm')}">
<c:set var="wormTracksCounter" value="${wormTracksCounter +1 }" />
  <c:choose>
  <c:when test="${empty wormlabels}">
     <c:set var="wormlabels" value="${etrack.track}" />
  </c:when>
  <c:otherwise>
     <c:if test="${!fn:contains(wormlabels, etrack.track)}">
       <c:set var="wormlabels" value="${wormlabels}-${etrack.track}" />
     </c:if>
  </c:otherwise>
  </c:choose>
</c:when>
<c:when test="${fn:startsWith(organism,'fly')}">
<c:set var="flyTracksCounter" value="${flyTracksCounter +1}" />
  <c:choose>
  <c:when test="${empty flylabels}">
     <c:set var="flylabels" value="${etrack.track}" />
  </c:when>
  <c:otherwise>
     <c:if test="${!fn:contains(flylabels, etrack.track)}">
       <c:set var="flylabels" value="${flylabels}-${etrack.track}" />
     </c:if>
  </c:otherwise>
  </c:choose>
</c:when>
</c:choose>

</c:forEach>

<tr>
<td >

<c:if test="${flyTracksCounter > 1 }">
<b><html:link
     href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?label=${flylabels}" target="_blank" title="View all the tracks for this experiment">
     All ${flyTracksCounter} tracks
</html:link></b>
        <img border="0" class="arrow" src="model/images/f_vvs.png" title="fly"/>
</c:if>

<c:if test="${ flyTracksCounter== 1}">
<b><html:link
     href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?label=${flylabels}" target="_blank" title="View the track generated for this experiment">
     ${flylabels}
</html:link></b>
        <img border="0" class="arrow" src="model/images/f_vvs.png" title="fly"/>
</c:if>

<c:if test="${ flyTracksCounter > 0 && wormTracksCounter > 0}">
<br></br>
</c:if>
<c:if test="${wormTracksCounter > 1 }">
<b><html:link
     href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?label=${wormlabels}" target="_blank" title="View all the tracks for this experiment">
     All ${wormTracksCounter} tracks
</html:link></b>
        <img border="0" class="arrow" src="model/images/w_vvs.png" title="worm"/>
</c:if>

<c:if test="${ wormTracksCounter== 1}">
<b><html:link
     href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?label=${wormlabels}" target="_blank" title="View the track generated for this experiment">
     ${wormlabels}
</html:link></b>
        <img border="0" class="arrow" src="model/images/w_vvs.png" title="worm"/>
</c:if>



</td>
<td>
<c:if test="${ flyTracksCounter > 0 }">
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=X;label=${flylabels};start=0;end=500000" target="_blank">X</html:link>
</c:if>
<c:if test="${wormTracksCounter > 0}">
  <c:if test="${ flyTracksCounter > 0 }">
   <br><br>
  </c:if>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?ref=I;label=${wormlabels};start=0;end=500000" target="_blank">I</html:link>
</c:if>
</td>

<td>
<c:if test="${ flyTracksCounter > 0 }">
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=2L;label=${flylabels};start=0;end=500000" target="_blank">2L</html:link>
</c:if>
<c:if test="${wormTracksCounter > 0}">
  <c:if test="${ flyTracksCounter > 0 }">
   <br><br>
  </c:if>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?ref=II;label=${wormlabels};start=0;end=500000" target="_blank">II</html:link>
</c:if>
</td>
<td>
<c:if test="${ flyTracksCounter > 0 }">
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=2R;label=${flylabels};start=0;end=500000" target="_blank">2R</html:link>
</c:if>
<c:if test="${wormTracksCounter > 0}">
  <c:if test="${ flyTracksCounter > 0 }">
   <br><br>
  </c:if>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?ref=III;label=${wormlabels};start=0;end=500000" target="_blank">III</html:link>
</c:if>
</td>
<td>
<c:if test="${ flyTracksCounter > 0 }">
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=3L;label=${flylabels};start=0;end=500000" target="_blank">3L</html:link>
</c:if>
<c:if test="${wormTracksCounter > 0}">
  <c:if test="${ flyTracksCounter > 0 }">
   <br><br>
  </c:if>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?ref=IV;label=${wormlabels};start=0;end=500000" target="_blank">IV</html:link>
</c:if>
</td>
<td>
<c:if test="${ flyTracksCounter > 0 }">
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=3R;label=${flylabels};start=0;end=500000" target="_blank">3R</html:link>
</c:if>
<c:if test="${wormTracksCounter > 0}">
  <c:if test="${ flyTracksCounter > 0 }">
   <br><br>
  </c:if>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?ref=V;label=${wormlabels};start=0;end=500000" target="_blank">V</html:link>
</c:if>
</td>
<td>
<c:if test="${ flyTracksCounter > 0 }">
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=4;label=${flylabels};start=0;end=500000" target="_blank">4</html:link>
</c:if>
<c:if test="${wormTracksCounter > 0}">
  <c:if test="${ flyTracksCounter > 0 }">
   <br><br>
  </c:if>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/worm/?ref=X;label=${wormlabels};start=0;end=500000" target="_blank">X</html:link>
</c:if>
</td>

<c:if test="${ flyTracksCounter > 0 }">
<td>
<html:link href="${WEB_PROPERTIES['gbrowse.prefix']}/fly/?ref=U;label=${flylabels};start=0;end=500000" target="_blank">U</html:link>
<c:if test="${wormTracksCounter > 0}">
<br></br><br>-</br>
</c:if>
</c:if>

</table>
     </c:when>
     <c:otherwise>
        NO GBROWSE TRACKS FOR THIS EXPERIMENT
     </c:otherwise>
     </c:choose>
   </td>

<%-- EXPERIMENT SUBMISSIONS TO REPOSITORIES --%>
     <c:if test="${exp.repositedCount >1 }">
 <tr>
 <td>
     <%--FULL GFF --%>
   <c:if test="${project == 'Celniker'
   && fn:containsIgnoreCase(exp.name,'Gene Model')
   && hasFeat != 'false'}" >
    <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&project=${project}&feature=all&format=gff3"
        title="Download in GFF3 format"><b>GFF3 for the experiment (with Genes, UTRs, Transcripts, mRNA, Codons, CDS, polyA sites)</b></html:link>
   </c:if>
   <c:if test="${project == 'Piano'
   && fn:containsIgnoreCase(exp.name,'Encyclopedia')
      && hasFeat != 'false'}" >
    <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&project=${project}&feature=all&format=gff3"
        title="Download in GFF3 format"><b>GFF3 for the experiment (with Genes, UTRs, Transcripts, mRNA)</b></html:link>
   </c:if>
   <c:if test="${project == 'Waterston'
   && fn:containsIgnoreCase(exp.name,'Definition')
      && hasFeat != 'false'}" >
    <html:link
        href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=experiment&action=export&experiment=${exp.name}&project=${project}&feature=all&format=gff3"
        title="Download in GFF3 format"><b>GFF3 for the experiment (with Transcripts, introns, exons, polyA sites, TSS, TES, acceptor sites)</b></html:link>
   </c:if>
 </td>

     <td align="top"><b>
       <im:querylink text="All entries in public repositories generated by this experiment" skipBuilder="true" title="View all submissions to public repositories (AE, GEO, SRA) for this experiment">
        <query name="" model="genomic" view="Experiment.name Experiment.submissions.DCCid Experiment.submissions.databaseRecords.database Experiment.submissions.databaseRecords.accession Experiment.submissions.databaseRecords.url" sortOrder="Experiment.name asc">
         <node path="Experiment" type="Experiment">
         </node>
         <node path="Experiment.name" type="String">
          <constraint op="=" value="${exp.name}" description="" identifier="" code="A">
          </constraint>
        </node>
       </query>

     </im:querylink>
     </td>
</c:if>

   </tr>
</table>
    </div>
    </c:if>

<%-- SUBMISSIONS ==================================================================--%>
<div class="submissions">
  <em>
  <c:choose>
    <c:when test="${exp.submissionCount == 0}">
      There are no submissions for this experiment:
    </c:when>
    <c:when test="${exp.submissionCount == 1}">
      There is <c:out value="${exp.submissionCount}"></c:out> <b><c:out value="${exp.experimentType}"></c:out></b> submission for this experiment:
    </c:when>
    <c:otherwise>
      There are <c:out value="${exp.submissionCount}"></c:out> <b><c:out value="${exp.experimentType}"></c:out></b> submissions for this experiment:
    </c:otherwise>

  </c:choose>
  </em>

<table cellpadding="0" cellspacing="0" border="0" class="sortable-onload-2 rowstyle-alt no-arrow submission_table">
<tr>
    <th class="sortable">DCC id</th>
    <th class="sortable">Name</th>

      <c:forEach items="${exp.factorTypes}" var="factor">

<%-- TEMP FIX for long list of primers --%>
           <c:choose>
           <c:when test="${fn:contains(factor,isPrimer)}">
           <th ><c:out value="${factor}"></c:out></th>
           </c:when>
          <c:otherwise>
      <th class="sortable" bgcolor="white"><c:out value="${factor}"></c:out></th>
          </c:otherwise>
          </c:choose>

      </c:forEach>
    <th>Date</th>
    <th>Features, GBrowse and Data Files</th>
  </tr>

<c:forEach items="${exp.submissionsAndFeatureCounts}" var="subCounts">
  <c:set var="sub" value="${subCounts.key}"></c:set>
    <tr>
      <td class="sorting">
      <html:link href="/${WEB_PROPERTIES['webapp.path']}/objectDetails.do?id=${subCounts.key.id}">
      <c:out value="${sub.dCCid}"></c:out></html:link>
      <p>
        <c:forEach items="${sub.relatedSubmissions}" var="relSubs" varStatus="rstatus">
        <br>
        <c:if test="${rstatus.first}">Related to: </c:if>
<html:link href="/${WEB_PROPERTIES['webapp.path']}/objectDetails.do?id=${relSubs.id}">
<c:out value="${relSubs.dCCid}"></c:out></html:link>
        <c:if test="${rstatus.last}"></c:if>
        </c:forEach>

      </td>

      <td class="sorting">
      <html:link href="/${WEB_PROPERTIES['webapp.path']}/objectDetails.do?id=${subCounts.key.id}">
      <c:out value="${sub.title}"></c:out></html:link>
      </td>

<%-- FACTORS --%>
    <c:forEach items="${exp.factorTypes}" var="factorType">
    <c:set var="thisTypeCount" value="0"></c:set>

       <td class="sorting" bgcolor="white">
          <c:forEach items="${sub.experimentalFactors}" var="factor" varStatus="status">
            <c:if test="${factor.type == factorType}">
                <c:choose>
                   <c:when test="${factor.property != null}">

    <c:set var="thisTypeCount" value="${thisTypeCount + 1}"></c:set>

                   <c:choose>
                   <c:when test="${thisTypeCount <= 5}">


                     <html:link href="/${WEB_PROPERTIES['webapp.path']}/objectDetails.do?id=${factor.property.id}" title="More information about this factor"><c:out value="${factor.name}"/></html:link>
                    <span class="tinylink">
                       <im:querylink text="[ALL]" skipBuilder="true" title="View all submissions using this factor">
                         <query name="" model="genomic"
                           view="Submission.DCCid Submission.project.surnamePI Submission.title Submission.experimentType Submission.properties.type Submission.properties.name"
                           sortOrder="Submission.experimentType asc">
                      <node path="Submission.properties.type" type="String">
                        <constraint op="=" value="${factor.type}" description=""
                                    identifier="" code="A">
                        </constraint>
                      </node>
                      <node path="Submission.properties.name" type="String">
                        <constraint op="=" value="${factor.name}" description=""
                                    identifier="" code="B">
                        </constraint>
                      </node>
                      <node path="Submission.organism.taxonId" type="Integer">
                        <constraint op="=" value="${sub.organism.taxonId}" description=""
                                    identifier="" code="C">
                        </constraint>
                      </node>
                    </query>
                  </im:querylink>
                  </span>
                   </c:when>
                  <c:when test="${thisTypeCount > 5 && status.last}">
                  ...
<br></br>
                  <im:querylink text="all ${thisTypeCount} ${factor.type}s" showArrow="true" skipBuilder="true"
                  title="View all ${thisTypeCount} ${factor.type} factors of submission ${sub.dCCid}">

<query name="" model="genomic" view="SubmissionProperty.name SubmissionProperty.type" sortOrder="SubmissionProperty.type asc" constraintLogic="A and B">
  <node path="SubmissionProperty" type="SubmissionProperty">
  </node>
  <node path="SubmissionProperty.submissions" type="Submission">
    <constraint op="LOOKUP" value="${sub.dCCid}" description="" identifier="" code="A" extraValue="">
    </constraint>
  </node>
  <node path="SubmissionProperty.type" type="String">
    <constraint op="=" value="${factor.type}" description="" identifier="" code="B" extraValue="">
    </constraint>
  </node>
</query>

                  </im:querylink>

</c:when>
</c:choose>

</c:when>
                   <c:otherwise>
                     <c:out value="${factor.name}"/><c:if test="${!status.last}">,</c:if>
                   </c:otherwise>
                 </c:choose>
               </c:if>
           </c:forEach>
      </td>
    </c:forEach>

<td class="sorting"><fmt:formatDate value="${sub.publicReleaseDate}" type="date"/></td>
<%-- FEATURES --%>
  <td class="sorting">
    <c:if test="${!empty subCounts.value}">
      <div class="submissionFeatures">
      <table cellpadding="0" cellspacing="0" border="0" class="features" width="100%">
      <c:forEach items="${subCounts.value}" var="fc" varStatus="rowNumber">
          <c:set var="class" value=""/>
    <tr><td>
<c:forEach items="${expFeatDescription}" var="fdes" varStatus="fdes_status">
<c:if test="${fn:substringBefore(fdes.key, '+') == exp.name && fn:substringAfter(fdes.key, '+') == fc.key}">
<img src="model/images/def_s.png" title="${fdes.value }" height="18" width="18" />
            </c:if>
</c:forEach>
   ${fc.key}:
   <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=results&submission=${sub.dCCid}&feature=${fc.key}">${fc.value} </html:link>

  &nbsp;&nbsp;export:
  <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&feature=${fc.key}&format=tab">TAB</html:link>
  &nbsp;
  <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&feature=${fc.key}&format=csv">CSV</html:link>
          <c:set var="isUnloc" value="false"></c:set>
          <c:forEach items="${unlocatedFeat}" var="uft" varStatus="uft_status">
            <c:if test="${uft.key == sub.dCCid}">
             <c:forEach items="${uft.value}" var="uftv" varStatus="uftv_status">
              <c:if test="${uftv == fc.key}">
                <c:set var="isUnloc" value="true">
                </c:set>
              </c:if>
            </c:forEach>
          </c:if>
         </c:forEach>
<c:choose>
<c:when test="${isUnloc == 'true' }">
<i>&nbsp;GFF3&nbsp;SEQ</i>
</c:when>
<c:otherwise>
   &nbsp;<html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&feature=${fc.key}&format=gff3">GFF3</html:link>
   &nbsp;<html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&feature=${fc.key}&format=sequence">SEQ</html:link>
</c:otherwise>
</c:choose>

   &nbsp;&nbsp;
   <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=list&submission=${sub.dCCid}&feature=${fc.key}">create&nbsp;LIST</html:link>


                </td>
            </tr>
          <c:set var="featCount" value="${rowNumber.count}"></c:set>

            <tr><td>
<c:forEach items="${subFeatEL}" var="subEL" varStatus="subEL_status">
  <c:if test="${subEL.key == sub.dCCid}" >
  <c:forEach items="${subEL.value}" var="subELF" varStatus="subELF_status">
    <c:if test="${subELF.key == fc.key}" >
Expression Levels:&nbsp;

  <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=subEL&action=results&submission=${sub.dCCid}&feature=${fc.key}">${subELF.value} </html:link>

    </c:if>
  </c:forEach>
  </c:if>
</c:forEach>
            </td>
            </tr>

        </c:forEach>
            <tr><td>
<%--
            <c:if test="${fn:containsIgnoreCase(proGFF,project)}" >
   <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&project=${project}&feature=all&format=gff3">[full gff3]</html:link>
            </c:if>
--%>

   <c:if test="${project == 'Celniker' && fn:containsIgnoreCase(exp.name,'Gene Model')  && featCount > 4}" >
    <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&project=${project}&feature=all&format=gff3">[full gff3]</html:link>
   </c:if>
   <c:if test="${project == 'Piano' && fn:containsIgnoreCase(exp.name,'Encyclopedia') && featCount > 4}" >
    <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&project=${project}&feature=all&format=gff3">[full gff3]</html:link>
   </c:if>
   <c:if test="${project == 'Waterston' && fn:containsIgnoreCase(exp.name,'Definition') && featCount > 4}" >
    <html:link href="/${WEB_PROPERTIES['webapp.path']}/features.do?type=submission&action=export&submission=${sub.dCCid}&project=${project}&feature=all&format=gff3">[full gff3]</html:link>
   </c:if>

   &nbsp;&nbsp;<html:link href="/${WEB_PROPERTIES['webapp.path']}/objectDetails.do?id=${subCounts.key.id}"><c:out value="[find nearby features]"></c:out></html:link>
            </td></tr>
        </table>
        </div>
      </c:if>

<%-- GBROWSE --%>

          <c:forEach items="${subTracks}" var="subTracks" varStatus="subt_status">
            <c:if test="${subTracks.key == sub.dCCid}">
          <table cellpadding="0" cellspacing="0" border="0" class="internal" >
    <tr>
    <td valign="top">GBrowse tracks: </td>
    <td valign="top">
         <c:forEach items="${subTracks.value}" var="track" varStatus="track_status">
         <mm:singleTrack track="${track}"/>
         <br>
        </c:forEach>
        </td>
        <td valign="top">
             <mm:allTracks tracks="${subTracks.value}" dccId="${sub.dCCid}"/>
            </td>
            </tr>
            </table>
            </c:if>
         </c:forEach>

<%-- REPOSITORY --%>

<span class="filelink">

<c:forEach items="${subRep}" var="rep" varStatus="rep_status">
   <c:if test="${rep.key == sub.dCCid}">
      <br>
      <c:forEach items="${rep.value}" var="aRef" varStatus="ref_status" begin="0" end="5">


         <c:if test="${ref_status.count < 6}">
         ${aRef[0]}:
            <c:choose>
            <c:when test="${fn:startsWith(aRef[1],'To ')}">
                 ${aRef[1]}
            </c:when>
            <c:otherwise>
                 <a href="${aRef[2]}"
                 title="see ${aRef[1]} in ${aRef[0]} repository" class="value extlink">
                 <c:out value="${aRef[1]}" /> </a>
            </c:otherwise>
            </c:choose>
            <br></br>
         </c:if>

         <c:if test="${ref_status.count == 6}">
       <im:querylink text="...All entries in public repositories generated by this submission" skipBuilder="true" title="View all submissions to public repositories (AE, GEO, SRA) for this experiment">
<query name="" model="genomic" view="Submission.DCCid Submission.databaseRecords.database Submission.databaseRecords.accession Submission.databaseRecords.url" sortOrder="Submission.DCCid asc">
  <node path="Submission" type="Submission">
  </node>
  <node path="Submission.DCCid" type="Integer">
    <constraint op="=" value="${sub.dCCid}" description="" identifier="" code="A">
    </constraint>
  </node>
</query>
     </im:querylink>
<br></br>
         </c:if>

    </c:forEach>
  </c:if>
</c:forEach>
          </span>


<%-- FILES --%>
<span class="filelink">
<c:forEach items="${files}" var="subFiles" varStatus="sub_status">
  <c:if test="${subFiles.key == sub.dCCid}">
    <mm:dataFiles files="${subFiles.value}" dccId="${sub.dCCid}" />
  </c:if>
</c:forEach>
</span>

</td>
  </tr>
  </c:forEach>
  </table>
</div>
</im:boxarea>

</c:forEach>
</div>
<!-- /experiment.jsp -->