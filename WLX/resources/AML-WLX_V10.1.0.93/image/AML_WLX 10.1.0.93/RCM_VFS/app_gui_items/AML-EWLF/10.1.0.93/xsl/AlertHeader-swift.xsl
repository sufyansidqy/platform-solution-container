<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fo="http://www.w3.org/1999/XSL/Format">
        <xsl:variable name="swiftFreeTextMatchFields" select="$rootDocument/content/alert/*/elem[@name='messageMatchPositions']/elem[@name='matchPositionAttribute']"/>
        <xsl:variable name="swiftFreeTextAttrMap" select="document('xml/FreeTextFields.xml')/freeTextFieldMap"/>
        <xsl:variable name="alertId" select="$rootDocument/@id"/>
        <xsl:template name="writeAlertHeaderSwift">
                <script language="javascript">
                        var highlighter = new InputFieldHighlighter();
                </script>
                <xsl:for-each select="$sectionInfo/alert-header-swift/field-group">
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
					                        <xsl:call-template name="alertHeaderField-swift">
					                        	<xsl:with-param name="colw" select="number(100 div $colspn)"/>
					                        </xsl:call-template>
					                </tr>
				                </xsl:for-each>
                        </table>
                        </div>
                </xsl:for-each>
                <script language="javascript">
                <xsl:for-each select="$swiftFreeTextMatchFields">
                        var positionArray = new Array();
                        <xsl:for-each select="./elem[@name='position']">
							positionArray.push(new FreeTextFieldPositions(<xsl:value-of select="./elem[@name='begin']/text()"/>, <xsl:value-of select="./elem[@name='end']/text()"/>))
                        </xsl:for-each>
                        <xsl:variable name="attrKey" select="./elem[@name='matchField']/text()"/>
                        <xsl:for-each select="$swiftFreeTextAttrMap/entry[@value=$attrKey]">
                            <xsl:variable name="pre_fldKey">
                                <xsl:value-of select="$alertId"/><xsl:text>_</xsl:text><xsl:value-of select="@key"/>
                            </xsl:variable>
                            highlighter.register(new FreeTextFieldHighlighter(&quot;<xsl:value-of select="$pre_fldKey"/>&quot;, positionArray));
                        </xsl:for-each>
                </xsl:for-each>
                        <!--  highlighter.process();-->
                </script>
        </xsl:template>
        <xsl:template name="alertHeaderField-swift">
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
                                <xsl:value-of select="translate($rootDocument/content/alert/alert-header/elem[@name = $fldKey], '&#10;&#13;','&#9830;&#9830;')"/>
                        </span>
					</xsl:otherwise>
				</xsl:choose>
                
                        
                </td>
                </xsl:for-each>
        </xsl:template>
</xsl:stylesheet>

