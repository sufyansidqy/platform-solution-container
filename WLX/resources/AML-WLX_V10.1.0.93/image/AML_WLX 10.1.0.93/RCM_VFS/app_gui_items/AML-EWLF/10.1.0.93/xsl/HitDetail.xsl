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
	
	<xsl:template name="writeHitDetails">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$sectionInfo/hit-detail/field-section">
			<xsl:variable name="secName" select="@labelKey"/>
			<div>
			<table width="100%" class="detailsList">
				<xsl:if test="$secName != ''">
					<tr>
						<td style="background-color:#ebecee; font-weight:bold; padding: 3px;">
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
			</div>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="setSection">
		<xsl:param name="setName"/>
		<xsl:param name="hitElem"/>
		<xsl:if test="$setName = 'aliases'">
			<xsl:call-template name="writeAliases">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'additionalInfo'">
			<xsl:call-template name="writeAddlInfo">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'scoreFactors'">
			<xsl:call-template name="writeScoreFactors">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'ids'">
			<xsl:call-template name="writeIds">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'addresses'">
			<xsl:call-template name="writeAddresses">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'customFields'">
			<xsl:call-template name="writeCustomFields">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'aliasesAndIds'">
			<xsl:call-template name="writeAliasesAndIDs">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'dobAndAddresses'">
			<xsl:call-template name="writeDobAndAddresses">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'dob'">
			<xsl:call-template name="writeDOB">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$setName = 'miscSection'">
			<xsl:call-template name="writeMiscSection">
				<xsl:with-param name="hitElem" select="$hitElem"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="writeMiscSection">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$sectionInfo/misc-sections/field-group">
			<xsl:variable name="secTitle" select="@labelKey"/>
			<xsl:variable name="colNums" select="number(@cols)"/>
			<xsl:variable name="colspn" select="number($colNums * 2)"/>
				<div class="clsGridTableBase clsGridTableBackground">
				<table width="100%" class="clsGridTableBase pluginDataTable">
					<xsl:if test="$secTitle != ''">
						<tr class="clsGridHeaderRow">
							<td class="clsGridHeaderCell clsGridCellBase">
								<xsl:attribute name="colspan"><xsl:value-of select="$colspn"/></xsl:attribute>
								<xsl:apply-templates select="$texts/hits/*[name() = $secTitle]" mode="getText"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:for-each select="row">
						<tr>
							<xsl:call-template name="miscField">
								<xsl:with-param name="colw" select="number(100 div $colspn)"/>
								<xsl:with-param name="hitElem" select="$hitElem"/>
							</xsl:call-template>
						</tr>
					</xsl:for-each>
				</table>
				</div>
		</xsl:for-each>	
	</xsl:template>
	<xsl:template name="miscField">
		<xsl:param name="colw"/>
		<xsl:param name="hitElem"/>
		<xsl:for-each select="field">
			<xsl:variable name="fldKey" select="."/>
			<td class="clsGridUnreadRow bottomBorder">
				<xsl:attribute name="width"><xsl:value-of select="number($colw - 5)"/>%</xsl:attribute>
				<xsl:apply-templates select="$texts/hits/*[name() = $fldKey]" mode="getText"/>
			</td>
			<td class="bottomBorder rightBorder">
				<xsl:attribute name="width"><xsl:value-of select="number($colw + 5)"/>%</xsl:attribute>
				<xsl:variable name="value" select="$hitElem/elem[@name = $fldKey]"/>
				<xsl:message><xsl:value-of select="$value"/></xsl:message>
				<xsl:choose>
					<xsl:when test="string($value) = ''">
						<xsl:variable name="value1" select="$hitElem/elem[@name = $fldKey]"/>
						<xsl:if test="$inputMatches = $value1">
							<script language="javascript">
								highlighter.register(new FullFieldHighlighter('<xsl:value-of select="$fldKey"/>'));
							</script>
						</xsl:if>
			            <span>
							<xsl:attribute name="id">
								<xsl:value-of select="$fldKey"/>
							</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$fldKey = 'gender'">
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
								highlighter.register(new FullFieldHighlighter('<xsl:value-of select="$fldKey"/>'));
							</script>
						</xsl:if>
			            <span>
							<xsl:attribute name="id">
								<xsl:value-of select="$fldKey"/>
							</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$fldKey = 'gender'">
									<xsl:apply-templates select="$value" mode="getGenderTypes"/>
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
	
	<xsl:template name="writeDobAndAddresses">
		<xsl:param name="hitElem"/>
		<table width="100%">
			<tr>
				<td width="50%" class="rightBorder" valign="top">
					<xsl:call-template name="writeDOB">
						<xsl:with-param name="hitElem" select="$hitElem"/>
					</xsl:call-template>
				</td>
				<td width="50%"  valign="top">
					<xsl:call-template name="writeAddresses">
						<xsl:with-param name="hitElem" select="$hitElem"/>
					</xsl:call-template>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="writeAliasesAndIDs">
		<xsl:param name="hitElem"/>
		<table width="100%">
			<tr>
				<td width="50%" class="rightBorder" valign="top">
					<xsl:call-template name="writeAliases">
						<xsl:with-param name="hitElem" select="$hitElem"/>
					</xsl:call-template>
				</td>
				<td width="50%"  valign="top">
					<xsl:call-template name="writeIds">
						<xsl:with-param name="hitElem" select="$hitElem"/>
					</xsl:call-template>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="writeAliases">
		<xsl:param name="hitElem"/>
		<table class="clsGridTableBase pluginDataTable" width="100%">
			<tr>
				<td class="graycell"  width="100%">
					<xsl:apply-templates select="$texts/hits/aliases" mode="getText"/>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:for-each select="$hitElem/elem[@name = 'aliases']/elem[@name = 'displayName']">
						<xsl:call-template name="checkStructuredHighlightsForNames">
							<xsl:with-param name="matchValue" select="../elem[@name = 'matchedName']"/>
							<xsl:with-param name="value" select="."/>
							<xsl:with-param name="hit" select="$hitElem"/>
						</xsl:call-template>
						<br/>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>

	<xsl:template name="split">
		<xsl:param name="text"/>
		<xsl:param name="delimiter" select="'&#10;'"/> <!-- newline character -->
		<xsl:choose>

			<xsl:when test="contains($text, $delimiter)">
				<line>
					<xsl:call-template name="makeLink">

						<xsl:with-param name="text" select="substring-before($text, $delimiter)"/>
					</xsl:call-template>
					<BR/>
				</line>
				<xsl:call-template name="split">

					<xsl:with-param name="text" select="substring-after($text, $delimiter)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<line>
					<xsl:call-template name="makeLink">
						<xsl:with-param name="text" select="$text"/>
					</xsl:call-template>
				</line>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="makeLink">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, 'http://')">
				<xsl:value-of select="substring-before($text, 'http://')"/>
				<a href="{concat('http://', substring-before(concat(substring-after($text, 'http://'), ' '), ' '))}" target="_blank">
					<xsl:value-of select="concat('http://', substring-before(concat(substring-after($text, 'http://'), ' '), ' '))"/>
				</a>
				<xsl:text> </xsl:text>
				<xsl:call-template name="makeLink">
					<xsl:with-param name="text" select="substring-after($text, concat('http://', substring-before(concat(substring-after($text, 'http://'), ' '), ' ')))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, 'https://')">
				<xsl:value-of select="substring-before($text, 'https://')"/>
				<a href="{concat('https://', substring-before(concat(substring-after($text, 'https://'), ' '), ' '))}" target="_blank">
					<xsl:value-of select="concat('https://', substring-before(concat(substring-after($text, 'https://'), ' '), ' '))"/>
				</a>
				<xsl:text> </xsl:text>
				<xsl:call-template name="makeLink">
					<xsl:with-param name="text" select="substring-after($text, concat('https://', substring-before(concat(substring-after($text, 'https://'), ' '), ' ')))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template name="writeAddlInfo">
		<xsl:param name="hitElem"/>
		<xsl:variable name="extsrc"/>
		<table class="clsGridTableBase pluginDataTable" width="100%">
			<xsl:choose>
				<!-- 	<xsl:when test="$hitElem/elem[@name = 'listId'][. = 'FACTIVA_PEP']"> -->
				<xsl:when test="substring($hitElem/elem[@name = 'listId']/text(),1,7) = 'FACTIVA' or substring($hitElem/elem[@name = 'listId']/text(),1,2) = 'DJ'">
					<tr>
						<td class="datacell bottomBorder">
							<b><u><xsl:apply-templates select="$texts/hits/profileNotes" mode="getText"/></u></b><br/>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'ProfileNotes']">

								<xsl:variable name="profileContents" select="../elem[@name = 'value']"/>
								<xsl:call-template name="split">
									<xsl:with-param name="text" select="$profileContents"/>
								</xsl:call-template>

								<br/>
							</xsl:for-each>

						</td>
					</tr>

				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/externalSource" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo'][elem[@name = 'name'] = 'External Source']">
							<xsl:variable name="value" select="elem[@name='value']"/>
							<xsl:choose>
								<xsl:when test="starts-with($value, 'http://') or starts-with($value, 'https://')">
									<a href="{$value}" target="_blank">
										<xsl:value-of select="$value"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="textBeforeParentheses" select="substring-before($value, '(')"/>
									<xsl:value-of select="$textBeforeParentheses"/>
									<xsl:variable name="url" select="substring-before(substring-after($value, '('), ')')"/>
									<xsl:choose>
										<xsl:when test="starts-with($url, 'http://') or starts-with($url, 'https://')">
											<xsl:text>(</xsl:text>
											<a href="{$url}" target="_blank">
												<xsl:value-of select="$url"/>
											</a>
											<xsl:text>)</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>(</xsl:text>
											<xsl:value-of select="url"></xsl:value-of>
											<xsl:text>)</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:variable name="textAfter" select="substring-after($value,')')"/>
									<xsl:value-of select="textAfter"></xsl:value-of>
								</xsl:otherwise>
							</xsl:choose>
							<br/>
						</xsl:for-each>
					</td>
				</tr>
				
				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/linkedTo" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Linked To']">
							<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
						</xsl:for-each>
					</td>
				</tr>
				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/images" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo'][elem[@name = 'name'] = 'Image']">
							<a href="{elem[@name = 'value']}" target="_blank">
								<xsl:value-of select="elem[@name = 'value']"/>&#160;<br/>
							</a><br/>
						</xsl:for-each>
					</td>
				</tr>
				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/otherRoles" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Other Roles']">
							<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
						</xsl:for-each>
					</td>
				</tr>
				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/previousRoles" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Previous Roles']">
							<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
						</xsl:for-each>
					</td>
				</tr>
				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/sanctionReferences" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Sanction References']">
							<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
						</xsl:for-each>
					</td>
			    </tr>
			</xsl:when>
			<xsl:when test="$hitElem/elem[@name = 'listId'][. = 'FinCEN314a']">
				<tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/trackingNumber" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Tracking Number']">
							<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
						</xsl:for-each>
					</td>
			    </tr>
			    <tr>
					<td class="datacell bottomBorder">
						<b><u><xsl:apply-templates select="$texts/hits/phoneNumber" mode="getText"/></u></b><br/>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Phone Numbers']">
							<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
						</xsl:for-each>
					</td>
			    </tr>
			</xsl:when>
			<xsl:otherwise>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/furtherInfo" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Further Information']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/externalSource" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo'][elem[@name = 'name'] = 'External Source']">
						<xsl:variable name="value" select="elem[@name='value']"/>
						<xsl:choose>
							<xsl:when test="starts-with($value, 'http://') or starts-with($value, 'https://')">
								<a href="{$value}" target="_blank">
									<xsl:value-of select="$value"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="textBeforeParentheses" select="substring-before($value, '(')"/>
								<xsl:value-of select="$textBeforeParentheses"/>
								<xsl:variable name="url" select="substring-before(substring-after($value, '('), ')')"/>
								<xsl:choose>
									<xsl:when test="starts-with($url, 'http://') or starts-with($url, 'https://')">
										<xsl:text>(</xsl:text>
										<a href="{$url}" target="_blank">
											<xsl:value-of select="$url"/>
										</a>
										<xsl:text>)</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>(</xsl:text>
										<xsl:value-of select="url"></xsl:value-of>
										<xsl:text>)</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:variable name="textAfter" select="substring-after($value,')')"/>
								<xsl:value-of select="textAfter"></xsl:value-of>
							</xsl:otherwise>
						</xsl:choose>
						<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/linkedTo" mode="getText"/></u></b><br/>
						<table>
							<tr>
								<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Linked To']">
									<td style="width: 100px; text-align: left;"><xsl:value-of select="../elem[@name = 'value']"/></td>
									<xsl:if test="number(position() mod 5) = 0">
										<tr/>
									</xsl:if>
								</xsl:for-each>
							</tr>
						</table>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/company" mode="getText"/></u></b><br/>
						<table>
							<tr>
								<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Company']">
									<td style="width: 100px; text-align: left;"><xsl:value-of select="../elem[@name = 'value']"/></td>
									<xsl:if test="number(position() mod 5) = 0">
										<tr/>
									</xsl:if>
								</xsl:for-each>
							</tr>
						</table>
				</td>
			</tr>
			<tr>
                <td class="datacell bottomBorder">
		        			<b><u><xsl:apply-templates select="$texts/hits/pepStatus" mode="getText"/></u></b><br/>
		        			<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Status']">
		        				<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
		        			</xsl:for-each>
		        </td>
			</tr>
			<tr>
                <td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepRole" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepRoleLevel" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Level']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepPosition" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Position']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>		
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepRoleStatus" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Status']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepRoleStartDate" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Start Date']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepRoleEndDate" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role End Date']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			<tr>
				<td class="datacell bottomBorder">
					<b><u><xsl:apply-templates select="$texts/hits/pepRoleBio" mode="getText"/></u></b><br/>
					<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Bio']">
						<xsl:value-of select="../elem[@name = 'value']"/>&#160;<br/>
					</xsl:for-each>
				</td>
			</tr>
			</xsl:otherwise>
     	 </xsl:choose>
		</table>
	</xsl:template>
	<xsl:template name="writeScoreFactors">
		<xsl:param name="hitElem"/>
		<table width="50%" class="clsGridTableBase pluginDataTable">
			<tr>
				<td colspan="3">
					<xsl:apply-templates select="$texts/hits/hitScore" mode="getText"/>&#160;
					<xsl:value-of select="$hitElem/elem[@name = 'score']"/>
				</td>
			</tr>
			<tr>
				<td class="graycell">
					<xsl:apply-templates select="$texts/hits/factor" mode="getText"/>
				</td>
				<td class="graycell">
					<xsl:apply-templates select="$texts/hits/value" mode="getText"/>
				</td>
				<td class="graycell">
					<xsl:apply-templates select="$texts/hits/factorScore" mode="getText"/>
				</td>
				<td class="graycell">
					<xsl:apply-templates select="$texts/hits/impact" mode="getText"/>
				</td>
			</tr>
			<xsl:for-each select="$hitElem/elem[@name = 'scoreFactors']/elem[@name = 'scoreFactors']">
				<xsl:variable name="desc" select="./elem[@name = 'factorDesc']"/>
				<xsl:if test="normalize-space($desc)!=''">
					<tr>
						<td style="font-weight: bold; text-align:center;" class="bottomBorder rightBorder">
						    <xsl:variable name="userText">  <xsl:value-of select="elem[@name = 'factorDesc']"/> </xsl:variable>
                            <xsl:variable name="origionalText"> <rcm:t select="elem[@name = 'factorDesc']" /> </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$origionalText != ''">   <xsl:value-of select="$origionalText" disable-output-escaping="yes"/> </xsl:when>
                                <xsl:otherwise>     <xsl:value-of select="$userText" disable-output-escaping="yes"/> </xsl:otherwise>
                            </xsl:choose>
						</td>
						<td style="text-align:center;" class="bottomBorder rightBorder">
							<xsl:variable name="userText">  <xsl:value-of select="elem[@name = 'factorValue']"/> </xsl:variable>
                            <xsl:variable name="origionalText"> <rcm:t select="elem[@name = 'factorValue']" /> </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$origionalText != ''">   <xsl:value-of select="$origionalText"/> </xsl:when>
                                <xsl:otherwise>     <xsl:value-of select="$userText"/> </xsl:otherwise>
                            </xsl:choose>
						</td>
						<td style="text-align:center;" class="bottomBorder rightBorder">
							<xsl:value-of select="elem[@name = 'factorScore']"/>
						</td>
						<td style="text-align:center;" class="bottomBorder rightBorder">
							<xsl:attribute name="class">
								score_<xsl:value-of select="elem[@name = 'factorImpact']"/> bottomBorder rightBorder
							</xsl:attribute>
							<xsl:variable name="vImpact" select="elem[@name = 'factorImpact']"/>
							<xsl:apply-templates select="$texts/impacts/*[name() = $vImpact]" mode="getText"/>
						</td>
					</tr>
				</xsl:if>	
			</xsl:for-each>
		</table>
	</xsl:template>
	<xsl:template name="writeIds">
		<xsl:param name="hitElem"/>
		<table class="clsGridTableBase pluginDataTable" width="100%">
			<tr>
				<td class="graycell"  width="100%">
					<xsl:apply-templates select="$texts/hits/ids" mode="getText"/>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:for-each select="$hitElem/elem[@name = 'ids']">
						<!--<xsl:value-of select="./elem[@name='idType']"/> (<xsl:value-of select="./elem[@name='idCountry']"/>): -->
						<xsl:value-of select="./elem[@name='idType']"/> (<xsl:call-template name="checkStructuredHighlights">
						  <xsl:with-param name="value" select="./elem[@name='idCountry']"/>
						  <xsl:with-param name="hit" select="$hitElem"/>
						</xsl:call-template>):
						<!-- <xsl:value-of select="@idNumber"/><br/>  -->
						<xsl:call-template name="checkStructuredHighlights">
						  <xsl:with-param name="value" select="./elem[@name='idNumber']"/>
						  <xsl:with-param name="hit" select="$hitElem"/>
						</xsl:call-template>
						<br/>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="writeDOB">
		<xsl:param name="hitElem"/>
		<table class="clsGridTableBase pluginDataTable" width="100%">
			<tr>
				<td class="graycell" width="100%" colspan="2">
					<xsl:apply-templates select="$texts/hits/dob" mode="getText"/>
				</td>
			</tr>
			<tr>
				<td width="50%">
					<table width="100%">
					<tr>
								<td width="50%">
									<xsl:apply-templates select="$texts/hits/age" mode="getText"/>
								</td>
								<td width="50%">
									<xsl:value-of select="$hitElem/elem[@name='age']"/> 
								</td>
							</tr>
							<tr>
								<td width="50%">
									<xsl:apply-templates select="$texts/hits/ageAsOfDate" mode="getText"/>
								</td>
								<td width="50%">
									<xsl:value-of select="$hitElem/elem[@name='ageAsOfDate']"/> 
								</td>
							</tr>
							<tr>
							<td width="50%">
								<xsl:apply-templates select="$texts/hits/placeOfBirth" mode="getText"/>
							</td>
							<td width="50%">
								<xsl:for-each select="$hitElem/elem[@name = 'datesOfBirth']">
									<xsl:if test="position() > 1">; </xsl:if>
									<xsl:choose>
										<xsl:when test="./elem[@name = 'birthDate'] != ''">
											<xsl:value-of select="./elem[@name = 'birthDate']"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="./elem[@name = 'yearOfBirth']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
								/
								<xsl:for-each select="$hitElem/elem[@name = 'placesOfBirth']">
									<xsl:if test="position() > 1">; </xsl:if>
									<xsl:value-of select="./elem[@name = 'birthPlace']"/>
									<xsl:if test="./elem[@name = 'birthPlace'] != ''">,</xsl:if>
									<xsl:call-template name="checkStructuredHighlights">
										<xsl:with-param name="value" select="./elem[@name = 'birthCountry']"/>
										<xsl:with-param name="hit" select="$hitElem"/>
								    </xsl:call-template> 
								</xsl:for-each>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="writeAddresses">
		<xsl:param name="hitElem"/>
		<table class="clsGridTableBase pluginDataTable" width="100%">
			<tr>
				<td class="graycell"  width="100%">
					<xsl:apply-templates select="$texts/hits/addresses" mode="getText"/>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:for-each select="$hitElem/elem[@name = 'addresses']">
						<!-- <xsl:value-of select="./elem[@name = 'streetAddress1']"/>, <xsl:value-of select="./elem[@name = 'streetAddress2']"/>, <xsl:value-of select="./elem[@name = 'city']"/>, <xsl:value-of select="./elem[@name = 'stateProvince']"/> - <xsl:value-of select="./elem[@name = 'postalCode']"/>, <xsl:value-of select="./elem[@name = 'country']"/> <br/>  -->
						<xsl:variable name="street1" select="./elem[@name = 'streetAddress1']"/>
						<xsl:variable name="street2" select="./elem[@name = 'streetAddress2']"/>
						<xsl:variable name="city" select="./elem[@name = 'city']"/>
						<xsl:variable name="state" select="./elem[@name = 'stateProvince']"/> 
						<xsl:variable name="zip" select="./elem[@name = 'postalCode']"/>
						<xsl:variable name="country" select="./elem[@name = 'country']"/>
						<xsl:if test="normalize-space($street1)!=''"><xsl:value-of select="$street1"/>,</xsl:if>
						<xsl:if test="normalize-space($street2)!=''"><xsl:value-of select="$street2"/>,</xsl:if>
						<xsl:if test="normalize-space($city)!=''">
							<xsl:call-template name="checkStructuredHighlights">
								<xsl:with-param name="value" select="$city"/>
								<xsl:with-param name="hit" select="$hitElem"/>
							</xsl:call-template>
							,</xsl:if>
						<xsl:if test="normalize-space($state)!=''">
							<xsl:call-template name="checkStructuredHighlights">
								<xsl:with-param name="value" select="$state"/>
								<xsl:with-param name="hit" select="$hitElem"/>
							</xsl:call-template>,
						</xsl:if>
						<xsl:if test="normalize-space($zip)!=''"><xsl:value-of select="$zip"/>,</xsl:if>
						<xsl:call-template name="checkStructuredHighlights">
							 <xsl:with-param name="value" select="$country"/>
							 <xsl:with-param name="hit" select="$hitElem"/>
						</xsl:call-template>
						<xsl:if test="normalize-space($country)!=''">
							<!--<xsl:value-of select="$country"/> -->
						</xsl:if><br/>
					</xsl:for-each>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="writeCustomFields">
		<xsl:param name="hitElem"/>
		<table class="clsGridTableBase pluginDataTable" width="100%">
			<xsl:if test="$userTexts/hits/cs_1 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_1" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_1']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_2 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_2" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_2']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_3 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_3" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_3']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_4 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_4" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_4']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_5 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_5" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_5']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_6 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_6" mode="getText"/>
					</td>
					<td>
						<xsl:apply-templates select="$hitElem/elem[@name = 'cs_6']" mode="getBoolTypes"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_7 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_7" mode="getText"/>
					</td>
					<td>
						<xsl:apply-templates select="$hitElem/elem[@name = 'cs_7']" mode="getBoolTypes"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_8 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_8" mode="getText"/>
					</td>
					<td>
						<xsl:apply-templates select="$hitElem/elem[@name = 'cs_8']" mode="getBoolTypes"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_9 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_9" mode="getText"/>
					</td>
					<td>
						<xsl:apply-templates select="$hitElem/elem[@name = 'cs_9']" mode="getBoolTypes"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_10 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_10" mode="getText"/>
					</td>
					<td>
						<xsl:apply-templates select="$hitElem/elem[@name = 'cs_10']" mode="getBoolTypes"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_11 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_11" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_11']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_12 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_12" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_12']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_13 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_13" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_13']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_14 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_14" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_14']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_15 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_15" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_15']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_16 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_16" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_16']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_17 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_17" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_17']"/>
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="$userTexts/hits/cs_18 != ''">
				<tr>
					<td class="graycell"  width="20%">
						<xsl:apply-templates select="$userTexts/hits/cs_18" mode="getText"/>
					</td>
					<td>
						<xsl:value-of select="$hitElem/elem[@name = 'cs_18']"/>
					</td>
				</tr>
			</xsl:if>
		</table>
	</xsl:template>
	

	<xsl:template name="checkStructuredHighlights">
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $value"/>
		<xsl:choose>
			<xsl:when test="boolean($match)">
				<font color="red"><xsl:value-of select="$value"/></font>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="checkStructuredHighlightsForNames">
		<xsl:param name="matchValue"/>
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $matchValue"/>
		<xsl:variable name="match2" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $value"/>
		<xsl:choose>
			<xsl:when test="boolean($match) or boolean($match2)">
				<font color="red">
					<xsl:value-of select="$value"/>
				</font>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
</xsl:stylesheet>
