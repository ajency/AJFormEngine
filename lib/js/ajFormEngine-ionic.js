jQuery(document).ready(function($) {
  ajForm.get_submit_button = function() {
    return '<div class="list list-inset"> <button class="button button-block btn-primary" type="submit"> Save </button> </div>';
  };
  ajForm.get_textbox = function(field, name, secondaryName) {
    var value;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    value = field.value ? field.value : '';
    return "<label class='item item-input'> <input value='" + value + "' type='text' " + (ajForm.validations(field.validation)) + " " + (ajForm.attributes(field.attributes)) + " class='form-control input-sm' name=" + name + "> </label>";
  };
  ajForm.get_dropdown = function(field, name, secondaryName) {
    var html, selectLabel;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '<label class="item item-input item-select">';
    html += '<select ' + ajForm.validations(field.validation) + ' ' + ajForm.attributes(field.attributes) + ' name="' + name + '" class="form-control">';
    selectLabel = _.has(field, 'selectLabel') ? field.selectLabel : 'Select';
    html += '<option value="">' + selectLabel + '</option>';
    _.each(field.options, (function(_this) {
      return function(option) {
        var opt;
        opt = ajForm.formatOptions(option);
        return html += '<option value="' + opt.value + '" ' + ajForm.preSelected(field, option) + '>' + opt.label + '</option>';
      };
    })(this));
    html += '</select>';
    return html += '</label>';
  };
  ajForm.get_radio = function(field, name, secondaryName) {
    var html;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '';
    _.each(field.options, function(option) {
      var opt;
      opt = ajForm.formatOptions(option);
      return html += '<label class="item item-radio"> <input ' + ajForm.validations(field.validation) + ' type="radio" name="' + name + '" value="' + opt.value + '" ' + ajForm.preSelected(field, option) + ' ' + ajForm.attributes(field.attributes) + '> <div class="item-content">' + opt.label + '</div> <i class="radio-icon ion-checkmark"></i> </label>';
    });
    return html;
  };
  ajForm.get_checkbox = function(field, name, secondaryName) {
    var html;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '';
    _.each(field.options, function(option) {
      var opt;
      opt = ajForm.formatOptions(option);
      return html += '<label class="checkbox"> <input ' + ajForm.validations(field.validation) + ' type="checkbox" name="' + name + '" value="' + opt.value + '" ' + ajForm.preSelected(field, option) + ' ' + ajForm.attributes(field.attributes) + '>' + opt.label + '</label>';
    });
    return html;
  };
  return ajForm.triggerFieldPlugins = function(element) {
    ajForm.addDatePicker(element);
    ajForm.addAutoSuggest(element);
    ajForm.setAutogrowTextHeight(element);
    ajForm.addMultiselectDropdown(element);
    ajForm.addGeoSearch(element);
    return ajForm.bindButtonEvents(element);
  };
});
