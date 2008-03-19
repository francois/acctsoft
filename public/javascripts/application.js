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

function toNumber(value, digits) {
  var exponent = Math.pow(10, digits);
  var pre = value.gsub(/[^-\.\d]/, '');
  return Math.ceil(pre * exponent) / exponent;
}

function toMoney(value, digits) {
  var exponent = Math.pow(10, digits);
  value = Math.ceil(value * exponent) / exponent;
  value = value.toString();
  if (-1 == value.indexOf('.')) value += '.'
  value += '0000000000';
  return value.substring(0, value.indexOf('.') + digits + 1)
}

function updateLinePrice(object) {
  var quantity = toNumber($F(object + '_quantity'), 4);
  if (0 == quantity) quantity = 1;
  var unit_price = toNumber($F(object + '_unit_price'), 4);
  $(object + '_extension').value = toMoney(quantity * unit_price, 2);
}

$(document).ready(function() {
  $(".notice").hide().slideDown("slow");
});
