<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:template match="/" name="generateAlertLayout">
		
		<html>
		<head></head>
		<body>
		===<xsl:value-of select="$msgStruct"/>===
		<xsl:if test="$msgStruct = 'STRUCTURED'">
			<xsl:call-template name="writeAlertHeaderStructured" />	
		</xsl:if>
		<xsl:if test="$msgStruct = 'SWIFT'">
			<xsl:call-template name="writeAlertHeaderSwift" />	
		</xsl:if>
		<xsl:call-template name="writeAlertDetails" />
		<xsl:call-template name="writeHitHeader"/>
		<xsl:call-template name="writeHitDetails"/>
		<xsl:call-template name="writeHitAddlDetails"/>
		</body>
		</html>
	</xsl:template>
</xsl:stylesheet>