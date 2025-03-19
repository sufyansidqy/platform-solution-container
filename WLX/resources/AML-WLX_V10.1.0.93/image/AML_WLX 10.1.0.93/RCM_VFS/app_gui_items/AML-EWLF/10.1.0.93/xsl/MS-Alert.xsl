<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:param name="version"/>

<!-- Overriding texts variables to refer to CF text file only -->
<xsl:variable name="userTexts" select="document('xml/MS_texts.xml')/texts"/>
<xsl:variable name="texts" select="document('xml/MS_defaultTexts.xml')/texts"/>
<xsl:variable name="sectionInfo" select="document('xml/MS_FieldOrder.xml')/fields"/>
<xsl:variable name="optionalConfig" select="document('xml/OptionalConfig.xml')/optional_config"/>
<xsl:variable name="msgStruct" select="/enrichedAlert/content/alert/alert-header/elem[@name='msgStruct']"/>
<xsl:variable name="totalHits" select="count(/enrichedAlert/content/alert/hits/elem[@name = 'hit'])"/>
<xsl:variable name="rootDocument" select="/enrichedAlert"/>
<xsl:variable name="renderMode" select="'screen'"/>
<xsl:output method="html"/>

<xsl:include href="xsl/texts.xsl"/>
<xsl:include href="xsl/common.xsl"/>
<xsl:include href="xsl/AlertHeader-struct.xsl"/>
<xsl:include href="xsl/AlertHeader-swift.xsl"/>
<xsl:include href="xsl/AlertHeader-swiftmx.xsl"/>
<xsl:include href="xsl/AlertDetail.xsl"/>
<xsl:include href="xsl/HitHeader.xsl"/>
<xsl:include href="xsl/HitDetail.xsl"/>
<xsl:include href="xsl/HitAddlDetail.xsl"/>

