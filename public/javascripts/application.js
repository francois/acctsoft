function updateGroupTotal(root, className, target) {
  var total = 0.0;

  var fields = document.getElementsByClassName(className, root);
  for (var i = 0; i < fields.length; i++) {
    match = fields[i].value.match(/(-?\d*\.?\d+?)$/)
    if (null == match) continue;

    amount = match[1];
    if ('.' == amount.substring(0,1)) amount = '0' + amount;
    total += parseFloat(amount);
  }

  var value = (Math.round(total * 100.0) / 100.0).toString();
  if (-1 == value.indexOf('.')) value += '.';
  value += '00';
  value = value.substr(0, value.indexOf('.') + 3);
  $(target).innerHTML = '<span class="money"><span class="symbol">$</span>' + value + '</span>';
}
