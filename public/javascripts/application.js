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

function validateQuickTransaction() {
  clearQuickTransactionErrors();
  if ($("#quicktxn #quicktxn_posted_on").val().toString() == "") {
    return reportQuickTransactionError("quicktxn_posted_on", "Vous devez indiquer une date");
  } else if ($("#quicktxn #quicktxn_debit_account").val().toString() == "") {
    return reportQuickTransactionError("quicktxn_debit_account", "Vous devez indiquer le compte débiteur");
  } else if ($("#quicktxn #quicktxn_credit_account").val().toString() == "") {
    return reportQuickTransactionError("quicktxn_credit_account", "Vous devez indiquer le compte créditeur");
  } else if ($("#quicktxn #quicktxn_amount").val().toString() == "") {
    return reportQuickTransactionError("quicktxn_amount", "Vous devez indiquer un montant");
  } else if ($("#quicktxn #quicktxn_description").val().toString() == "") {
    return reportQuickTransactionError("quicktxn_description", "Vous devez indiquer une description");
  }

  return true;
}

function reportQuickTransactionError(fieldId, message) {
  $("#quicktxn #error").html(message).show("fast");
  $("#quicktxn #" + fieldId).addClass("in-error").focus();
  return false;
}

function clearQuickTransactionErrors() {
  $("#quicktxn #error").hide("fast");
  $("#quicktxn :input").removeClass("in-error");
}

$(document).ready(function() {
  $("#quicktxn :submit").click(validateQuickTransaction);
  $("#txn .add-account").click(function() {
    var fields = $("#txn #new-account :input");
    $.ajax({
      url: this.href,
      cache: false,
      data: fields.serializeArray(), 
      dataType: "script"
    });
    return false;
  });
});
