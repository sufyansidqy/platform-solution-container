<?xml version="1.0" encoding="UTF-8"?>
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

<xsl:param name="version"/>
<xsl:variable name="userTexts" select="document('xml/CF_texts.xml')/texts"/>
<xsl:variable name="texts" select="document('xml/CF_defaultTexts.xml')/texts"/>

<xsl:template match="*" mode="getText">
	<xsl:variable name="section" select="name(..)"/>
	<xsl:variable name="id" select="name(.)"/>
	<xsl:variable name="originalText" select="$userTexts/*[name()=$section]/*[name() = $id]/." />
           <xsl:variable name="userText"> 
                     <rcm:t byId="true" select ="$originalText" />
           </xsl:variable>
	<xsl:choose>
			<xsl:when test="$userText != ''">
				<xsl:value-of select="$userText" disable-output-escaping="yes"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
	</xsl:choose>
</xsl:template>
</xsl:stylesheet>
