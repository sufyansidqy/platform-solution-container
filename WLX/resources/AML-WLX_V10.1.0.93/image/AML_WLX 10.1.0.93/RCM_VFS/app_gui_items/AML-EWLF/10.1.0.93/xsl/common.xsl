<?xml version="1.0" encoding="US-ASCII"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format">
<xsl:param name="version"/>
<xsl:template match="*" mode="getJobTypes">
	<xsl:choose>
		<xsl:when test=". = 'List Loading'">
			<xsl:apply-templates select="$texts/jobTypes/etl" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'List Synchronization'">
			<xsl:apply-templates select="$texts/jobTypes/listsync" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'Scheduled Batch Scan'">
			<xsl:apply-templates select="$texts/jobTypes/sb" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'Self Service Batch Scan'">
			<xsl:apply-templates select="$texts/jobTypes/ssb" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'On Demand'">
			<xsl:apply-templates select="$texts/jobTypes/od" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'Real-time'">
			<xsl:apply-templates select="$texts/jobTypes/rt" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'Batch Message Screening'">
			<xsl:apply-templates select="$texts/jobTypes/bms" mode="getText"/>
		</xsl:when>
		<xsl:when test=". = 'Real-time Message'">
			<xsl:apply-templates select="$texts/jobTypes/rtm" mode="getText"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>
<xsl:template match="*" mode="getEntityTypes">
	<xsl:variable name="infoVal" select="."/>
	<xsl:choose>
		<xsl:when test="$infoVal = 'PERSON' or $infoVal = 'P' or $infoVal = 'Person'">
			<xsl:apply-templates select="$texts/entityTypes/person" mode="getText"/>
		</xsl:when>
		<xsl:when test="$infoVal = 'ORGANIZATION' or $infoVal = 'O' or $infoVal = 'Organization'">
			<xsl:apply-templates select="$texts/entityTypes/org" mode="getText"/>
		</xsl:when>
		<xsl:when test="$infoVal = 'COUNTRY'  or $infoVal = 'C'">
			<xsl:apply-templates select="$texts/entityTypes/country" mode="getText"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$infoVal"/>
		</xsl:otherwise>
	</xsl:choose>					
</xsl:template>
<xsl:template match="*" mode="getMatchTypes">
	<xsl:variable name="mtype" select="."/>
	<xsl:choose>
		<xsl:when test="$mtype = 'NAME'">
			<xsl:apply-templates select="$texts/matchTypes/name" mode="getText"/>
		</xsl:when>
		<xsl:when test="$mtype = 'ID'">
			<xsl:apply-templates select="$texts/matchTypes/id" mode="getText"/>
		</xsl:when>
		<xsl:when test="$mtype = 'COUNTRY'">
			<xsl:apply-templates select="$texts/matchTypes/country" mode="getText"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>
<xsl:template match="*" mode="getBoolTypes">
	<xsl:variable name="cfVal" select="."/>
	<xsl:choose>
		<xsl:when test="$cfVal = 'TRUE'">
			<xsl:apply-templates select="$texts/boolTypes/trueVal" mode="getText"/>
		</xsl:when>
		<xsl:when test="$cfVal = 'FALSE'">
			<xsl:apply-templates select="$texts/boolTypes/falseVal" mode="getText"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$cfVal"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="*" mode="getGenderTypes">
	<xsl:variable name="gtype" select="."/>
	<xsl:choose>
		<xsl:when test="$gtype = 'MALE'">
			<xsl:apply-templates select="$texts/gender/MALE" mode="getText"/>
		</xsl:when>
		<xsl:when test="$gtype = 'FEMALE'">
			<xsl:apply-templates select="$texts/gender/FEMALE" mode="getText"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$texts/gender/UNKNOWN" mode="getText"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
</xsl:stylesheet>