<xsl:template match="/">
	<!--
	<xsl:message>+++++++++++++++++++++ START MS-Alert.xsl +++++++++++++++++++++++++</xsl:message>
	-->
	<head>
		<xsl:call-template name="writeJSFuncs"/>
	</head>
	<body style="font-size: 12pt;" id="alertDisplayBody" onload="resizeAlertWindow({$optionalConfig/message_view_transpose/is_active})">
		<xsl:variable name="headerWidthPct">
			<xsl:choose>
				<xsl:when test="$optionalConfig/message_view_transpose/is_active = 'true'">
					<xsl:value-of select="$optionalConfig/message_view_transpose/header_width_pct"/>
				</xsl:when>
				<xsl:otherwise>100</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<table style="width:100%; border-collapse: collapse; border-spacing: 0px; padding: 0px"><tr><td style="width={$headerWidthPct}%; vertical-align=top">
		<div id="alertHeaderDivId">
			<input type="hidden" name="alertId" id="alertId">
				<xsl:attribute name="value"><xsl:value-of select="/enrichedAlert/@id"/></xsl:attribute>
			</input>
			<input type="hidden" name="cfElimState" id="cfElimState">
				<xsl:attribute name="value"><xsl:value-of select="/enrichedAlert/attributes/attribute[@property = 'acm_alert_custom_attributes.csm11']/value"/></xsl:attribute>
			</input>
			
			<xsl:apply-templates select="/enrichedAlert/content/alert/alert-header" mode="getAlertHeader"></xsl:apply-templates>
		</div>
		<xsl:if test="$optionalConfig/message_view_transpose/is_active = 'true'">
			<xsl:text disable-output-escaping="yes"><![CDATA[</td><td style="vertical-align=top"]]></xsl:text>
		</xsl:if>
		<div id="alertHitsDivId">		
			<div id="sortHitDiv" class="sortHitDiv">
				<xsl:apply-templates select="$texts/hits/sortHitsBy" mode="getText"/>&#160;&#160;
				<select name="sortHitBy" onchange="sortHits(this.value)">
					<option value="score"><xsl:apply-templates select="$texts/hits/sortByHitScore" mode="getText"/></option>
					<option value="viewed"><xsl:apply-templates select="$texts/hits/sortByViewedHits" mode="getText"/></option>
				</select>
			</div>
			<div id="hitsDiv" style="overflow-y:scroll; overflow-x:hidden; align:center; border: 1px solid #dddddd; font-size: 12px; height: 60vh;">
				<xsl:for-each select="/enrichedAlert/content/alert/hits/elem[@name = 'hit']">
					<xsl:call-template name="getHitBody"/>
				</xsl:for-each>
			</div>
			<script language="javascript">
			    sortHits('score');
			    highlighter.process();
				restoreEliminatedStates();
			</script>
		</div>
		<xsl:if test="$optionalConfig/message_view_transpose/is_active = 'true'">
			<xsl:text disable-output-escaping="yes"><![CDATA[</td></tr><tr><td colspan="2">]]></xsl:text>
		</xsl:if>
		<div id="relatedAlerts">
			<xsl:choose>
				<xsl:when test="$optionalConfig/message_related_alerts/is_active = 'true'">
					<div class="clsGridTableBase clsGridTableBackground">
						<table class="clsGridTableBase pluginDataTable" width="100%">
							<tr class="clsGridHeaderRow">
								<td class="clsGridHeaderCell clsGridCellBase">Related Alerts</td>
							</tr>
							<tr>
								 <td class="clsGridUnreadRow bottomBorder">
								 	<xsl:variable name="widgetHeightPx" select="$optionalConfig/message_related_alerts/widget_height_px"/>
								 	<div id="relatedAlertsData" style="height: {$widgetHeightPx}px" />
								 	<script language="javascript">
								 		var relatedAlertsWidget = new RCMAPI.WorkItemsWidget ('relatedAlertsWidget', 'relatedAlertsData',
								 		{
								 			pagingSize: 10,
								 			disableFilterByExample: true,
								 			preventNewConditions: true,
								 			showBaseQueryConditions: false,
								 			showRefreshButton: false,
								 			showResetButton: false,
								 			showExportButton: false,
								 			viewIdentifier: '<xsl:value-of select="$optionalConfig/message_related_alerts/alert_view"/>',
								 			ddqIdentifier: '<xsl:value-of select="$optionalConfig/message_related_alerts/data_source_identifier"/>',
								 			ddqParamValues: '<xsl:value-of select="enrichedAlert/@id"/>'
								 		});
								 		relatedAlertsWidget.draw();
								 	</script>
								 </td>
							</tr>
						</table>
					</div>
				</xsl:when>
			<xsl:otherwise>
		<xsl:if test="/enrichedAlert/content/alert/alert-header/elem[@name = 'partyKey'] != 'N/A' and /enrichedAlert/content/alert/alert-header/elem[@name = 'partyKey'] != ''" >
	        <table id="alertButtonsOuterTable" style="width:100%;margin-left:0px;"  border="0" cellpadding="0" cellspacing="0" valign="top" bgcolor="#EBECEE">
	                <tr id="buttonsRow">
	                        <td>
	                                <table cellpadding="0" cellspacing="0"  width="100%" border="0">
	                                        <tr>
	                                                <td>
	                                                        <table border="0" >
	                                                                <tr class="infotitle">
	                                                                        <!-- Prior Alerts -->
	                                                                        <td style="padding-right:10px;">
	                                                                                <div class="drill">
	                                                                                        <a class="drill">
																								    <xsl:attribute name="href"><xsl:text>javascript:RCMAPI.jumpToDynamicAlerts('ACT_EWLF_priorAlertsQuery',</xsl:text><xsl:text>'@@</xsl:text><xsl:value-of select="/enrichedAlert/content/alert/alert-header/elem[@name = 'partyKey']"/><xsl:text>@@</xsl:text><xsl:value-of select="substring(/enrichedAlert/@alertDate, 1, 19)"/><xsl:text>@@</xsl:text><xsl:text>AML-EWLF','','','');</xsl:text></xsl:attribute>
	                                                                                                <span style="height:16px;width:16px;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='app_gui_items/{$version}\images\table_sql_view.png');"/>
																								&#160;<xsl:apply-templates mode="getText" select="$texts/buttons/priorAlerts"/>&#160;
	                                                                                        </a>
	                                                                                </div>
	                                                                        </td>
	                                                                </tr>
	                                                        </table>
	                                                </td>
	                                        </tr>
	                                </table>
	                        </td>
	                </tr>
	        </table>
    </xsl:if>
    </xsl:otherwise>
    </xsl:choose>
    </div>
    </td></tr></table>	
	</body>
	<!--
	<xsl:message>+++++++++++++++++++++  END MS-Alert.xsl +++++++++++++++++++++++++</xsl:message>
	-->
