<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:rcm="com.actimize.infrastructure.util.XsltExtensionsElements" 
	extension-element-prefixes="rcm">
	
	<xalan:component prefix="rcm" elements="setModule t">
        <xalan:script lang="javaclass" src="xalan://com.actimize.infrastructure.util.XsltExtensionsElements"/>
    </xalan:component>

        <xsl:variable name="inputMatches" select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='inputExplanations']/elem/elem[@name='inputExplanation']/text()"/>

	<xsl:template name="writeAlertHeaderCF">
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
			highlighter.process();
        </script>
	</xsl:template>
	<xsl:template name="alertHeaderField">
		<xsl:param name="colw"/>
		<xsl:for-each select="field">
		<xsl:variable name="fldKey" select="."/>
		<xsl:variable name="alertId" select="$rootDocument/content/alert/alert-header/elem[@name = 'alertId']"/>
		<xsl:variable name="pre_fldKey">
			<xsl:value-of select="$alertId"/><xsl:text>_</xsl:text><xsl:value-of select="$fldKey"/>
		</xsl:variable>
		<td class="clsGridUnreadRow bottomBorder">
			<xsl:attribute name="width"><xsl:value-of select="number($colw - 10)"/>%</xsl:attribute>
			<xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/>
		</td>
		<td class="bottomBorder rightBorder">
			<xsl:attribute name="width"><xsl:value-of select="number($colw + 10)"/>%</xsl:attribute>
			
			<xsl:choose>
				<xsl:when test="$fldKey = 'partyIds'">
					<xsl:call-template name="writePartyIds"/>
				</xsl:when>
				<xsl:when test="$fldKey = 'partyNationalityCountries'">
					<xsl:call-template name="writePartyNationalityCountries"/>
				</xsl:when>
				<xsl:when test="$fldKey = 'partyAddresses'">
					<xsl:call-template name="writePartyAddresses"/>
				</xsl:when>
				<xsl:when test="$fldKey = 'partyAliases'">
					<xsl:call-template name="writePartyAliases"/>
				</xsl:when><xsl:otherwise>
					<xsl:variable name="value" select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/>
					<xsl:choose>
						<xsl:when test="string($value) = ''">
							<xsl:variable name="value1" select="$rootDocument/content/alert/alert-header/elem/elem[@name = $fldKey]"/>
							<xsl:if test="normalize-space($inputMatches) = normalize-space($value1)">
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
										<xsl:apply-templates select="$value1" mode="getJobTypes"/>
									</xsl:when>
									<xsl:when test="$fldKey = 'partyType'">
										<xsl:apply-templates select="$value1" mode="getEntityTypes"/>
									</xsl:when>
									<xsl:when test="$fldKey = 'partyGender'">
										<xsl:apply-templates select="$value1" mode="getGenderTypes"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$value1"/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
						</xsl:when>
						<xsl:otherwise>
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
									<xsl:when test="$fldKey = 'partyType'">
										<xsl:apply-templates select="$value" mode="getEntityTypes"/>
									</xsl:when>
									<xsl:when test="$fldKey = 'partyGender'">
										<xsl:apply-templates select="$value" mode="getGenderTypes"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$value"/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</td>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writePartyIds">
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'partyIds']">
			<xsl:variable name="idt" select="./elem[@name='idType']"/>
			<xsl:variable name="idc" select="./elem[@name='idCountry']"/>
			<xsl:variable name="idn" select="./elem[@name='idNumber']"/>
			<xsl:if test="normalize-space($idt)!=''"><xsl:value-of select="$idt"/></xsl:if>
			<xsl:if test="normalize-space($idt)!='' and normalize-space($idc)!=''">&#160;</xsl:if>
			<xsl:if test="normalize-space($idc)!=''">(<xsl:choose>
					<xsl:when test="$inputMatches = $idc">
						<span style="color:red"><xsl:value-of select="$idc"/></span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$idc"/>
					</xsl:otherwise>
				</xsl:choose>)</xsl:if>
				<xsl:if test="(normalize-space($idt)!='' or normalize-space($idc)!='') and normalize-space($idn)!=''">:&#160;</xsl:if>
			<xsl:if test="normalize-space($idn)!=''">
				<xsl:choose>
					<xsl:when test="$inputMatches = $idn">
						<span style="color:red"><xsl:value-of select="$idn"/></span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$idn"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>;
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writePartyNationalityCountries">
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'partyNatCountries']">
			<xsl:variable name="cntr" select="./elem[@name = 'countryCd']"/>
			<xsl:if test="normalize-space($cntr)!=''">
				<xsl:choose>
					<xsl:when test="$inputMatches = $cntr">
						<span style="color:red"><xsl:value-of select="$cntr"/></span>;&#160;
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$cntr"/>;&#160;
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writePartyAddresses">
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'partyAddresses']">
			<xsl:variable name="street1" select="./elem[@name = 'partyAddressLine1']"/>
			<xsl:variable name="street2" select="./elem[@name = 'partyAddressLine2']"/>
			<xsl:variable name="city" select="./elem[@name = 'partyCity']"/>
			<xsl:variable name="state" select="./elem[@name = 'partyStateProvince']"/> 
			<xsl:variable name="zip" select="./elem[@name = 'partyPostalCd']"/>
			<xsl:variable name="country" select="./elem[@name = 'partyCountry']"/>
			<xsl:if test="normalize-space($street1)!=''"><xsl:value-of select="$street1"/>,</xsl:if>
			<xsl:if test="normalize-space($street2)!=''"><xsl:value-of select="$street2"/>,</xsl:if>
			<xsl:if test="normalize-space($city)!=''">
				<xsl:choose>
					<xsl:when test="$inputMatches = $city">
						<span style="color:red"><xsl:value-of select="$city"/></span>,
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$city"/>,
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="normalize-space($state)!=''">
				<xsl:choose>
					<xsl:when test="$inputMatches = $state">
						<span style="color:red"><xsl:value-of select="$state"/></span>,
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$state"/>,
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="normalize-space($zip)!=''"><xsl:value-of select="$zip"/>,</xsl:if>
			<xsl:if test="normalize-space($country)!=''">
				<xsl:choose>
					<xsl:when test="$inputMatches = $country">
						<span style="color:red"><xsl:value-of select="$country"/></span>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$country"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<br/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writePartyAliases">
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'partyAliases']">
			<xsl:variable name="aliasVal" select="./elem[@name = 'alias']"/>
			<xsl:choose>
				<xsl:when test="$inputMatches = $aliasVal">
					<span style="color:red"><xsl:value-of select="$aliasVal"/>;&#160;</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$aliasVal !=''">
						<xsl:value-of select="$aliasVal"/>;&#160;
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writePartyCustomFields">
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'partyCustomFields']">
			<table class="clsGridTableBase pluginDataTable" width="100%">
				<xsl:variable name="cfVal" select="./elem[@name = 'value']"/>
				<xsl:if test="normalize-space($cfVal)!=''">
					<tr>
						<td class="graycell"  width="20%">
							<xsl:variable name="userText">  <xsl:value-of select="./elem[@name = 'caption']"/> </xsl:variable>
                            <xsl:variable name="origionalText"> <rcm:t select="./elem[@name = 'caption']"/> </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$origionalText != ''">   <xsl:value-of select="$origionalText" disable-output-escaping="yes"/> </xsl:when>
                                <xsl:otherwise>     <xsl:value-of select="$userText"  disable-output-escaping="yes"/> </xsl:otherwise>
                            </xsl:choose>
						</td>
						<td><xsl:apply-templates select="$cfVal" mode="getBoolTypes"/></td>
					</tr>
				</xsl:if>
			</table>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
