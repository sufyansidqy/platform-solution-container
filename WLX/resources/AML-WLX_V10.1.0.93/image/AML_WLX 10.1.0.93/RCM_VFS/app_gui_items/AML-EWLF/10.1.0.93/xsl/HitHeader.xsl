<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:template name="writeHitHeader">
		<xsl:param name="hitCnt"/>
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$sectionInfo/hit-header/field-group">
			<xsl:variable name="colNums" select="number(@cols)"/>
			<xsl:variable name="colspn" select="number($colNums * 2)"/>
			<div style="background-color:#eeeeef">
			<table width="100%" class="clsGridTableBase pluginDataTable">
				<tr class="clsGridHeaderRow">
					<td class="clsGridHeaderCell clsGridCellBase" colspan="2">
					<xsl:apply-templates select="$texts/hits/hit" mode="getText"/>&#160;
						#<xsl:value-of select="$hitCnt"/> : 
						<!-- <xsl:value-of select="$hitElem/elem[@name = 'displayName']"/> -->
						<xsl:call-template name="checkHeaderHighlightsForName2">
							<xsl:with-param name="matchValue" select="$hitElem/elem[@name = 'matchedName']"/>
							<xsl:with-param name="value" select="$hitElem/elem[@name = 'displayName']"/>
							<xsl:with-param name="hit" select="$hitElem"/>
						</xsl:call-template>
					</td>
					<td class="clsGridHeaderCell clsGridCellBase" colspan="1" align="right">
						<xsl:attribute name="colspan"><xsl:value-of select="number($colspn - 1)"/></xsl:attribute>
						<input type="checkbox" name="viewedHitChk" value="1">
							<xsl:attribute name="onclick">hitViewed('<xsl:value-of select="$hitCnt"/>', this.checked)</xsl:attribute>
							<xsl:if test="$renderMode != 'screen'">
								<xsl:attribute name="disabled">true</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="id">hitElemChk<xsl:value-of select="$hitCnt"/></xsl:attribute>
						</input>
						&#160;
						<xsl:apply-templates select="$texts/hits/viewedHit" mode="getText"/>
					</td>
				</tr>
				<xsl:call-template name="hitHeaderRow">
					<xsl:with-param name="hitElem" select="$hitElem"/>
					<xsl:with-param name="colw" select="number(100 div $colspn)"/>
				</xsl:call-template>
			</table>
			</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="hitHeaderRow">
		<xsl:param name="hitElem"/>
		<xsl:param name="colw"/>
		<xsl:for-each select="row">
			<tr>
				<xsl:call-template name="hitHeaderField">
					<xsl:with-param name="hitElem" select="$hitElem"/>
					<xsl:with-param name="colw" select="$colw"/>
				</xsl:call-template>
			</tr>
		</xsl:for-each>	
	</xsl:template>
	<xsl:template name="hitHeaderField">
		<xsl:param name="hitElem"/>
		<xsl:param name="colw"/>
		<xsl:for-each select="field">
			<xsl:variable name="fldKey" select="."/>
			<td class="clsGridUnreadRow bottomBorder">
				<xsl:attribute name="width"><xsl:value-of select="number($colw - 10)"/>%</xsl:attribute>
				<xsl:apply-templates select="$texts/hits/*[name() = $fldKey]" mode="getText"/>
			</td>
			<td class="bottomBorder rightBorder">
				<xsl:attribute name="width"><xsl:value-of select="number($colw + 10)"/>%</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$fldKey = 'categories'">
						<xsl:call-template name="writeCategories">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$fldKey = 'keywords'">
						<xsl:call-template name="writeKeywords">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$fldKey = 'nationalityCountries'">
					<!--xsl:when test="$fldKey = 'addresses_country'"-->
						<xsl:call-template name="writeNationalityCountries">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="checkHeaderHighlights">
						  <xsl:with-param name="value" select="$hitElem/elem[@name = $fldKey]"/>
						  <xsl:with-param name="hit" select="$hitElem"/>
						  <xsl:with-param name="fldKey" select="$fldKey"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeCategories">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$hitElem/elem[@name = 'categories']/elem[@name = 'category']">
			<xsl:value-of select="."/>;&#160;
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeKeywords">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$hitElem/elem[@name = 'keywords']/elem[@name = 'keyword']">
			<xsl:value-of select="."/>;&#160;
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeNationalityCountries">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$hitElem/elem[@name = 'nationalityCountries']/elem[@name = 'country']">
			<xsl:call-template name="checkHeaderHighlightsForName2">
				<xsl:with-param name="matchValue" select="."/>
	 	        <xsl:with-param name="value" select="."/>
				<xsl:with-param name="hit" select="$hitElem"/>
			</xsl:call-template>
			<!--xsl:value-of select="."/>;&#160;-->
		</xsl:for-each>
	</xsl:template>

     <xsl:template name="checkHeaderHighlights">
       <xsl:param name="value"/>
       <xsl:param name="hit"/>
       <xsl:param name="fldKey"/>
       <xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $value"/>
       <xsl:choose>
         <xsl:when test="$match">
	<font color="red">
		<xsl:choose>
			<xsl:when test="$fldKey = 'matchType'">
				<xsl:apply-templates select="$value" mode="getMatchTypes"/>
			</xsl:when>
			<xsl:when test="$fldKey = 'entryType'">
				<xsl:apply-templates select="$value" mode="getEntityTypes"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</font>
         </xsl:when>
         <xsl:otherwise>
	<xsl:choose>
		<xsl:when test="$fldKey = 'matchType'">
			<xsl:apply-templates select="$value" mode="getMatchTypes"/>
		</xsl:when>
		<xsl:when test="$fldKey = 'entryType'">
			<xsl:apply-templates select="$value" mode="getEntityTypes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$value"/>
		</xsl:otherwise>
	</xsl:choose>
       </xsl:otherwise>
       </xsl:choose>
     </xsl:template>
	<xsl:template name="checkHeaderHighlightsForNames">
		<xsl:param name="matchValue"/>
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="Explanation" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text()"/>
		<xsl:variable name="upperMatchValue" select="translate($matchValue, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		<xsl:variable name="upperExplanation" select="translate($Explanation, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		<xsl:variable name="match" select="$upperExplanation = $upperMatchValue"/>
		<!--    <xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $MatchValue"/> -->
		<xsl:choose>
			<xsl:when test="boolean($match)">
				<font color="red"><xsl:value-of select="$value"/></font>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	 <xsl:template name="checkHeaderHighlightsForName2">
		<xsl:param name="matchValue"/>
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="matchSplit" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $matchValue"/>
		<xsl:variable name="matchDisplay" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $value" />
		<xsl:choose>
			<xsl:when test="boolean($matchSplit) or boolean($matchDisplay)">
				<font color="red"><xsl:value-of select="$value"/></font><xsl:text>;&#160;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/><xsl:text>;&#160;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>


