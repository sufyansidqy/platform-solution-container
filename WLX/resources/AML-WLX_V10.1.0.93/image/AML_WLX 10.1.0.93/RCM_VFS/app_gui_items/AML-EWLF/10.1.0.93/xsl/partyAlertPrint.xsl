<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:param name="version"/>

<!-- Overriding texts variables to refer to CF text file only -->
<xsl:variable name="userTexts" select="document('xml/CF_texts.xml')/texts"/>
<xsl:variable name="texts" select="document('xml/CF_defaultTexts.xml')/texts"/>
<xsl:variable name="sectionInfo" select="document('xml/CF_FieldOrder.xml')/fields"/>
<xsl:variable name="msgStruct" select="/enrichedAlert/content/alert/alert-header/elem[@name='msgStruct']"/>
<xsl:variable name="totalHits" select="count(/enrichedAlert/content/alert/hits/elem[@name = 'hit'])"/>
<xsl:variable name="rootDocument" select="/enrichedAlert"/>
<xsl:variable name="renderMode" select="'print'"/>
<xsl:output method="html"/>

<xsl:include href="xsl/CF-texts.xsl"/>
<xsl:include href="xsl/AlertHeader-CF.xsl"/>
<xsl:include href="xsl/AlertDetail.xsl"/>
<xsl:include href="xsl/HitHeader.xsl"/>
<xsl:include href="xsl/HitDetail.xsl"/>
<xsl:include href="xsl/HitAddlDetail.xsl"/>

<xsl:template match="/">
	<head>
		<xsl:call-template name="writeJSFuncs"/>
	</head>
	<body style="font-size: 12pt;">
		<input type="hidden" name="alertId" id="alertId">
			<xsl:attribute name="value"><xsl:value-of select="/enrichedAlert/@id"/></xsl:attribute>
		</input>
		<input type="hidden" name="cfElimState" id="cfElimState">
			<xsl:attribute name="value"><xsl:value-of select="/enrichedAlert/attributes/attribute[@property = 'acm_alert_custom_attributes.csm11']/value"/></xsl:attribute>
		</input>
		
		<xsl:apply-templates select="/enrichedAlert/content/alert/alert-header" mode="getAlertHeader"></xsl:apply-templates>
		<div id="sortHitDiv" style="width:98%; text-align:right; background-color:#c0c0ff;">
			&#160;
		</div>
		<div id="hitsDiv" style="width:98%; align:center; border: 1px solid #dddddd; font-size: 12px;">
			<xsl:for-each select="/enrichedAlert/content/alert/hits/elem[@name = 'hit']">
				<xsl:sort select="elem[@name = 'score']" data-type="number" order = "descending" />
				<xsl:call-template name="getHitBody"/>
			</xsl:for-each>
		</div>
		<script language="javascript">
			restoreEliminatedStates();
			<!-- sortHitsByScore(); -->
		</script>
	</body>
</xsl:template>

<xsl:template match="*" mode="getAlertHeader">
	<xsl:call-template name="writeAlertHeaderCF" />
	<br/>
	<xsl:call-template name="writeAlertDetails" />
