$(document).ready(function() {
	new QRCode(document.getElementById("qrcode"), "http://google.com");
});

function clic() {
	var fonction = document.getElementById("fonction").value.split(' ').join('');
	$(location).attr('href','losanges.html?fonction="' + fonction + '"');
}