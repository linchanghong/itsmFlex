var minWidth = 1200;
var minHeight = 600;
var winWidth = 0;
var winHeight = 0;
function findDimensions() {
	// 获取窗口宽度和高度
	
	//IE不支持innerHeight属性，据不同的版本用document.body或document.documentElement的clientHeight替代。
	if (window.innerWidth) {
		winWidth = window.innerWidth;
		winHeight = window.innerHeight;
	} else if (document.documentElement && document.documentElement.clientHeight) {
		winHeight = document.documentElement.clientHeight;
		winWidth = document.documentElement.clientWidth;
	} else if (document.body && document.body.clientWidth) {
		winWidth = document.body.clientWidth;
		winHeight = document.body.clientHeight;
	} 

	var cssSize = document.styleSheets[0].rules
			|| document.styleSheets[0].cssRules;
	
	if (winWidth < minWidth) {
		cssSize[0].style.width = minWidth.toString() + "px";
	} else {
		cssSize[0].style.width = "100%";
	}

	if (winHeight < minHeight) {
		cssSize[0].style.height = minHeight.toString() + "px";
	} else {
		cssSize[0].style.height = "100%";
	}
}
window.onresize = findDimensions;

function pageInit() {
	// 调用函数，获取数值
	findDimensions();
}