</xsl:template>
<xsl:template name="getHitBody">
	<div style="border:1px solid #c0c0ff; width: 100%;">
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
	<xsl:if test="/enrichedAlert/content/alert/alert-header/elem[@name = 'alertEntityKey'] != 'N/A' and /enrichedAlert/content/alert/alert-header/elem[@name = 'alertEntityKey'] != ''" >  
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
													<xsl:attribute name="href"><xsl:text>javascript:RCMAPI.jumpToDynamicAlerts('ACT_EWLF_priorAlertsQuery',</xsl:text><xsl:text>'@@</xsl:text><xsl:value-of select="/enrichedAlert/content/alert/alert-header/elem[@name = 'alertEntityKey']"/><xsl:text>@@</xsl:text><xsl:value-of select="substring(/enrichedAlert/@alertDate, 1, 19)"/><xsl:text>@@</xsl:text><xsl:text>AML-EWLF','','','');</xsl:text></xsl:attribute>
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
</xsl:template>
<xsl:template name="writeJSFuncs">
<link rel="stylesheet" href="app_gui_items/{$version}/css/wlfAlert.css" type="text/css"></link>
<script src="app_gui_items/{$version}/js/wlfAlertsHighlighter.js" type="text/javascript"></script>
<style type="text/css">
.score_LOW {
	text-align:center;
	background-color:#ffffff;
	font-weight:bold;
	color:green;
}
.score_MEDIUM {
	text-align:center;
	background-color:#ffffff;
	font-weight:bold;
	color:orange;
}
.score_HIGH {
	text-align:center;
	background-color:#ffffff;
	font-weight:bold;
	text-decoration:underline;
	color:red;
}
.score_CORRECTIVE {
	text-align:center;
	background-color:#ffffff;
	font-weight:bold;
	color:blue;
}
td {
	font-size: 11px;
	color: #000000;
}
.graycell {
	background-color:#ebecee;
	font-weight:bold;
	text-align:center;
	padding: 3px;
	border-right: 1px dotted gray;
	border-bottom: 1px dotted gray;
}
.datacell {
	padding: 3px;
	border-right: 1px dotted gray;
	border-bottom: 1px dotted gray;
}
</style>
<script language="javascript">
	var alertDetExpanded = false;
	var t;
	var origHt;
	var animOn = false;
	var htDecr;
	var frames = 25;
	var totHits = <xsl:value-of select="$totalHits"/>;
	
/*	function restoreEliminatedStates() {
		var elimState = document.getElementById('cfElimState').value;
		var elimArr = elimState.split(",");
		for(i=0; i&lt;elimArr.length; i++) {
			var tempArr = elimArr[i].split("-");
			if(tempArr[1] == "true") {
				document.getElementById('hitElemChk' + tempArr[0]).checked = true;
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
		for(i=0; i&lt;elimArr.length; i++) {
			if(elimArr[i] == "1") {
			    var ii = i+1;
				document.getElementById('hitElemChk' + ii).checked = true;
				document.getElementById('hitDetDiv' + ii).style.display = "none";
			}
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
		if(hitExp == "false") {
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
		} else {
			document.getElementById('hitDetDiv' + idx).style.display = "block";
		}
		saveEliminatedState();		
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

	function saveEliminatedState() {
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
	 	var ajaxUrl = "plugin?plugin=wlf-ondemand-search-plugin&amp;module=alertService&amp;page=eliminatedHit&amp;alertId=" + aid + "&amp;val=" + codedElimState + "&amp;123";
		//document.getElementById("scInfoId").innerHTML = "$pluginLiterals.get('common_literal_loading_msg')";
	 	com.actimize.http.HTTPSender.sendPostRequest(ajaxUrl, parseAlertResp);
	}
	
	function parseAlertResp(r) {
	}
	
	function sortHits(sortby) {
		if(sortby == "score") {
			sortHitsByScore();
		} else if(sortby == "viewed") {
			sortHitsByViewed();
		}
	}
	
	function sortHitsByScore() {
		var hitScoreArray = new Array();
		for(var i=1; i&lt;=totHits; i++) {
			hitScoreArray[i-1] = i + "-" + document.getElementById('hit' + i + 'score').value; 
		}
		hitScoreArray.sort(sortNums);
		rearrangeSortedHits(hitScoreArray);
	}
	
	function sortHitsByViewed() {
		var hitScoreArray = new Array();
		for(var i=1; i&lt;=totHits; i++) {
			hitScoreArray[i-1] = i + "-" + document.getElementById('hitElemChk' + i).checked; 
		}
		hitScoreArray.sort(sortEliminated);
		rearrangeSortedHits(hitScoreArray);
	}
	
	function rearrangeSortedHits(hitScoreArray) {
		var strHtml = "";
		for(i=0; i&lt;totHits; i++) {
			var hid = hitScoreArray[i].split("-")[0];
			strHtml += document.getElementById('hitDiv' + hid).outerHTML + "<br/>";
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
	}
	
</script>
</xsl:template>

</xsl:stylesheet>
