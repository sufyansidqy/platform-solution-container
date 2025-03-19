<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:internal="http://www.actimize.com/internal"
                exclude-result-prefixes="internal">

    <xsl:variable name="inputMatches"
                  select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='inputExplanations']/elem/elem[@name='inputExplanation']/text()"/>
    <xsl:variable name="freeTextMatchFields"
                  select="$rootDocument/content/alert/*/elem[@name='messageMatchPositions']/elem[@name='matchPositionAttribute']"/>
    <xsl:variable name="freeTextAttrMap" select="document('xml/FreeTextFields.xml')/freeTextFieldMap"/>
    <xsl:variable name="alertId" select="$rootDocument/@id"/>
    <xsl:template name="writeAlertHeaderSwiftMX">
        <script language="javascript">
            var highlighter = new InputFieldHighlighter();
        </script>
        <xsl:for-each select="$sectionInfo/alert-header-swiftmx/field-group">
            <xsl:variable name="secTitle" select="@labelKey"/>
            <xsl:variable name="colNums" select="number(@cols)"/>
            <xsl:variable name="colspn" select="$colNums * 2"/>
            <div class="clsGridTableBase clsGridTableBackground">
                <table width="100%" class="clsGridTableBase pluginDataTable">
                    <tr class="clsGridHeaderRow">
                        <td class="clsGridHeaderCell clsGridCellBase">
                            <xsl:attribute name="colspan">
                                <xsl:value-of select="$colspn"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
                        </td>
                    </tr>
                    <xsl:if test="$secTitle = 'jobDetails'">
                        <xsl:for-each select="row">
                            <tr>
                                <xsl:call-template name="alertHeaderField">
                                    <xsl:with-param name="colw" select="100 div $colspn"/>
                                </xsl:call-template>
                            </tr>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:variable name="listOfFields" select="$rootDocument/content/alert/alert-header/elem[@name = $secTitle]" />
                    <xsl:variable name="totalFields" select="(count($listOfFields) div $colNums) + 1" />
                    <xsl:for-each select="$listOfFields[position() &lt;= $totalFields]">
                        <xsl:variable name="lowerIndex" select="(position() * $colNums) - $colNums" />
                        <xsl:variable name="upperIndex" select="(position() * $colNums)" />
                        <xsl:call-template name="groupingMXFields">
                            <xsl:with-param name="listOfFields" select="$listOfFields[position() &gt;= ($lowerIndex+1) and position() &lt;= $upperIndex]"/>
                            <xsl:with-param name="colspn" select="$colspn" />
                        </xsl:call-template>
                    </xsl:for-each>
                </table>
            </div>
        </xsl:for-each>
        <script language="javascript">
            <xsl:for-each select="$freeTextMatchFields">
                var positionArray = new Array();
                <xsl:for-each select="./elem[@name='position']">
                    positionArray.push(new FreeTextFieldPositions(<xsl:value-of select="./elem[@name='begin']/text()"/>,
                    <xsl:value-of select="./elem[@name='end']/text()"/>))
                </xsl:for-each>
                <xsl:variable name="attrKey" select="./elem[@name='matchField']/text()"/>
                <xsl:for-each select="$freeTextAttrMap/entry[@value=$attrKey]">
                    highlighter.register(new FreeTextFieldHighlighter(&quot;<xsl:value-of select="@key"/>&quot;,
                    positionArray));
                </xsl:for-each>
            </xsl:for-each>
            <!--  highlighter.process(); -->
        </script>
    </xsl:template>
    <xsl:template name="groupingMXFields" >
        <xsl:param name="listOfFields" />
        <xsl:param name="colspn" />
        <tr>
            <xsl:for-each select="$listOfFields">
                <xsl:call-template name="alertHeaderMXField">
                    <xsl:with-param name="colw" select="number(100 div $colspn)"/>
                </xsl:call-template>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:template name="alertHeaderMXField">
        <xsl:param name="colw"/>
        <xsl:variable name="MatchHits" select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='explanations']/elem"/>
        <xsl:variable name="MatchHitInputEx" select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='inputExplanations']/elem"/>
        <xsl:variable name="matchValues1">
            <xsl:for-each select="$MatchHits/elem[@name='Explanation']/text()">
                <xsl:if test="position() > 1">|</xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:for-each>

        </xsl:variable>
        <xsl:variable name="matchValues2">
        <xsl:for-each select="$MatchHitInputEx/elem[@name='inputExplanation']/text()">
            <xsl:if test="position() > 1">|</xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="matchValues">
            <xsl:choose>
                <xsl:when test="$matchValues1 and $matchValues2">
                    <xsl:value-of select="concat($matchValues1, '|', $matchValues2)" />
                </xsl:when>
                <xsl:when test="$matchValues1">
                    <xsl:value-of select="$matchValues1" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$matchValues2" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="fldKey" select="translate(./elem[@name = 'fieldKey'], ' ', '')"/>
        <xsl:variable name="pre_fldKey">
            <xsl:value-of select="$alertId"/><xsl:text>_</xsl:text><xsl:value-of select="$fldKey"/>
        </xsl:variable>
        <td class="clsGridUnreadRow bottomBorder">
            <xsl:attribute name="width">
                <xsl:value-of select="string(number($colw - 5))"/>%
            </xsl:attribute>
            <xsl:value-of select="./elem[@name = 'fieldKey']"/>
        </td>
        <td class="bottomBorder rightBorder">
            <xsl:attribute name="width">
                <xsl:value-of select="string(number($colw + 5))"/>%
            </xsl:attribute>
            <xsl:variable name="value" select="./elem[@name = 'fieldValue']"/>
            <span>
                <xsl:attribute name="id">
                    <xsl:value-of select="$pre_fldKey"/>
                </xsl:attribute>
                <xsl:value-of select="string($value)"/>
            </span>

            <xsl:if test="string-length($matchValues) > 0">
                <script language="javascript">
                    var matchValuesString = '<xsl:value-of select="$matchValues" />';
                    var preFldKey = '<xsl:value-of select="$pre_fldKey" />';
                    highlighter.register(new FullFieldHighlighterMX(preFldKey, matchValuesString));
                </script>
            </xsl:if>
        </td>
    </xsl:template>
</xsl:stylesheet>