</xsl:template>

<xsl:template match="*" mode="getAlertHeader">
	<xsl:if test="$msgStruct = 'STRUCTURED'">
		<xsl:call-template name="writeAlertHeaderStructured" />
		<br/>
		<xsl:call-template name="writeAlertDetails" />
	</xsl:if>
	<xsl:if test="$msgStruct = 'SWIFT'">
		<xsl:call-template name="writeAlertHeaderSwift" />
		<br/>
		<xsl:call-template name="writeAlertDetails" />
	</xsl:if>
	<xsl:if test="$msgStruct = 'SWIFTMX'">
		<xsl:call-template name="writeAlertHeaderSwiftMX" />
		<br/>
	</xsl:if>
</xsl:template>
<xsl:template name="getHitBody">
	<div class="hitBody" >
		<xsl:attribute name="id">hitDiv<xsl:value-of select="position()"/></xsl:attribute>
		<input type="hidden" name="hitExpanded" value="false">
			<xsl:attribute name="name">hitExpanded<xsl:value-of select="position()"/></xsl:attribute>
		</input>
		<xsl:call-template name="writeHitHeader">
			<xsl:with-param name="hitCnt" select="position()"/>
			<xsl:with-param name="hitElem" select="."/>
		</xsl:call-template>
		<div>
			<xsl:attribute name="id">hitDetDiv<xsl:value-of select="position()"/></xsl:attribute>
			<input type="hidden">
				<xsl:attribute name="name">hit<xsl:value-of select="position()"/>score</xsl:attribute>
				<xsl:attribute name="value"><xsl:value-of select="elem[@name = 'score']"/></xsl:attribute>
			</input>
			<xsl:call-template name="writeHitDetails">
				<xsl:with-param name="hitElem" select="."/>
			</xsl:call-template>
			<xsl:call-template name="writeHitAddlDetails">
				<xsl:with-param name="hitCnt" select="position()"/>
				<xsl:with-param name="hitElem" select="."/>
			</xsl:call-template>
		</div>
	</div>
	<br/>
</xsl:template>
<xsl:template name="writePartyCustomFields">
</xsl:template>
<xsl:template name="writeJSFuncs">
<link rel="stylesheet" href="app_gui_items/{$version}/css/wlfAlert.css" type="text/css"></link>
<script src="app_gui_items/{$version}/js/wlfAlertsHighlighter.js" type="text/javascript"></script>
<script src="app_gui_items/{$version}/js/wlfUtil.js" type="text/javascript"></script>
<script language="javascript">
	var alertDetExpanded = false;
	var t;
	var origHt;
	var animOn = false;
	var htDecr;
	var frames = 25;
	var totHits = <xsl:value-of select="$totalHits"/>;
	var hitUtils = new HitUtils(totHits,'<xsl:apply-templates select="$texts/hits/hit" mode="getText"/>')
	
