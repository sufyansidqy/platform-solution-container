<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:template name="writeHitAddlDetails">
		<xsl:param name="hitCnt"/>
		<xsl:param name="hitElem"/>
		<div id="hitDetPlusDiv" class="clsGridHeaderCell clsGridHeaderRow">
			<xsl:if test="$renderMode = 'screen'">
				<img width="17" height="17" style="cursor: hand; vertical-align: middle;" src="images/plus.gif" border="0" complete="complete">
					<xsl:attribute name="onclick">expandHitDetail('<xsl:value-of select="$hitCnt"/>')</xsl:attribute>
					<xsl:attribute name="id">hit_<xsl:value-of select="$hitCnt"/>_ICON</xsl:attribute>
				</img>		
			</xsl:if>
			&#160;&#160;<xsl:apply-templates select="$texts/hits/addl-hit-title" mode="getText"/>
		</div>		
		<div>
			<xsl:if test="$renderMode = 'screen'">
				<xsl:attribute name="style">display: none;</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="id">hitAddlDet<xsl:value-of select="$hitCnt"/></xsl:attribute>

			<xsl:for-each select="$sectionInfo/hit-addl-detail/field-section">
				<xsl:variable name="secName" select="@labelKey"/>
				
					<table width="100%" class="detailsList">
						<xsl:if test="$secName != ''">
							<tr>
								<td  style="background-color:#ebecee; font-weight:bold; padding: 3px;">
									<xsl:apply-templates select="$texts/hits/*[name() = $secName]" mode="getText"/>&#160;
								</td>
							</tr>
						</xsl:if>
						<tr>
							<td>
								<xsl:call-template name="setSection">
									<xsl:with-param name="setName" select="@set"/>
									<xsl:with-param name="hitElem" select="$hitElem"/>
								</xsl:call-template>
							</td>
						</tr>
					</table>
			</xsl:for-each>
		</div>
	</xsl:template>
</xsl:stylesheet>