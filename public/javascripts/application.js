function updateTransactionVolume(root, selectorExpression, target) {
  var volume = 0.0;

  var fields = new Selector(selectorExpression).findElements(root);
  fields.each(function(field) {
    alert(field.value.inspect());
    volume += field.value;
  });

  $(target).innerHTML = volume.toString();
}