/*	function restoreEliminatedStates() {
		var elimState = document.getElementById('cfElimState').value;
		var elimArr = elimState.split(",");
		for(i=0; i&lt;elimArr.length; i++) {
			var tempArr = elimArr[i].split("-");
			if(tempArr[1] == "true") {
				document.getElementById('hitElemChk' + tempArr[0]).checked = true;
				document.getElementById('hitDetDiv' + tempArr[0]).style.display = "none";
			}
		}
	}
*/
	function padLeftTo(string, padChar, numChars) {
	    return (new Array(numChars - string.length + 1)).join(padChar) + string;
	}

	function unicodeToBinary(char) {
		var charArr = char.split('');
		var elimStateBin = '';
		for(i=0; i&lt;charArr.length; i++) {
			var c = charArr[i].charCodeAt(0) - 48;
			c = padLeftTo(c.toString(2), 0, 6);
			elimStateBin = elimStateBin + c;
		}     
		return elimStateBin;
	}
	
	function restoreEliminatedStates() {
		var elimStateChar = document.getElementById('cfElimState').value;
		var elimState = unicodeToBinary(elimStateChar);
        //alert(elimState);
		var elimArr = elimState.split("");
		try {
			for(i=0; i&lt;elimArr.length; i++) {
				if(elimArr[i] == "1") {
			    	var ii = i+1;
					document.getElementById('hitElemChk' + ii).setAttribute("checked", "");
					document.getElementById('hitElemChk' + ii).checked = true;
					document.getElementById('hitDetDiv' + ii).style.display = "none";
				}
			}
		} catch(err) {
		}
	}	

	function expandAlertDetail() {
		if(!alertDetExpanded) {
			document.getElementById('alertDetailDiv').style.display = "block";
			document.getElementById('1_ICON').src = "images/minus.gif";
		} else {
			document.getElementById('alertDetailDiv').style.display = "none";
			document.getElementById('1_ICON').src = "images/plus.gif";
		}
		alertDetExpanded = !alertDetExpanded;
	}

	function expandHitDetail(idx) {
	     var hitExp = document.getElementsByName('hitExpanded' + idx)[0];
	     if(hitExp.value == "false") {
	         document.getElementById('hitAddlDet' + idx).style.display = "block";
		     document.getElementById('hit_' + idx + '_ICON').src = "images/minus.gif";
	   		 hitExp.value = "true";
		} else {
			document.getElementById('hitAddlDet' + idx).style.display = "none";
			document.getElementById('hit_' + idx + '_ICON').src = "images/plus.gif";
			hitExp.value = "false";
		}
	}
	
	function hitViewed(idx, chk) {
		if(chk) {
			document.getElementById('hitDetDiv' + idx).style.display = "none";
			document.getElementById('hitElemChk' + idx).setAttribute("checked", "");
			document.getElementById('hitElemChk' + idx).checked = true;
			} else {
			document.getElementById('hitDetDiv' + idx).style.display = "block";
			document.getElementById('hitElemChk' + idx).checked = false;
			document.getElementById('hitElemChk' + idx).removeAttribute("checked");
		}
		saveEliminatedState(': Hit #'+ idx + ' changed to ' + chk);		
	}
	
