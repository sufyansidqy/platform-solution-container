<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:internal="http://www.actimize.com/internal"
	exclude-result-prefixes="internal">

    <xsl:variable name="inputMatches" select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='inputExplanations']/elem/elem[@name='inputExplanation']/text()"/>
    <xsl:variable name="freeTextMatchFields" select="$rootDocument/content/alert/*/elem[@name='messageMatchPositions']/elem[@name='matchPositionAttribute']"/>
    <xsl:variable name="freeTextAttrMap" select="document('xml/FreeTextFields.xml')/freeTextFieldMap"/>
	<xsl:variable name="alertId" select="$rootDocument/@id"/>
	<xsl:template name="writeAlertHeaderStructured">
		<script language="javascript">
                	var highlighter = new InputFieldHighlighter();
		</script>
		<xsl:for-each select="$sectionInfo/alert-header/field-group">
			<xsl:variable name="secTitle" select="@labelKey"/>
			<xsl:variable name="colNums" select="number(@cols)"/>
			<xsl:variable name="colspn" select="number($colNums * 2)"/>
			<div class="clsGridTableBase clsGridTableBackground">
			<table width="100%" class="clsGridTableBase pluginDataTable">
				<tr class="clsGridHeaderRow">
					<td class="clsGridHeaderCell clsGridCellBase">
						<xsl:attribute name="colspan"><xsl:value-of select="$colspn"/></xsl:attribute>
						<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
					</td>
				</tr>
				<xsl:for-each select="row">
					<tr>
						<xsl:call-template name="alertHeaderField">
							<xsl:with-param name="colw" select="number(100 div $colspn)"/>
						</xsl:call-template>
					</tr>
				</xsl:for-each>
			</table>
			</div>
		</xsl:for-each>
		<script language="javascript">
      <xsl:for-each select="$freeTextMatchFields">
        var positionArray = new Array();
			  <xsl:for-each select="./elem[@name='position']">
          positionArray.push(new FreeTextFieldPositions(<xsl:value-of select="./elem[@name='begin']/text()"/>, <xsl:value-of select="./elem[@name='end']/text()"/>))
			  </xsl:for-each>
			  <xsl:variable name="attrKey" select="./elem[@name='matchField']/text()"/>
        <xsl:for-each select="$freeTextAttrMap/entry[@value=$attrKey]">
			<xsl:variable name="pre_fldKey">
				<xsl:value-of select="$alertId"/><xsl:text>_</xsl:text><xsl:value-of select="@key"/>
			</xsl:variable>
			highlighter.register(new FreeTextFieldHighlighter(&quot;<xsl:value-of select="$pre_fldKey"/>&quot;, positionArray));
		</xsl:for-each>
      </xsl:for-each>
			<!--  highlighter.process(); -->
    </script>
	</xsl:template>
	<xsl:template name="alertHeaderField">
		<xsl:param name="colw"/>
		<xsl:for-each select="field">
		<xsl:variable name="fldKey" select="."/>
		<xsl:variable name="pre_fldKey">
			<xsl:value-of select="$alertId"/><xsl:text>_</xsl:text><xsl:value-of select="$fldKey"/>
		</xsl:variable>
		<td class="clsGridUnreadRow bottomBorder">
			<xsl:attribute name="width"><xsl:value-of select="number($colw - 5)"/>%</xsl:attribute>
			<xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/>
		</td>
		<td class="bottomBorder rightBorder">
			<xsl:attribute name="width"><xsl:value-of select="number($colw + 5)"/>%</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$fldKey = 'numberOfHits'">
					<xsl:value-of select="count($rootDocument/content/alert/hits/elem[@name = 'hit'])"/>
				</xsl:when>
				<xsl:when test="$fldKey = 'msgBenIds' or $fldKey = 'msgOrigtorIds'">
					<xsl:call-template name="writeMsgIds">
						<xsl:with-param name="idFld" select="$fldKey"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="value" select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/>
					<xsl:if test="$inputMatches = $value">
						<script language="javascript">
							highlighter.register(new FullFieldHighlighter('<xsl:value-of select="$pre_fldKey"/>'));
						</script>
					</xsl:if>
		            <span>
						<xsl:attribute name="id">
							<xsl:value-of select="$pre_fldKey"/>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="$fldKey = 'jobType'">
								<xsl:apply-templates select="$value" mode="getJobTypes"/>
							</xsl:when>
							<xsl:when test="$fldKey = 'entryType'">
								<xsl:apply-templates select="$value" mode="getEntityTypes"/>
							</xsl:when>
							<xsl:when test="$fldKey = 'partyGender'">
								<xsl:apply-templates select="$value" mode="getGenderTypes"/>
							</xsl:when>
							<xsl:when test="$fldKey = 'msgIntermed'">
								<xsl:call-template name="writeIntermediateFI"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$value"/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</td>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeMsgIds">
		<xsl:param name="idFld"/>
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = $idFld]">
			<xsl:if test="elem[@name = 'idType'] != ''">
				<xsl:value-of select="elem[@name = 'idType']"/>
			</xsl:if>
			<xsl:if test="elem[@name = 'idCountry'] != ''">
				<xsl:call-template name="checkMessageHighlights">
					<xsl:with-param name="value" select="elem[@name = 'idCountry']"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="elem[@name = 'idNumber'] != ''">
				: <xsl:call-template name="checkMessageHighlights">
            <xsl:with-param name="value" select="elem[@name = 'idNumber']"/>
          </xsl:call-template>
			</xsl:if>;&#160;
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="checkMessageHighlights">
		<xsl:param name="value"/>
		<xsl:variable name="match" select="$inputMatches = $value"/>
		<xsl:choose>
			<xsl:when test="$match">
				<font color="red"><xsl:value-of select="$value"/></font>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="writeIntermediateFI">
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'msgIntermed']/elem[@name = 'msgIntermed']">
		    
			<xsl:variable name="cd" select="./elem[@name = 'Cd']"/>
			<xsl:variable name="countryCd" select="./elem[@name='Country_Cd']"/>
			<xsl:variable name="orgName" select="./elem[@name='Org_Name']"/>
			
			<xsl:if test="$countryCd != ''">
			    (<xsl:call-template name="checkMessageHighlights">
					<xsl:with-param name="value" select="$countryCd"/>
				</xsl:call-template>)
			</xsl:if>
			<xsl:if test="$cd != ''">
				<xsl:if test="$countryCd != ''">:</xsl:if>
				<xsl:call-template name="checkMessageHighlights">
					<xsl:with-param name="value" select="$cd"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$orgName != ''">
				<xsl:if test="$cd != '' or $countryCd != ''">-</xsl:if>
				<xsl:call-template name="checkMessageHighlights">
					<xsl:with-param name="value" select="$orgName"/>
				</xsl:call-template>
			</xsl:if>
			;
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
