var acookie = document.cookie.split("; ");

function getck(sname) {// 获取单个cookies
	for ( var i = 0; i < acookie.length; i++) {
		var equeIndex = acookie[i].indexOf("=");
		if (sname == acookie[i].substring(0,equeIndex)) {
			if (acookie[i].length > equeIndex) {
				//document.write(unescape(acookie[i].substring(equeIndex+1)));
				return URLencode(unescape(acookie[i].substring(equeIndex+1)));
			} else {
				return "";
			}
		}
	}
	return "";
}


function URLencode(sStr) 
{
    return escape(sStr).replace(/\+/g, '%2B').replace(/\"/g,'%22').replace(/\'/g, '%27').replace(/\//g,'%2F');
}