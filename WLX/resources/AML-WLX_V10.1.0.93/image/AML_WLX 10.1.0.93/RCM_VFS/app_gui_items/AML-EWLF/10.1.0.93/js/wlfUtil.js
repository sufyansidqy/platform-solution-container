function resizeAlertWindow(transpose) {
	var fullHeight = document.getElementById('alertDisplayBody').offsetHeight;
	var alertHeaderHeight = document.getElementById('alertHeaderDivId').offsetHeight;
    var sortHitsHeight = document.getElementById('sortHitDiv').offsetHeight;
    var relatedAlertsHeight = document.getElementById('relatedAlerts').offsetHeight;
	var newAlertHitsHeight = fullHeight - alertHeaderHeight - sortHitsHeight;
	
	 if(transpose) {
		 newAlertHitsHeight = fullHeight - sortHitsHeight - relatedAlertsHeight - 4;
	 } else {
		 newAlertHitsHeight = fullHeight - alertHeaderHeight - sortHitsHeight - relatedAlertsHeight - 2;
	 }
    // set with a minimum of 200px
	document.getElementById('hitsDiv').style.height = newAlertHitsHeight > 200 ? newAlertHitsHeight : 200;
}


function HitUtils(totalHits,configuredHitHeader) {
	this.configuredHitHeader = configuredHitHeader;
	this.totalHits = totalHits;
}


HitUtils.prototype.sortByScore = function() {
	var hitsScoreArray = new Array();
	for (var i = 1; i <= this.totalHits; i += 1) {
		//hitsScoreArray[i-1] = i + "-" + document.getElementById('hit' + i + 'score').value;
		hitsScoreArray[i-1] = i + "-" + document.getElementsByName('hit' + i + 'score')[0].value;
	}
	hitsScoreArray.sort(this.sortByScoreCallBackDescending);
	this.rearrangeSortedHits(hitsScoreArray);
}

HitUtils.prototype.sortByViewed = function() {
	var hitsViewedArray = new Array();
	for (var i = 1; i <= this.totalHits; i += 1) {
		hitsViewedArray[i-1] = i + "-" + document.getElementById('hitElemChk' + i).checked;
	}
	hitsViewedArray.sort(this.sortByEliminatedCallBack);
	this.rearrangeSortedHits(hitsViewedArray);
}

HitUtils.prototype.rearrangeSortedHits = function(hitArray) {
	var strHtml = "";
	for(i=0; i < hitArray.length; i++) {
		var hid = hitArray[i].split("-")[0];
		var tmpHtml = document.getElementById('hitDiv' + hid).outerHTML;
		//var configuredHitHeader = '<xsl:apply-templates select="$texts/hits/hit" mode="getText"/>';
		var ndx1 = tmpHtml.indexOf(this.configuredHitHeader+'&nbsp; #');
		var ndx2 = tmpHtml.indexOf(' :');
		if (ndx1 != -1 && ndx2 != -1) {
			tmpHtml = tmpHtml.substring(0,ndx1+this.configuredHitHeader.length+8) + String(i+1) + tmpHtml.substring(ndx2);
		}
		strHtml += tmpHtml + "<br/>";
	}
	document.getElementById('hitsDiv').innerHTML = "";
	document.getElementById('hitsDiv').innerHTML = strHtml;
}

HitUtils.prototype.sortByScoreCallBackDescending = function(a,b) {
	var n1 = a.split("-")[1];
	var n2 = b.split("-")[1];
	return n2 - n1;
}

HitUtils.prototype.sortByScoreCallBackAscending = function(a,b) {
	var n1 = a.split("-")[1];
	var n2 = b.split("-")[1];
	return n1 - n2;
}

HitUtils.prototype.sortByEliminatedCallBack = function(a, b) {
	var n1 = a.split("-")[1];
	var n2 = b.split("-")[1];
	if(n1 == "false" && n2 == "true") {
		return -1;
	}
	if(n1 == "true" && n2 == "false") {
		return 1;
	}
	return 0;
}