/*	function saveEliminatedState() {
		var aid = document.getElementById('alertId').value;
		var elimState = "";
		for(i=1; i&lt;=totHits; i++) {
			elimState = elimState + i + "-" + document.getElementById('hitElemChk' + i).checked;
			if (i &lt; totHits) {
				elimState = elimState + ",";
			}
		}
	 	var ajaxUrl = "plugin?plugin=wlf-ondemand-search-plugin&amp;module=alertService&amp;page=eliminatedHit&amp;alertId=" + aid + "&amp;val=" + elimState + "&amp;123";
		//document.getElementById("scInfoId").innerHTML = "$pluginLiterals.get('common_literal_loading_msg')";
	 	com.actimize.http.HTTPSender.sendPostRequest(ajaxUrl, parseAlertResp);
	}
*/
	function binaryToUnicode(binaryList) {
		var codepointsAsNumbers = [];
		var bLength = binaryList.length;
		while (bLength%6 != 0) {
			binaryList = binaryList + "0";
			bLength = binaryList.length;
		}
		while (binaryList.length > 0) {
			var codepointBits = binaryList.slice(0, 6);
			binaryList = binaryList.slice(6);
			codepointsAsNumbers.push(parseInt(codepointBits, 2) + 48);
		}
		return String.fromCharCode.apply(this, codepointsAsNumbers);
	}

	function saveEliminatedState(AddTextAudit) {
		var aid = document.getElementById('alertId').value;
		var elimState = "";
		var codedElimState = "";
		for(i=1; i&lt;=totHits; i++) {
		    if (document.getElementById('hitElemChk' + i).checked)
			  elimState = elimState + "1";
			else
			  elimState = elimState + "0";
		}
		codedElimState = binaryToUnicode(elimState);
	 	//var ajaxUrl = "plugin?plugin=wlf-ondemand-search-plugin&amp;module=alertService&amp;page=eliminatedHit&amp;alertId=" + aid + "&amp;val=" + codedElimState + "&amp;123";
	    var ajaxUrl = "plugin?plugin=wlf-ondemand-search-plugin&amp;module=alertService&amp;page=eliminatedHit&amp;alertId=" + aid + "&amp;val=" + escape(codedElimState) + "&amp;addText=" + escape(AddTextAudit) + "&amp;123";
		//document.getElementById("scInfoId").innerHTML = "$pluginLiterals.get('common_literal_loading_msg')";
	 	com.actimize.http.HTTPSender.sendPostRequest(ajaxUrl, parseAlertResp);
	}
	
	function parseAlertResp(r) {
	}
	
	function sortHits(sortby) {
		if(sortby == "score") {
			hitUtils.sortByScore();
		} else if(sortby == "viewed") {
			hitUtils.sortByViewed();
		}
	}
	
	/* This functionality has been moved to wlfUtil.js - HitUtils
	function sortHitsByScore() {
		var hitScoreArray = new Array();
		for(var i=1; i&lt;=totHits; i++) {
			hitScoreArray[i-1] = i + "-" + document.getElementById('hit' + i + 'score').value; 
		}
		hitScoreArray.sort(sortNums);
		rearrangeSortedHits(hitScoreArray,totHits,'<xsl:apply-templates select="$texts/hits/hit" mode="getText"/>');
	}
	
	function sortHitsByViewed() {
		var hitScoreArray = new Array();
		for(var i=1; i&lt;=totHits; i++) {
			hitScoreArray[i-1] = i + "-" + document.getElementById('hitElemChk' + i).checked; 
		}
		hitScoreArray.sort(sortEliminated);
		rearrangeSortedHits(hitScoreArray,totHits,'<xsl:apply-templates select="$texts/hits/hit" mode="getText"/>');
	}
	
	function rearrangeSortedHits(hitScoreArray) {
		var strHtml = "";
		for(i=0; i &lt; totHits; i++) {
			var hid = hitScoreArray[i].split("-")[0];
			var tmpHtml = document.getElementById('hitDiv' + hid).outerHTML;
			//var configuredHitHeader = '<xsl:apply-templates select="$texts/hits/hit" mode="getText"/>';
			var configuredHitHeader = 'Hit';
			var ndx1 = tmpHtml.indexOf(configuredHitHeader+'<xsl:text disable-output-escaping="yes">&amp;</xsl:text>&#160; #');
			var ndx2 = tmpHtml.indexOf(' :');
			if (ndx1 != -1 &amp;&amp; ndx2 != -1) {
				tmpHtml = tmpHtml.substring(0,ndx1+configuredHitHeader.length+8) + String(i+1) + tmpHtml.substring(ndx2);
			}
			strHtml += tmpHtml + "<br/>";
		}
		document.getElementById('hitsDiv').innerHTML = "";
		document.getElementById('hitsDiv').innerHTML = strHtml;
	}
	
	function sortNums(a, b) {
		var n1 = a.split("-")[1];
		var n2 = b.split("-")[1];
		return n2 - n1;
	}
	function sortEliminated(a, b) {
		var n1 = a.split("-")[1];
		var n2 = b.split("-")[1];
		if(n1 == "false" &amp;&amp; n2 == "true") {
			return -1;
		}
		if(n1 == "true" &amp;&amp; n2 == "false") {
			return 1;
		}
		return 0;
	}*/
	
</script>
</xsl:template>

</xsl:stylesheet>
