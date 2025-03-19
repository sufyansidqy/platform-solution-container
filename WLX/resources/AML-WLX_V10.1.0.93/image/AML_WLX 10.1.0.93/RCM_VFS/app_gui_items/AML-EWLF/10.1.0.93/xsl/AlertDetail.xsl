<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:template name="writeAlertDetails">
		<div id="alertDetPlusDiv" class="clsGridHeaderCell clsGridHeaderRow">
			<xsl:if test="$renderMode = 'screen'">
				<img width="17" height="17" id="1_ICON" style="cursor: hand; vertical-align: middle;" onclick="expandAlertDetail()" src="images/plus.gif" border="0" complete="complete"/>
				&#160;&#160;
			</xsl:if>
			<xsl:apply-templates select="$texts/alertHighlights/title" mode="getText"/>
		</div>
		<div class="clsGridTableBase clsGridTableBackground" id="alertDetailDiv">
			<xsl:if test="$renderMode = 'screen'">
				<xsl:attribute name="style">display: none;</xsl:attribute>
			</xsl:if>
			<xsl:for-each select="$sectionInfo/alert-detail/field-group">
				<xsl:variable name="secTitle" select="@labelKey"/>
				<xsl:variable name="colNums" select="number(@cols)"/>
				<xsl:variable name="colspn" select="number($colNums * 2)"/>
					<table width="100%" class="clsGridTableBase pluginDataTable">
						<tr class="clsGridHeaderRow">
							<td class="clsGridHeaderCell clsGridCellBase">
								<xsl:attribute name="colspan"><xsl:value-of select="$colspn"/></xsl:attribute>
								<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
							</td>
						</tr>
						<xsl:for-each select="row">
							<tr>
								<xsl:call-template name="alertDetailField">
									<xsl:with-param name="colw" select="number(100 div $colspn)"/>
								</xsl:call-template>
							</tr>
						</xsl:for-each>
					</table>
			</xsl:for-each>
			<xsl:for-each select="$sectionInfo/alert-detail/field-section">
				<xsl:variable name="secName" select="@labelKey"/>
				<div>
				<table width="100%" class="detailsList">
					<xsl:if test="$secName != ''">
						<tr>
							<td style="background-color:#ebecee; font-weight:bold; padding: 3px;">
								<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secName]" mode="getText"/>&#160;
							</td>
						</tr>
					</xsl:if>
					<tr>
						<td>
							<xsl:call-template name="setAlertSection">
								<xsl:with-param name="setName" select="@set"/>
							</xsl:call-template>
						</td>
					</tr>
					</table>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>
	<xsl:template name="alertDetailField">
		<xsl:param name="colw"/>
		<xsl:for-each select="field">
			<xsl:variable name="fldKey" select="."/>
		<td class="clsGridUnreadRow bottomBorder">
			<xsl:attribute name="width"><xsl:value-of select="number($colw - 10)"/>%</xsl:attribute>
			<xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/>
		</td>
		<td class="bottomBorder rightBorder">
			<xsl:attribute name="width"><xsl:value-of select="number($colw + 10)"/>%</xsl:attribute>
			<xsl:variable name="value" select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/>
			<xsl:choose>
				<xsl:when test="string($value) = ''">
					<xsl:variable name="value1" select="$rootDocument/content/alert/alert-header/elem/elem[@name = $fldKey]"/>
		            <span>
						<xsl:attribute name="id">
							<xsl:value-of select="$fldKey"/>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="$fldKey = 'jobType'">
								<xsl:apply-templates select="$value1" mode="getJobTypes"/>
							</xsl:when>
							<xsl:when test="$fldKey = 'partyType'">
								<xsl:apply-templates select="$value1" mode="getEntityTypes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$value1"/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<xsl:if test="$inputMatches = $value">
						<script language="javascript">
							highlighter.register(new FullFieldHighlighter('<xsl:value-of select="$fldKey"/>'));
						</script>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
		            <span>
						<xsl:attribute name="id">
							<xsl:value-of select="$fldKey"/>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="$fldKey = 'jobType'">
								<xsl:apply-templates select="$value" mode="getJobTypes"/>
							</xsl:when>
							<xsl:when test="$fldKey = 'entryType'">
								<xsl:apply-templates select="$value" mode="getEntityTypes"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$value"/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<xsl:if test="$inputMatches = $value">
						<script language="javascript">
							 highlighter.register(new FullFieldHighlighter('<xsl:value-of select="$fldKey"/>'));
						</script>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</td>
		</xsl:for-each>
		 <!--  <script language="javascript">
			highlighter.process();
		</script> -->
	</xsl:template>
	<xsl:template name="setAlertSection">
		<xsl:param name="setName"/>
		<xsl:if test="$setName = 'partyCustomFields'">
			<xsl:call-template name="writePartyCustomFields"/>
		</xsl:if>
	</xsl:template>	
</xsl:stylesheet>