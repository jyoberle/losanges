$(document).ready(function() {
	new QRCode(document.getElementById("qrcode"), "https://jyoberle.github.io/losanges/Losanges71/");
});

function clic() {
	var fonction = document.getElementById("fonction").value.split(' ').join('');
	$(location).attr('href','losanges.html?fonction="' + fonction + '"');
}