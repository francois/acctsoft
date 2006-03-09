function updateTransactionVolume(root, className, target) {
  var volume = 0.0;

  var fields = document.getElementsByClassName(className, root);
  for (var i = 0; i < fields.length; i++) {
    match = fields[i].value.match(/(-?\d*\.?\d+?)$/)
    if (null == match) continue;

    amount = match[1];
    volume += parseFloat(amount);
  }

  var value = (Math.round(volume * 100.0) / 100.0).toString();
  if (-1 == value.indexOf('.')) value += '.';
  value += '00';
  value = value.substr(0, value.indexOf('.') + 3);
  $(target).innerHTML = '<span class="money"><span class="symbol">$</span>' + value + '</span>';
}
