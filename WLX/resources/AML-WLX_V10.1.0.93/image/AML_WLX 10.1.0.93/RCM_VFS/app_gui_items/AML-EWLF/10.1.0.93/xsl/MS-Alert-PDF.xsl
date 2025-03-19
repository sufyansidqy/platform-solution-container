<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:internal="http://www.actimize.com/internal"
	xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:rcm="com.actimize.infrastructure.util.XsltExtensionsElements" 
	extension-element-prefixes="rcm">
	
	<xalan:component prefix="rcm" elements="setModule t">
        <xalan:script lang="javaclass" src="xalan://com.actimize.infrastructure.util.XsltExtensionsElements"/>
    </xalan:component>

	<xsl:param name="version"/>
	
	<!-- Overriding texts variables to refer to CF text file only -->
	<xsl:variable name="userTexts" select="document('xml/MS_texts.xml')/texts"/>
	<xsl:variable name="texts" select="document('xml/MS_defaultTexts.xml')/texts"/>
	<xsl:variable name="sectionInfo" select="document('xml/MS_FieldOrder.xml')/fields"/>
	<xsl:variable name="msgStruct" select="/enrichedAlert/content/alert/alert-header/elem[@name='msgStruct']"/>
	<xsl:variable name="totalHits" select="count(/enrichedAlert/content/alert/hits/elem[@name = 'hit'])"/>
	<xsl:variable name="rootDocument" select="/enrichedAlert"/>
	<xsl:variable name="renderMode" select="'pdf'"/>
	<xsl:variable name="freeTextAttrMap" select="document('xml/FreeTextFields.xml')/freeTextFieldMap"/>	

	<xsl:include href="xsl/texts.xsl"/>
	<xsl:include href="xsl/common.xsl"/>
	
	<xsl:attribute-set name="impact_HIGH">
		<xsl:attribute name="color">red</xsl:attribute>
		<xsl:attribute name="text-decoration">underline</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="impact_MEDIUM">
		<xsl:attribute name="color">orange</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="impact_LOW">
		<xsl:attribute name="color">green</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="impact_CORRECTIVE">
		<xsl:attribute name="color">blue</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template match="/">
  		<!--fo:layout-master-set>
			<fo:simple-page-master master-name="ms-alert" page-height="11in" page-width="8.5in" margin-top="0.5in" margin-bottom="0.5in" margin-left="1in" margin-right="1in">
				<fo:region-body margin-top=".25in" margin-bottom=".25in"/>
				<fo:region-before extent=".5in"/>
				<fo:region-after extent=".25in"/>
			</fo:simple-page-master>
		 </fo:layout-master-set-->	
		<fo:page-sequence master-reference="A4">
			<fo:static-content flow-name="page-header">
				<fo:block font-size="7pt" border-bottom-width="thin" border-bottom-style="solid" border-bottom-color="black" text-align="left">
                    <xsl:variable name="alertIdDetails"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.alertdetailsfor"  /> </xsl:variable>
	    			<xsl:value-of select="$alertIdDetails"/> <xsl:value-of select="/enrichedAlert/@id"/>
	   			</fo:block>
			</fo:static-content>
			<fo:static-content flow-name="page-footer">
				<fo:block font-size="7pt" border-top-color="blue" text-align="right">
	   				<xsl:variable name="alertPage"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.page"  /> </xsl:variable>
	   			<xsl:value-of select="$alertPage"/>	  <fo:page-number />&#160;
	  			</fo:block>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
				<fo:block font-size="7pt">
					<xsl:variable name="elimStateChar" select="/enrichedAlert/attributes/attribute[@property = 'acm_alert_custom_attributes.csm11']/value"/>
					<xsl:apply-templates select="/enrichedAlert/content/alert/alert-header" mode="getAlertHeader"></xsl:apply-templates>

					<xsl:variable name="i">1</xsl:variable>  		
					<xsl:variable name="elimState">
						<xsl:call-template name="while">      
							<xsl:with-param name="elimStateChar" select="$elimStateChar"/>					
							<xsl:with-param name="i" select="$i"/>
						</xsl:call-template>
					</xsl:variable>			 
					
					<xsl:for-each select="/enrichedAlert/content/alert/hits/elem[@name = 'hit']">
						<xsl:call-template name="getHitBody">
							<xsl:with-param name="hitCnt" select="position()"/>
							<xsl:with-param name="elimState" select="$elimState"/>
						</xsl:call-template>
					</xsl:for-each>
				</fo:block>
			</fo:flow>
		</fo:page-sequence> 
	</xsl:template>
	<xsl:template match="*" mode="getAlertHeader">
		<xsl:if test="$msgStruct = 'STRUCTURED'">
			<xsl:call-template name="writeAlertHeaderStructured" />
		</xsl:if>
		<xsl:if test="$msgStruct = 'SWIFT'">
			<xsl:call-template name="writeAlertHeaderSwift" />
		</xsl:if>
		<xsl:if test="$msgStruct = 'SWIFTMX'">
			<xsl:call-template name="writeAlertHeaderSwiftMX" />
		</xsl:if>
		<xsl:call-template name="writeAlertDetails" />
	</xsl:template>

	<xsl:template name="writeAlertHeaderStructured">
		<xsl:variable name="inputMatches" select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='inputExplanations']/elem/elem[@name='inputExplanation']/text()"/>
		<xsl:for-each select="$sectionInfo/alert-header/field-group">
			<xsl:variable name="secTitle" select="@labelKey"/>
			<xsl:variable name="colNums" select="number(@cols)"/>
			<xsl:variable name="colspn" select="number($colNums * 2)"/>
			<fo:block background-color="silver" font-weight="bold">
				<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
			</fo:block>
			<fo:table table-layout="fixed" width="100%">
				<xsl:for-each select="row/field">
					<xsl:if test="position() &lt;= $colNums">
						<fo:table-column/>
						<fo:table-column/>
					</xsl:if>
				</xsl:for-each>
				<fo:table-body><fo:table-row></fo:table-row>
					<xsl:for-each select="row">
						<fo:table-row>
							<xsl:for-each select="field">
								<xsl:variable name="fldKey" select="."/>
								<fo:table-cell>
									<fo:block font-weight="bold"><xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<xsl:choose>
										<xsl:when test="$fldKey = 'numberOfHits'">
											<fo:block>
												<xsl:value-of select="count($rootDocument/content/alert/hits/elem[@name = 'hit'])"/>
											</fo:block>
										</xsl:when>
										<xsl:when test="$fldKey = 'msgBenIds' or $fldKey = 'msgOrigtorIds'">
											<fo:block>
												<xsl:call-template name="writeMsgIds">
													<xsl:with-param name="idFld" select="$fldKey"/>
												</xsl:call-template>
											</fo:block>
										</xsl:when>
										<xsl:otherwise>
											<xsl:variable name="fval" select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/>
											<fo:block>
												<xsl:choose>
													<xsl:when test="$fldKey = 'jobType'">
														<xsl:apply-templates select="$fval" mode="getJobTypes"/>
													</xsl:when>
													<xsl:when test="$fldKey = 'entryType'">
														<xsl:apply-templates select="$fval" mode="getEntityTypes"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:choose>
															<xsl:when test="$inputMatches = $fval">
																<fo:inline color="red">
																	<xsl:value-of select="$fval"/>
																</fo:inline>
															</xsl:when>
															<xsl:otherwise>
																<fo:block>
																	<xsl:value-of select="$fval"/>
																</fo:block>
															</xsl:otherwise>
														</xsl:choose>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-cell>
							</xsl:for-each>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="writeAlertHeaderSwift">
		<xsl:for-each select="$sectionInfo/alert-header-swift/field-group">
	        <xsl:variable name="secTitle" select="@labelKey"/>
	        <xsl:variable name="colNums" select="number(@cols)"/>
	        <xsl:variable name="colspn" select="number($colNums * 2)"/>
	        <fo:block font-weight="bold" background-color="silver">
	        	<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
	        </fo:block>
	        <fo:table table-layout="fixed" width="100%">
	        	<xsl:for-each select="row/field">
					<xsl:if test="position() &lt;= $colNums">
						<fo:table-column/>
						<fo:table-column/>
					</xsl:if>
				</xsl:for-each>
				<fo:table-body><fo:table-row></fo:table-row>
				    <xsl:for-each select="row">
					     <fo:table-row>
				             <xsl:call-template name="alertHeaderField-swift">
				             	<xsl:with-param name="colw" select="number(100 div $colspn)"/>
				             </xsl:call-template>
					     </fo:table-row>
				    </xsl:for-each>
			    </fo:table-body>
        	</fo:table>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeAlertHeaderSwiftMX">
		<xsl:variable name="inputMatches"
					  select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='explanations']/elem"/>
		<xsl:variable name="inputExpMatches"
					  select="$rootDocument/content/alert/*/elem[@name='hit']/elem[@name='inputExplanations']/elem"/>
		<xsl:variable name="matchValues1">
			<xsl:for-each select="$inputMatches/elem[@name='Explanation']/text()">
				<xsl:if test="position() > 1">|</xsl:if>
				<xsl:value-of select="normalize-space(.)" />
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="matchValues2">
			<xsl:for-each select="$inputExpMatches/elem[@name='inputExplanation']/text()">
				<xsl:if test="position() > 1">|</xsl:if>
				<xsl:value-of select="normalize-space(.)" />
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
		<xsl:for-each select="$sectionInfo/alert-header-swiftmx/field-group">
			<xsl:variable name="secTitle" select="@labelKey"/>
			<xsl:variable name="colNums" select="number(@cols)"/>
			<xsl:variable name="colspn" select="$colNums * 2"/>
			<fo:block background-color="silver" font-weight="bold">
				<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
			</fo:block>
			<fo:table table-layout="fixed" width="100%" border-collapse="separate" border-separation="3pt">
				<xsl:choose>
					<xsl:when test="$secTitle = 'jobDetails'">
						<xsl:for-each select="row/field">
							<xsl:if test="position() &lt;= $colNums">
								<fo:table-column/>
								<fo:table-column/>
							</xsl:if>
						</xsl:for-each>
						<fo:table-body>
							<fo:table-row></fo:table-row>
							<xsl:for-each select="row">
								<fo:table-row>
									<xsl:for-each select="field">
										<xsl:variable name="fldKey" select="."/>
										<fo:table-cell>
											<fo:block font-weight="bold">
												<xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<xsl:choose>
												<xsl:when test="$fldKey = 'numberOfHits'">
													<fo:block><xsl:value-of select="count($rootDocument/content/alert/hits/elem[@name = 'hit'])"/></fo:block>
												</xsl:when>
												<xsl:otherwise>
													<xsl:variable name="fval" select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/>
													<xsl:choose>
														<xsl:when test="$fldKey = 'jobType'">
															<fo:block><xsl:apply-templates select="$fval" mode="getJobTypes"/></fo:block>
														</xsl:when>
														<xsl:otherwise>
															<fo:block><xsl:value-of select="$fval"/></fo:block>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</fo:table-cell>
									</xsl:for-each>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = $secTitle]">
							<xsl:if test="position() &lt;= $colNums">
								<fo:table-column/>
								<fo:table-column/>
							</xsl:if>
						</xsl:for-each>
						<xsl:variable name="listOfFields" select="$rootDocument/content/alert/alert-header/elem[@name = $secTitle]" />

						<fo:table-body>
							<fo:table-row></fo:table-row>
							<xsl:variable name="totalFields" select="(count($listOfFields) div $colNums) + 1" />
							<xsl:for-each select="$listOfFields[position() &lt;= $totalFields]">
								<xsl:variable name="lowerIndex" select="(position() * $colNums) -$colNums" />
								<xsl:variable name="upperIndex" select="(position() * $colNums)" />
								<xsl:variable name="setOfFields" select="$listOfFields[position() &gt;= ($lowerIndex+1) and position() &lt;= $upperIndex]"/>

								<fo:table-row>
									<xsl:for-each select="$setOfFields">
										<fo:table-cell>
											<fo:block font-weight="bold">
												<xsl:value-of select="./elem[@name = 'fieldKey']"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<xsl:variable name="value" select="./elem[@name = 'fieldValue']"/>
											<fo:block>
												<xsl:call-template name="highlightMatches">
													<xsl:with-param name="string" select="$value"/>
													<xsl:with-param name="matchValues" select="$matchValues"/>
												</xsl:call-template>

											</fo:block>
										</fo:table-cell>
									</xsl:for-each>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</xsl:otherwise>
				</xsl:choose>
			</fo:table>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="alertHeaderField-swift">
		<xsl:param name="colw"/>
		<xsl:variable name="check" select="$rootDocument/content/alert/alert-header/elem[@name = 'messageMatchPositions']/elem[@name='matchPositionAttribute']"/>
		<xsl:for-each select="field">
			<xsl:variable name="fldKey" select="."/>
			<fo:table-cell>
				<xsl:attribute name="width"><xsl:value-of select="number($colw - 10)"/>%</xsl:attribute>
				<fo:block font-weight="bold"><xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/></fo:block>
			</fo:table-cell>
			<fo:table-cell >
				<xsl:attribute name="width"><xsl:value-of select="number($colw + 10)"/>%</xsl:attribute>
				<fo:block>
					<xsl:choose>
						<xsl:when test="$fldKey = 'numberOfHits'">
							<xsl:value-of select="count($rootDocument/content/alert/hits/elem[@name = 'hit'])"/>
						</xsl:when>
						<xsl:when test="$fldKey = 'msgText'">

							<xsl:variable name="matchValues">
								<!-- Loop through the elements to construct the keywords string -->
								<xsl:for-each select="$check/elem[@name='position']">
									<xsl:value-of select="./elem[@name='matchValue']/text()" />
									<xsl:text>|</xsl:text>
								</xsl:for-each>
							</xsl:variable>
							<fo:block>

								<xsl:call-template name="highlightMatches">

									<xsl:with-param name="string" select="$rootDocument/content/alert/alert-header/elem[@name ='msgText']/text()"/>
									<xsl:with-param name="matchValues" select="$matchValues"/>

								</xsl:call-template>

							</fo:block>
						</xsl:when>
						<xsl:otherwise>

							<xsl:value-of select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:table-cell>
		</xsl:for-each>
	</xsl:template>


	<xsl:template name="highlightMatches">
		<xsl:param name="string"/>
		<xsl:param name="matchValues"/>
		<xsl:choose>
			<!-- If there are still keywords to process -->
			<xsl:when test="$matchValues != ''">
				<!-- Select the first keyword -->
				<xsl:variable name="keyword" select="substring-before(concat($matchValues, '|'), '|')" />
				<xsl:choose>
					<!-- If the string contains the current keyword -->
					<xsl:when test="contains($string, $keyword)">
						<!-- Process substring-before with the remaining keywords -->
						<xsl:call-template name="highlightMatches">
							<xsl:with-param name="string" select="substring-before($string, $keyword)"/>
							<xsl:with-param name="matchValues" select="substring-after($matchValues, '|')"/>
						</xsl:call-template>
						<!-- Matched keyword -->
						<fo:inline color="red">
							<xsl:value-of select="$keyword"/>
							<xsl:text>&#xA;</xsl:text>


						</fo:inline>
						<!-- Continue with substring-after -->
						<xsl:call-template name="highlightMatches">
							<xsl:with-param name="string" select="substring-after($string, $keyword)"/>
							<xsl:with-param name="matchValues" select="$matchValues"/>
						</xsl:call-template>
					</xsl:when>

					<!-- If the string does not contain the current keyword -->
					<xsl:otherwise>
						<!-- Pass the entire string for processing with the remaining keywords -->
						<xsl:call-template name="highlightMatches">
							<xsl:with-param name="string" select="$string"/>
							<xsl:with-param name="matchValues" select="substring-after($matchValues, '|')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- If there are no more keywords -->
			<xsl:otherwise>
				<!-- Output the string as is -->
				<xsl:value-of select="$string"/>
				<xsl:text>&#xA;</xsl:text>


			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<xsl:template name="writeAlertDetails">
	<xsl:for-each select="$sectionInfo/alert-detail/field-group">
		<xsl:variable name="secTitle" select="@labelKey"/>
		<xsl:variable name="colNums" select="number(@cols)"/>
		<xsl:variable name="colspn" select="number($colNums * 2)"/>
		<xsl:apply-templates select="$texts/alertHighlights/title" mode="getText"/>
		<fo:block background-color="silver" font-weight="bold">
			<xsl:apply-templates select="$texts/alertHighlights/*[name() = $secTitle]" mode="getText"/>
		</fo:block>
		<fo:table table-layout="fixed" width="100%">
			<xsl:for-each select="row/field">
				<xsl:if test="position() &lt;= $colNums">
					<fo:table-column/>
					<fo:table-column/>
				</xsl:if>
			</xsl:for-each>
			<fo:table-body><fo:table-row></fo:table-row>
			<xsl:for-each select="row">
			<fo:table-row >
				<xsl:call-template name="alertDetailField"/>
			</fo:table-row>
			</xsl:for-each>
			</fo:table-body>	
		</fo:table>
	</xsl:for-each>
	</xsl:template>
	<xsl:template name="alertDetailField">
		<xsl:for-each select="field">
			<xsl:variable name="fldKey" select="."/>
			<fo:table-cell>
				<fo:block font-weight="bold"><xsl:apply-templates select="$texts/alertHighlights/*[name() = $fldKey]" mode="getText"/></fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block><xsl:value-of select="$rootDocument/content/alert/alert-header/elem[@name = $fldKey]"/></fo:block>
			</fo:table-cell>
		</xsl:for-each>
	</xsl:template>	
	<xsl:template name="highlightFreeText">
		<xsl:param name="fKey"/>
		<xsl:param name="fVal"/>
		<xsl:message>++++++here++++++</xsl:message>
		<xsl:variable name="msgFreeTextKey" select="$freeTextAttrMap/entry[. = $fKey]/@key"/>
		<xsl:message>msgFreeTextKey: <xsl:value-of select="$msgFreeTextKey"/>, fKey: <xsl:value-of select="$fKey"/>, fVal: <xsl:value-of select="$fVal"/></xsl:message>
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = 'messageMatchPositions']/elem[@name = 'matchPositionAttribute']">
			<xsl:choose>
				<xsl:when test="elem[@name ='matchField'] = $msgFreeTextKey">
					<xsl:call-template name="highlightText">
						<xsl:with-param name="fval" select="$fVal"/>
						<xsl:with-param name="begin" select="elem[@name = 'position']/elem[@name = 'begin']"/>
						<xsl:with-param name="end" select="elem[@name = 'position']/elem[@name = 'end']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<fo:block><xsl:value-of select="$fVal"/></fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="highlightText">
		<xsl:param name="fval"/>
		<xsl:param name="begin"/>
		<xsl:param name="end"/>
		<fo:block>
			<xsl:value-of select="substring($fval, 1, number($begin))"/>
			<fo:block color="red"><xsl:value-of select="substring($fval, number($begin), number($end) - number($begin))"/></fo:block>
			<xsl:value-of select="substring($fval, number($end))"/>
		</fo:block>
	</xsl:template>
	<xsl:template name="getHitBody">
		<xsl:param name="hitCnt"/>
		<xsl:param name="elimState"/>		
		<xsl:variable name="hitDisplayName" select="./elem[@name = 'displayName']/text()"/>
		<xsl:variable name="hitMatchedName" select="./elem[@name = 'matchedName']/text()"/>
		
		<xsl:variable name="matchSplit" select="./elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $hitMatchedName"/>
		<xsl:variable name="matchDisplay" select="./elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $hitDisplayName"/>		
		
		<xsl:variable name="match" select="boolean($matchSplit) or boolean($matchDisplay)"/>
		<xsl:variable name="hitLabel" select="'Hit #'"/>
		<xsl:variable name="colon" select="':'"/>		
		
		<fo:block font-weight="bold" background-color="black" color="white">
			<xsl:value-of select="concat($hitLabel,$hitCnt,$colon)"/>
			<xsl:choose>
				<xsl:when test="boolean($match)">
					<fo:inline color="red"><xsl:value-of select="$hitDisplayName"/></fo:inline>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$hitDisplayName"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:variable name="tmp" select="substring-after($elimState, concat($hitCnt, '-'))"/>
			<xsl:if test="starts-with($tmp, '1')">
				<fo:inline text-align="right" font-weight="bold" background-color="black" color="white">&#160;&#160;&#160;(<xsl:apply-templates select="$texts/hits/viewedHit" mode="getText"/>)</fo:inline>
			</xsl:if>
		</fo:block>
		<xsl:call-template name="writeHitHeader">
			<xsl:with-param name="hitCnt" select="position()"/>
			<xsl:with-param name="hitElem" select="."/>
		</xsl:call-template>
		<xsl:call-template name="writeHitDetails">
			<xsl:with-param name="hitElem" select="."/>
		</xsl:call-template>
		<xsl:call-template name="writeHitAddlDetails">
			<xsl:with-param name="hitCnt" select="position()"/>
			<xsl:with-param name="hitElem" select="."/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="checkEliminatedState">
		<xsl:param name="hitCnt"/>
		
	</xsl:template>
	<xsl:template name="writeHitHeader">
		<xsl:param name="hitCnt"/>
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$sectionInfo/hit-header/field-group">
			<xsl:variable name="colNums" select="number(@cols)"/>
			<xsl:variable name="colspn" select="number($colNums * 2)"/>
			<fo:table table-layout="fixed" width="100%" border="thin solid gray">
				<xsl:for-each select="row/field">
					<xsl:if test="position() &lt;= $colNums">
						<fo:table-column/>
						<fo:table-column/>
					</xsl:if>
				</xsl:for-each>
				<fo:table-body><fo:table-row></fo:table-row>
					<xsl:for-each select="row">
						<fo:table-row>
							<xsl:call-template name="hitHeaderField">
								<xsl:with-param name="hitElem" select="$hitElem"/>
							</xsl:call-template>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:for-each>
		<fo:block>&#160;</fo:block>
	</xsl:template>	
	<xsl:template name="hitHeaderField">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="field">
			<xsl:variable name="fldKey" select="."/>
			<fo:table-cell>
				<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/*[name() = $fldKey]" mode="getText"/></fo:block>
			</fo:table-cell>
			<fo:table-cell>
					<xsl:choose>
						<xsl:when test="$fldKey = 'matchType'">
							<xsl:variable name="value"><xsl:apply-templates select="$hitElem/elem[@name = $fldKey]" mode="getMatchTypes"/></xsl:variable>
							<xsl:call-template name="checkHeaderHighlights">
							  <xsl:with-param name="value" select="$value"/>
							  <xsl:with-param name="hit" select="$hitElem"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$fldKey = 'entryType'">
							<xsl:variable name="value"><xsl:apply-templates select="$hitElem/elem[@name = $fldKey]" mode="getEntityTypes"/></xsl:variable>
							<xsl:call-template name="checkHeaderHighlights">
							  <xsl:with-param name="value" select="$value"/>
							  <xsl:with-param name="hit" select="$hitElem"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$fldKey = 'categories'">
									<fo:block>
									<xsl:call-template name="writeCategories">
										<xsl:with-param name="hitElem" select="$hitElem"/>
									</xsl:call-template>
									</fo:block>
								</xsl:when>
								<xsl:when test="$fldKey = 'keywords'">
									<fo:block>
									<xsl:call-template name="writeKeywords">
										<xsl:with-param name="hitElem" select="$hitElem"/>
									</xsl:call-template>
									</fo:block>
								</xsl:when>
								<xsl:when test="$fldKey = 'nationalityCountries'">
									<fo:block>
									<xsl:call-template name="writeNationalityCountries">
										<xsl:with-param name="hitElem" select="$hitElem"/>
									</xsl:call-template>
									</fo:block>
								</xsl:when>
								<xsl:otherwise>						
									<xsl:call-template name="checkHeaderHighlights">
									  <xsl:with-param name="value" select="$hitElem/elem[@name = $fldKey]"/>
									  <xsl:with-param name="hit" select="$hitElem"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
			</fo:table-cell>
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
			<xsl:value-of select="."/>;&#160;
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="writeHitDetails">
		<xsl:param name="hitElem"/>
		<xsl:for-each select="$sectionInfo/hit-detail/field-section">
			<xsl:variable name="secName" select="@labelKey"/>
			<fo:table table-layout="fixed" width="100%" border="thin solid gray">
				<fo:table-column/>
				<fo:table-body><fo:table-row></fo:table-row>
					<fo:table-row>
						<fo:table-cell background-color="silver" font-weight="bold">
							<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/*[name() = $secName]" mode="getText"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
						<fo:table-cell>
							<xsl:call-template name="setSection">
								<xsl:with-param name="setName" select="@set"/>
								<xsl:with-param name="hitElem" select="$hitElem"/>
							</xsl:call-template>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<fo:block>&#160;</fo:block>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeHitAddlDetails">
		<xsl:param name="hitCnt"/>
		<xsl:param name="hitElem"/>
		<fo:block background-color="silver" font-weight="bold">
			<xsl:apply-templates select="$texts/hits/addl-hit-title" mode="getText"/>
		</fo:block>
		<xsl:for-each select="$sectionInfo/hit-addl-detail/field-section">
			<xsl:variable name="secName" select="@labelKey"/>
			<fo:table table-layout="fixed" width="100%" border="thin solid gray">
				<fo:table-column/>
				<fo:table-body><fo:table-row></fo:table-row>
					<xsl:if test="$secName != ''">
						<fo:table-row>
							<fo:table-cell background-color="silver" font-weight="bold" >
								<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/*[name() = $secName]" mode="getText"/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</xsl:if>
					<fo:table-row>
						<fo:table-cell>
							<xsl:call-template name="setSection">
								<xsl:with-param name="setName" select="@set"/>
								<xsl:with-param name="hitElem" select="$hitElem"/>
							</xsl:call-template>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<fo:block>&#160;</fo:block>
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
			<xsl:if test="$secTitle != ''">
				<fo:block background-color="silver">
					<xsl:apply-templates select="$texts/hits/*[name() = $secTitle]" mode="getText"/>
				</fo:block>
			</xsl:if>
			<fo:table table-layout="fixed" width="100%">
				<xsl:for-each select="row/field">
					<xsl:if test="position() &lt;= $colNums">
						<fo:table-column/>
						<fo:table-column/>
					</xsl:if>
				</xsl:for-each>
				<fo:table-body><fo:table-row></fo:table-row>
					<xsl:for-each select="row">
						<fo:table-row>
							<xsl:for-each select="field">
								<xsl:variable name="fldKey" select="."/>
								<fo:table-cell>
									<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/*[name() = $fldKey]" mode="getText"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<xsl:variable name="fval" select="$hitElem/elem[@name = $fldKey]"/>
									<fo:block><xsl:value-of select="$fval"/></fo:block>
									<!--
									<xsl:call-template name="highlightFreeText">
										<xsl:with-param name="fKey" select="$fldKey"/>
										<xsl:with-param name="fVal" select="$fval"/>
									</xsl:call-template>
									-->
								</fo:table-cell>
							</xsl:for-each>
						</fo:table-row>
					</xsl:for-each>
				</fo:table-body>
			</fo:table>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeAliases">
		<xsl:param name="hitElem"/>
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" background-color="silver"><xsl:apply-templates select="$texts/hits/aliases" mode="getText"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				
					<fo:table-row>
						<fo:table-cell>
						<xsl:for-each select="$hitElem/elem[@name = 'aliases']/elem[@name = 'displayName']">
							<fo:block>
		                	<xsl:call-template name="checkStructuredHighlightsForNames">
							    <xsl:with-param name="matchValue" select="../elem[@name = 'matchedName']"/>
								<xsl:with-param name="value" select="."/>
	                      		<xsl:with-param name="hit" select="$hitElem"/>
		                    </xsl:call-template>
		                    </fo:block>
	                    </xsl:for-each>
						</fo:table-cell>
					</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeAliasesAndIDs">
		<xsl:param name="hitElem"/>
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column column-width="50%"/>
			<fo:table-column column-width="50%"/>
			<fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<xsl:call-template name="writeAliases">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</fo:table-cell>
					<fo:table-cell>
						<xsl:call-template name="writeIds">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeDOB">
		<xsl:param name="hitElem"/>
		 <fo:table table-layout="fixed" width="100%">
			<fo:table-column/>
			<fo:table-column/>
			<!--fo:table-column/-->
			 <fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell width="100%" number-columns-spanned="2">
						<fo:block font-weight="bold" background-color="silver"><xsl:apply-templates select="$texts/hits/dob" mode="getText"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell width="50%">
							<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/age" mode="getText"/></fo:block>
					</fo:table-cell>
					<fo:table-cell width="50%">
						<fo:block><xsl:value-of select="$hitElem/elem[@name = 'age']"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				
				<fo:table-row>
					<fo:table-cell width="50%">
							<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/ageAsOfDate" mode="getText"/></fo:block>
					</fo:table-cell>
					<fo:table-cell width="50%">
						<fo:block><xsl:value-of select="$hitElem/elem[@name = 'ageAsOfDate']"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				
				<fo:table-row>
					<fo:table-cell width="50%">
							<fo:block font-weight="bold"><xsl:apply-templates select="$texts/hits/placeOfBirth" mode="getText"/></fo:block>
					</fo:table-cell>
					<fo:table-cell width="100%">
						 <fo:table table-layout="fixed" width="100%">
							<fo:table-column/>
							<fo:table-body><fo:table-row></fo:table-row>
							<fo:table-row>
							<fo:table-cell width="50%">
							<fo:block>
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
							</fo:block>
							</fo:table-cell>
							</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeDobAndAddresses">
		<xsl:param name="hitElem"/>
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column/>
			<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell width="50%">
						<xsl:call-template name="writeDOB">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</fo:table-cell>
					<fo:table-cell width="50%">
						<xsl:call-template name="writeAddresses">
							<xsl:with-param name="hitElem" select="$hitElem"/>
						</xsl:call-template>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeAddlInfo">
		<xsl:param name="hitElem"/>
		<xsl:variable name="extsrc"/>
		<fo:table table-layout="fixed" width="100%" border="thin solid gray">
			<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
			<xsl:choose>
				<xsl:when test="substring($hitElem/elem[@name = 'listId']/text(),1,7) = 'FACTIVA'"> 
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
											<fo:block font-weight="bold" text-decoration="underline">
											   <xsl:variable name="alertProfileNotes"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.profilenotes"  /> </xsl:variable>
	   	                                       <xsl:value-of select="$alertProfileNotes"/>
											</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'ProfileNotes']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						    <xsl:variable name="alertExternalSource"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.externalsource"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertExternalSource"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'External Source']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
								
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						    <xsl:variable name="alertLinkedTo"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.linkedto"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertLinkedTo"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Linked To']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						  <xsl:variable name="alertImages"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.images"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertImages"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Image']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>				
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						    <xsl:variable name="alertOtherRoles"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.otherroles"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertOtherRoles"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Other Roles']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>				
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						   <xsl:variable name="alertPreviousRoles"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.previousroles"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertPreviousRoles"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Previous Roles']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>				
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						   <xsl:variable name="alertSanctionReferences"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.sanctionreferences"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertSanctionReferences"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Sanction References']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>				
			</xsl:when>
			<xsl:when test="$hitElem/elem[@name = 'listId'][. = 'FinCEN314a']">
			  <fo:table-row>
				 <fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						   <xsl:variable name="alertTrackingNum"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.trackingnumber"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertTrackingNum"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Tracking Number']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
				 </fo:table-cell>
			   </fo:table-row>
			   <fo:table-row>
				 <fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						   <xsl:variable name="alertPhoneNum"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.phonenumbers"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertPhoneNum"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Phone Numbers']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
				  </fo:table-cell>
				</fo:table-row>
			</xsl:when>
			<xsl:otherwise>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						   <xsl:variable name="alertFurtherInformation"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.furtherinformation"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertFurtherInformation"/>
						</fo:block>
							<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Further Information']">
								<fo:block><xsl:value-of select="../elem[@name = 'value']"/>&#160;</fo:block>
							</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						    <xsl:variable name="alertExternalSource"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.externalsource"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertExternalSource"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'External Source']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						    <xsl:variable name="alertLinkedTo"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.linkedto"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertLinkedTo"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Linked To']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
						    <xsl:variable name="alertCompany"> <rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.company"  /> </xsl:variable>
	   	                    <xsl:value-of select="$alertCompany"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'Company']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepStatus">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.pepstatus"/>
							</xsl:variable>
							<xsl:value-of select="$pepStatus"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Status']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepRole">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.peprole"/>
							</xsl:variable>
							<xsl:value-of select="$pepRole"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepRoleLevel">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.peprolelevel"/>
							</xsl:variable>
							<xsl:value-of select="$pepRoleLevel"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Level']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepPosition">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.pepposition"/>
							</xsl:variable>
							<xsl:value-of select="$pepPosition"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Position']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepRoleStatus">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.peprolestatus"/>
							</xsl:variable>
							<xsl:value-of select="$pepRoleStatus"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Status']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepRoleStartDate">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.peprolestartdate"/>
							</xsl:variable>
							<xsl:value-of select="$pepRoleStartDate"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Start Date']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepRoleEndDate">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.peproleenddate"/>
							</xsl:variable>
							<xsl:value-of select="$pepRoleEndDate"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role End Date']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell border-bottom-style="dotted" border-bottom-color="black" border-bottom-width="thin" border-right-style="dotted" border-right-color="black" border-right-width="thin">
						<fo:block font-weight="bold" text-decoration="underline">
							<xsl:variable name="pepRoleBio">
								<rcm:t byId="true" text="actimize.wlf.alerts.actions.text.pdf.peprolebio"/>
							</xsl:variable>
							<xsl:value-of select="$pepRoleBio"/>
						</fo:block>
						<xsl:for-each select="$hitElem/elem[@name = 'additionalInfo']/elem[@name = 'name'][. = 'PEP Role Bio']">
							<fo:block>
								<xsl:value-of select="../elem[@name = 'value']"/>&#160;
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
			</xsl:otherwise>
			</xsl:choose>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeScoreFactors">
		<xsl:param name="hitElem"/>
		<fo:table table-layout="fixed" width="50%" border="thin solid gray">
		<fo:table-column/>
		<fo:table-column/>
		<fo:table-column/>
		<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell number-columns-spanned="4">
						<fo:block>
							<xsl:apply-templates select="$texts/hits/hitScore" mode="getText"/>&#160;
							<xsl:value-of select="$hitElem/elem[@name = 'score']"/>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row background-color="silver" text-align="center">
					<fo:table-cell >
						<fo:block><xsl:apply-templates select="$texts/hits/factor" mode="getText"/></fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block><xsl:apply-templates select="$texts/hits/value" mode="getText"/></fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block><xsl:apply-templates select="$texts/hits/factorScore" mode="getText"/></fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block><xsl:apply-templates select="$texts/hits/impact" mode="getText"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				<xsl:for-each select="$hitElem/elem[@name = 'scoreFactors']/elem[@name = 'scoreFactors']">
					<fo:table-row  text-align="center">
						<fo:table-cell>
							<fo:block>
							<xsl:variable name="userText">  <xsl:value-of select="elem[@name = 'factorDesc']"/> </xsl:variable>
                            <xsl:variable name="origionalText"> <rcm:t select="elem[@name = 'factorDesc']" /> </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$origionalText != ''">   <xsl:value-of select="$origionalText" disable-output-escaping="yes"/> </xsl:when>
                                <xsl:otherwise>     <xsl:value-of select="$userText"/> </xsl:otherwise>
                            </xsl:choose>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block>
							<xsl:variable name="userText">  <xsl:value-of select="elem[@name = 'factorValue']"/> </xsl:variable>
                            <xsl:variable name="origionalText"> <rcm:t select="elem[@name = 'factorValue']"  /> </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$origionalText != ''">   <xsl:value-of select="$origionalText" disable-output-escaping="yes"/> </xsl:when>
                                <xsl:otherwise>     <xsl:value-of select="$userText"/> </xsl:otherwise>
                            </xsl:choose>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="elem[@name = 'factorScore']"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<xsl:attribute name="xsl:use-attribute-sets">impact_<xsl:value-of select="elem[@name = 'factorImpact']"/></xsl:attribute>
							<xsl:variable name="vImpact" select="elem[@name = 'factorImpact']"/>
							<xsl:choose>
								<xsl:when test="$vImpact = 'HIGH'">
									<fo:block color="red" font-weight="bold" text-decoration="underline"><xsl:apply-templates select="$texts/impacts/*[name() = $vImpact]" mode="getText"/></fo:block>			
								</xsl:when>
								<xsl:when test="$vImpact = 'MEDIUM'">
									<fo:block color="orange" font-weight="bold"><xsl:apply-templates select="$texts/impacts/*[name() = $vImpact]" mode="getText"/></fo:block>			
								</xsl:when>
								<xsl:when test="$vImpact = 'LOW'">
									<fo:block color="green" font-weight="bold"><xsl:apply-templates select="$texts/impacts/*[name() = $vImpact]" mode="getText"/></fo:block>			
								</xsl:when>
								<xsl:when test="$vImpact = 'CORRECTIVE'">
									<fo:block color="blue" font-weight="bold"><xsl:apply-templates select="$texts/impacts/*[name() = $vImpact]" mode="getText"/></fo:block>			
								</xsl:when>
							</xsl:choose>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeMsgIds">
		<xsl:param name="idFld"/>
		<xsl:for-each select="$rootDocument/content/alert/alert-header/elem[@name = $idFld]">
			<xsl:if test="elem[@name = 'idType'] != ''">
				<xsl:value-of select="elem[@name = 'idType']"/>
			</xsl:if>
			<xsl:if test="elem[@name = 'idCountry'] != ''">
				&#160;(<xsl:value-of select="elem[@name = 'idCountry']"/>)
			</xsl:if>
			<xsl:if test="elem[@name = 'idNumber'] != ''">
				: <xsl:value-of select="elem[@name = 'idNumber']"/>
			</xsl:if>; 
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="writeIds">
		<xsl:param name="hitElem"/>
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell >
						<fo:block font-weight="bold" background-color="silver"><xsl:apply-templates select="$texts/hits/ids" mode="getText"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<xsl:for-each select="$hitElem/elem[@name = 'ids']">
							<fo:block>
							<xsl:value-of select="./elem[@name = 'idType']"/> (<xsl:value-of select="./elem[@name = 'idCountry']"/>): 
							<!-- <xsl:value-of select="@idNumber"/><br/>  -->
							<xsl:call-template name="checkStructuredHighlights">
							  <xsl:with-param name="value" select="./elem[@name = 'idNumber']"/>
							  <xsl:with-param name="hit" select="$hitElem"/>
							</xsl:call-template>
							</fo:block>
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="writeAddresses">
		<xsl:param name="hitElem"/>
		<fo:table table-layout="fixed"  width="100%">
			<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block font-weight="bold" background-color="silver"><xsl:apply-templates select="$texts/hits/addresses" mode="getText"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<xsl:for-each select="$hitElem/elem[@name = 'addresses']">
							<fo:block>
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
									</xsl:call-template>,</xsl:if>
								<xsl:if test="normalize-space($state)!=''"><xsl:value-of select="$state"/>,</xsl:if>
								<xsl:if test="normalize-space($zip)!=''"><xsl:value-of select="$zip"/>,</xsl:if>
								<xsl:if test="normalize-space($country)!=''"><xsl:value-of select="$country"/></xsl:if>
							</fo:block> 
						</xsl:for-each>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
		<xsl:template name="writeCustomFields">
		<xsl:param name="hitElem"/>
		<fo:table  table-layout="fixed" width="100%">
			<fo:table-column/>
			<fo:table-column/>
			<fo:table-body><fo:table-row></fo:table-row>
				<xsl:if test="$texts/hits/cs_1 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_1" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_1']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_2 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_2" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_2']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_3 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_3" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_3']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_4 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_4" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_4']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_5 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_5" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_5']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_6 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_6" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:apply-templates select="$hitElem/elem[@name = 'cs_6']" mode="getBoolTypes"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_7 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_7" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:apply-templates select="$hitElem/elem[@name = 'cs_7']" mode="getBoolTypes"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_8 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_8" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:apply-templates select="$hitElem/elem[@name = 'cs_8']" mode="getBoolTypes"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_9 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_9" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:apply-templates select="$hitElem/elem[@name = 'cs_9']" mode="getBoolTypes"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_10 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_10" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:apply-templates select="$hitElem/elem[@name = 'cs_10']" mode="getBoolTypes"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_11 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_11" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_11']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_12 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_12" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_12']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_13 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_13" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_13']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_14 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_14" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_14']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_15 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_15" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_15']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_16 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_16" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_16']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_17 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_17" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_17']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
				<xsl:if test="$texts/hits/cs_18 != ''">
					<fo:table-row>
						<fo:table-cell   width="20%">
							<fo:block><xsl:apply-templates select="$texts/hits/cs_18" mode="getText"/></fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block><xsl:value-of select="$hitElem/elem[@name = 'cs_18']"/></fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:if>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template name="checkStructuredHighlights">
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $value"/>
		<xsl:choose>
			<xsl:when test="boolean($match)">
				<fo:inline color="red"><xsl:value-of select="$value"/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:value-of select="$value"/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="checkStructuredHighlightsForNames">
		<xsl:param name="matchValue"/>
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $matchValue"/>
		<xsl:choose>
			<xsl:when test="boolean($match)">
				<fo:inline color="red"><xsl:value-of select="$value"/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:value-of select="$value"/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="checkHeaderHighlights">
		<xsl:param name="value"/>
		<xsl:param name="hit"/>
		<xsl:variable name="match" select="$hit/elem[@name = 'explanations']/elem/elem[@name = 'Explanation']/text() = $value"/>
		<xsl:choose>
			<xsl:when test="$match">
				<fo:block color="red"><xsl:value-of select="$value"/></fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block><xsl:value-of select="$value"/></fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		<xsl:template name="while">                         
	<xsl:param name="i"/> 
    <xsl:param name="elimStateChar"/>     
		<xsl:variable name="tmp" select="substring($elimStateChar,$i,1 )"/>         
		<xsl:if test="$tmp != ''">
			<xsl:call-template name="translate">
			<xsl:with-param name="char" select="$tmp"/>
			</xsl:call-template>           
				<xsl:call-template name="while">
			<xsl:with-param name="i" select="$i + 1"/>
			<xsl:with-param name="elimStateChar" select="$elimStateChar"/>
			</xsl:call-template>
		</xsl:if>   
    </xsl:template>
	   
    <xsl:template name="translate">                         
        <xsl:param name="char"/>
        <xsl:choose>
            <xsl:when test="$char='0'">000000</xsl:when>
			<xsl:when test="$char='1'">000001</xsl:when>
            <xsl:when test="$char='2'">000010</xsl:when>
            <xsl:when test="$char='3'">000011</xsl:when>
            <xsl:when test="$char='4'">000100</xsl:when>
            <xsl:when test="$char='5'">000101</xsl:when>
            <xsl:when test="$char='6'">000110</xsl:when>
            <xsl:when test="$char='7'">000111</xsl:when>
            <xsl:when test="$char='8'">001000</xsl:when>
            <xsl:when test="$char='9'">001001</xsl:when>
            <xsl:when test="$char=':'">001010</xsl:when>
            <xsl:when test="$char=';'">001011</xsl:when>
            <xsl:when test="$char='&lt;'">001100</xsl:when>
            <xsl:when test="$char='='">001101</xsl:when>
            <xsl:when test="$char='>'">001110</xsl:when>
            <xsl:when test="$char='?'">001111</xsl:when>
            <xsl:when test="$char='@'">010000</xsl:when>
            <xsl:when test="$char='A'">010001</xsl:when>
            <xsl:when test="$char='B'">010010</xsl:when>
            <xsl:when test="$char='C'">010011</xsl:when>
            <xsl:when test="$char='D'">010100</xsl:when>
            <xsl:when test="$char='E'">010101</xsl:when>
            <xsl:when test="$char='F'">010110</xsl:when>
            <xsl:when test="$char='G'">010111</xsl:when>
            <xsl:when test="$char='H'">011000</xsl:when>
            <xsl:when test="$char='I'">011001</xsl:when>
            <xsl:when test="$char='J'">011010</xsl:when>
            <xsl:when test="$char='K'">011011</xsl:when>
            <xsl:when test="$char='L'">011100</xsl:when>
            <xsl:when test="$char='M'">011101</xsl:when>
            <xsl:when test="$char='N'">011110</xsl:when>
            <xsl:when test="$char='O'">011111</xsl:when>
            <xsl:when test="$char='P'">100000</xsl:when>
            <xsl:when test="$char='Q'">100001</xsl:when>
            <xsl:when test="$char='R'">100010</xsl:when>
            <xsl:when test="$char='S'">100011</xsl:when>
            <xsl:when test="$char='T'">100100</xsl:when>
            <xsl:when test="$char='U'">100101</xsl:when>
            <xsl:when test="$char='V'">100110</xsl:when>
            <xsl:when test="$char='W'">100111</xsl:when>
            <xsl:when test="$char='X'">101000</xsl:when>
            <xsl:when test="$char='Y'">101001</xsl:when>
            <xsl:when test="$char='Z'">101010</xsl:when>
            <xsl:when test="$char='['">101011</xsl:when>
            <xsl:when test="$char='\'">101100</xsl:when>
            <xsl:when test="$char=']'">101101</xsl:when>
            <xsl:when test="$char='^'">101110</xsl:when>
            <xsl:when test="$char='_'">101111</xsl:when>
            <xsl:when test="$char='`'">110000</xsl:when>
            <xsl:when test="$char='a'">110001</xsl:when>
            <xsl:when test="$char='b'">110010</xsl:when>
            <xsl:when test="$char='c'">110011</xsl:when>
            <xsl:when test="$char='d'">110100</xsl:when>
            <xsl:when test="$char='e'">110101</xsl:when>
            <xsl:when test="$char='f'">110110</xsl:when>
            <xsl:when test="$char='g'">110111</xsl:when>
            <xsl:when test="$char='h'">111000</xsl:when>
            <xsl:when test="$char='i'">111001</xsl:when>
            <xsl:when test="$char='j'">111010</xsl:when>
            <xsl:when test="$char='k'">111011</xsl:when>
            <xsl:when test="$char='l'">111100</xsl:when>
            <xsl:when test="$char='m'">111101</xsl:when>
            <xsl:when test="$char='n'">111110</xsl:when>
            <xsl:when test="$char='o'">111111</xsl:when>         
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
