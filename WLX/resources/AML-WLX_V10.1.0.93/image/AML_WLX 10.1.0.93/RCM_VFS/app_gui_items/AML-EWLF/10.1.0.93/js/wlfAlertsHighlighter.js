function InputFieldHighlighter() {
  this.h= new Array();

  this.register = function(hlt) {
    this.h.push(hlt)
  }

  this.process = function() {
    for(var x = 0; x<this.h.length; x++) { this.h[x].highlight(); }
  }
}

function FullFieldHighlighter(id)
{
this.id = id;

  this.highlight = function() {
    document.getElementById(this.id).style.color="#ff0000";
  }

}

function FullFieldHighlighterMX(id, matchValuesString) {
  this.id = id;
  this.matchValuesString = matchValuesString;

  this.highlight = function() {
    var spanElement = document.getElementById(this.id);
    if (!spanElement) {
      return;
    }
    var fieldValue = spanElement.innerText;

    var matchValuesArray = this.matchValuesString.split('|').map(function(item) {
      return item.trim();
    });

    matchValuesArray.forEach((matchValue) => {
      var regex = new RegExp('\\b' + matchValue.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b', 'gi');
      fieldValue = fieldValue.replace(regex, (matched) => {
        return `<span style="color: red;">${matched}</span>`;
      });
    });
    spanElement.innerHTML = fieldValue;
  };
}


function FreeTextFieldHighlighter(id, positions) {
  this.id = id;
  this.positions = positions;

  this.highlight = function() {
    var node = document.getElementById(this.id);
    var diamond = String.fromCharCode(9830);
	var doubleDiamond = diamond + diamond;
    if(node) {
      var value= node.innerHTML;
	  //Replace diamond(break) character with 2 of them to simulate 2 characters CRLF. This change will be reverted after highlighting.
	  value = value.replace(new RegExp(diamond, "g"), doubleDiamond);
	  //Replace all &amp; &lt; &gt;  strings to theirs equivalents because of highlighting issue in alerts, where RCM display special characters incorrectly. Check the SR: 254179.
      value = value.replace(new RegExp("&lt;",'g'),"<");
      value = value.replace(new RegExp("&gt;",'g'),">");
      value = value.replace(new RegExp("&amp;",'g'),"&");
      value = value.replace(new RegExp("&nbsp;",'g')," ");
      var newValue=""
      var offset = 0
      for(var i=0; i<this.positions.length; i++) {
        var p = this.positions[i];
        var begin = value.substring(0, p.start-offset);
        begin = value.substring(0, begin.length)
		var content = value.substring(p.start-offset, p.end-offset);
        value = value.substring(p.end-offset, value.length);
//		  Change JS script based on ticket 0138445 and 119208
        if (offset < p.end) {offset = p.end;} //Only update offset if current highlighted match is longer than already highlighted match.
        if (content != "") {newValue += begin + '<span style="color: #ff0000">' + content + '</span>';} //Don't write a blank <span>
//        offset = p.end
//        newValue += begin + '<span style="color: #ff0000">' + content + '</span>'
      }
      newValue += value;
	  //revert breaks
	  newValue = newValue.replace(new RegExp(doubleDiamond, "g"), diamond);
      node.innerHTML = newValue.replace(new RegExp(diamond, "g"), "<br/>");
    }
  }
}

function FreeTextFieldPositions(start, end, text) {
  this.start = start - 1;
  this.end = end - 1;
  this.text = text;
}
