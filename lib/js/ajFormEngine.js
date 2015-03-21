jQuery(document).ready(function($) {
  var ajForm;
  ajForm = {};
  $.AJFormEngine = function(element, opts) {
    var form, formElement;
    ajForm.options = opts;
    form = '<form>';
    form += ajForm.generateFields(opts.fields, opts.columns);
    form += ajForm.get_submit_button();
    form += '</form>';
    element.append(form);
    ajForm.formElement = formElement = element.find('form');
    ajForm.bindConditions();
    ajForm.addDatePicker(element);
    ajForm.addAutoSuggest(element);
    ajForm.setAutogrowTextHeight(element);
    $(formElement).find('.richtext').wysihtml5();
    $(formElement).bind('submit', ajForm.handleFormSubmit);
    $(formElement.find('.autogrow')).bind('keyup', ajForm.autoGrowText);
    $(formElement.find('a.add-section')).bind('click', ajForm.addSection);
    return form;
  };
  ajForm.generateFields = function(fields, columns, secondaryName) {
    var col, form;
    if (secondaryName == null) {
      secondaryName = false;
    }
    form = '';
    col = 0;
    _.each(fields, function(field, name) {
      var columnClass, fieldFunction, hideElement, _ref;
      if (!columns) {
        columns = 1;
      }
      columnClass = 12 / columns;
      if ((_ref = field.type) === 'section' || _ref === 'repeatable_section' || _ref === 'html_section') {
        if (col !== 0) {
          col = 0;
          form += '</div>';
        }
        if (field.type === 'html_section') {
          return form += ajForm.get_html_section(field, name);
        } else {
          return form += ajForm.get_section(field, name, columns);
        }
      } else {
        if (col === 0) {
          form += '<div class="row">';
        }
        hideElement = field.conditionals ? ' style="display:none" ' : '';
        form += "<div class='ajForm-" + name + (" col-md-" + columnClass + "' ") + hideElement + ">";
        fieldFunction = ajForm['get_' + field.type];
        if (typeof fieldFunction === 'function') {
          if (!field.label) {
            field.label = s.humanize(name);
          }
          if (field.validation && field.validation.required) {
            field.label += '<i class="fa fa-asterisk"></i>';
          }
          form += '<div class="form-group fly-group"> <label class="fly-label classic">' + field.label + '</label>';
          form += fieldFunction(field, name, secondaryName);
          form += '</div>';
        }
        form += '</div>';
        if (col === columns - 1) {
          col = 0;
          return form += '</div>';
        } else if (name === _.last(_.keys(fields))) {
          return form += '</div>';
        } else {
          return col++;
        }
      }
    });
    return form;
  };
  ajForm.get_section = function(section, sectionName, columns) {
    var hideElement, html, secondaryName;
    if (!section.label) {
      section.label = s.titleize(s.humanize(sectionName));
    }
    if (section.columns) {
      columns = section.columns;
    }
    if (section.type === 'repeatable_section') {
      secondaryName = "" + sectionName + "[" + (ajForm.makeid()) + "]";
    }
    hideElement = section.conditionals ? ' style="display:none" ' : '';
    html = '<section class="ajForm-' + sectionName + ' ' + sectionName + '" ' + hideElement + '> <div class="well"> <h5 class="thin">' + section.label + '</h5>';
    html += '<div class="row"><div class="col-md-12">';
    html += ajForm.generateFields(section.fields, columns, secondaryName);
    html += '</div></div></div></section>';
    if (section.type === 'repeatable_section') {
      html += '<div class="form-group clearfix"> <a data-section="' + sectionName + '" class="add-section btn btn-default btn-sm pull-right m-t-10"><i class="fa fa-plus"></i> Add</a> </div>';
    }
    return html;
  };
  ajForm.addSection = function(evt) {
    var button, newName, section, sectionName;
    button = $(evt.target);
    sectionName = button.attr('data-section');
    section = $(ajForm.formElement).find('.' + sectionName).first().clone();
    section.find('input, textarea, select').val('');
    $(ajForm.formElement).find('.' + sectionName).last().after(section);
    newName = "" + (ajForm.makeid());
    section.find('input, textarea, select').each((function(_this) {
      return function(index, ele) {
        var array, completeName, name, nameToReplace;
        name = $(ele).attr('name');
        array = name.split('[');
        nameToReplace = array[1].split(']').shift();
        if (nameToReplace) {
          completeName = name.replace(nameToReplace, newName);
          return $(ele).attr('name', completeName);
        }
      };
    })(this));
    $(ajForm.formElement).find('.' + sectionName).last().append('<div class="form-group clearfix"> <a class="remove-section btn btn-link pull-right">Delete</a> </div>');
    return $(ajForm.formElement).find('a.remove-section').bind('click', ajForm.removeSection);
  };
  ajForm.makeid = function() {
    var i, possible, text, _i;
    text = "";
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (i = _i = 0; _i < 5; i = ++_i) {
      text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
  };
  ajForm.removeSection = function(evt) {
    return $(evt.target).closest('section').fadeOut('fast');
  };
  ajForm.get_submit_button = function() {
    return '<div class="row"> <div class="col-md-12"> <input type="submit" value="Save" class="btn btn-primary" /> </div> </div>';
  };
  ajForm.get_textbox = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<input type="text" ' + ajForm.validations(field.validation) + ' class="form-control input-sm" name="' + name + '">';
  };
  ajForm.get_date = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<input type="date" ' + ajForm.validations(field.validation) + ' class="form-control input-sm" name="' + name + '">';
  };
  ajForm.get_dropdown = function(field, name, secondaryName) {
    var html;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '<select ' + ajForm.validations(field.validation) + '  name="' + name + '" class="form-control">';
    _.each(field.options, (function(_this) {
      return function(opt) {
        opt = ajForm.formatOptions(opt);
        return html += '<option value="' + opt.value + '">' + opt.label + '</option>';
      };
    })(this));
    return html += '</select>';
  };
  ajForm.get_radio = function(field, name, secondaryName) {
    var html;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '';
    _.each(field.options, function(opt) {
      opt = ajForm.formatOptions(opt);
      return html += '<label class="radio-inline m-l-20"> <input ' + ajForm.validations(field.validation) + ' type="radio" name="' + name + '" value="' + opt.value + '"> <span class="lbl padding-8">' + opt.label + '</span> </label>';
    });
    return html;
  };
  ajForm.get_checkbox = function(field, name, secondaryName) {
    var html;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '';
    _.each(field.options, function(opt) {
      opt = ajForm.formatOptions(opt);
      return html += '<label class="radio-inline m-l-20"> <input ' + ajForm.validations(field.validation) + ' type="checkbox" name="' + name + '" value="' + opt.value + '"> <span class="lbl padding-8">' + opt.label + '</span> </label>';
    });
    return html;
  };
  ajForm.get_autosuggest = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<div data-id="' + name + '" class="magicsuggest"></div>';
  };
  ajForm.get_textarea = function(field, name, secondaryName) {
    var autogrowClass;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    autogrowClass = field.autogrow ? ' autogrow ' : '';
    return '<textarea ' + ajForm.validations(field.validation) + ' name="' + name + '" class="' + autogrowClass + ' form-control" placeholder="Enter text ..."></textarea>';
  };
  ajForm.get_richtext = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<textarea ' + ajForm.validations(field.validation) + ' name="' + name + '" class="richtext form-control" placeholder="Enter text ..."></textarea>';
  };
  ajForm.get_html_section = function(section, sectionName) {
    if (!section.label) {
      section.label = s.titleize(s.humanize(sectionName));
    }
    return '<h5 class="thin">' + section.label + '</h5> <div class="row"> <div class="col-md-12">' + section.value + '</div> </div>';
  };
  ajForm.validations = function(validation) {
    var validation_str;
    validation_str = '';
    _.each(validation, function(value, key) {
      return validation_str += " data-parsley-" + key + "='" + value + "'";
    });
    return validation_str;
  };
  ajForm.formatOptions = function(opt) {
    var label, value, _ref;
    if ((_ref = typeof opt) === 'string' || _ref === 'number') {
      label = s.titleize(s.humanize(opt));
      value = s.underscored(opt);
      opt = {
        label: label,
        value: value
      };
    }
    return opt;
  };
  ajForm.addDatePicker = function(element) {
    return element.find('input[type="date"]').pickadate({
      'container': 'body',
      'selectYears': true,
      'selectMonths': true,
      'formatSubmit': 'yyyy-mm-dd'
    });
  };
  ajForm.addAutoSuggest = function(element) {
    var divs;
    divs = element.find('.magicsuggest');
    _.each(divs, function(el) {
      var fieldName, item, items;
      fieldName = $(el).attr('data-id');
      item = ajForm.options.fields[fieldName];
      if (item.optionsUrl) {
        items = item.optionsUrl;
      } else {
        items = _.map(item.options, function(opt) {
          var data;
          opt = ajForm.formatOptions(opt);
          return data = {
            id: opt.value,
            name: opt.label
          };
        });
      }
      return $(el).magicSuggest({
        maxSelection: item.maxSelection ? item.maxSelection : false,
        data: items
      });
    });
    return divs;
  };
  ajForm.setAutogrowTextHeight = function(el) {
    var elements;
    elements = el.find('.autogrow');
    return _.each(elements, function(ele) {
      var scrollHeight;
      scrollHeight = $(ele).prop('scrollHeight') + 2;
      return $(ele).css({
        'height': scrollHeight + "px"
      });
    });
  };
  ajForm.autoGrowText = function(e) {
    var ele;
    ele = $(e.target);
    if ($(ele).prop('clientHeight') < $(ele).prop('scrollHeight')) {
      $(ele).css({
        'height': $(ele).prop('scrollHeight') + "px"
      });
    }
    if ($(ele).prop('clientHeight') < $(ele).prop('scrollHeight')) {
      return $(ele).css({
        'height': ($(ele).prop('scrollHeight') * 2 - $(ele).prop('clientHeight')) + "px"
      });
    }
  };
  ajForm.handleFormSubmit = function(e) {
    var data, form, validator;
    e.preventDefault();
    form = $(e.target).closest('form');
    validator = form.parsley({
      errorsContainer: function(ParsleyField) {
        return $(ParsleyField.$element).closest('.form-group');
      }
    });
    validator.validate();
    if (validator.isValid()) {
      data = Backbone.Syphon.serialize(this);
      return $(form).trigger("ajFormSubmitted", data);
    }
  };
  ajForm.bindConditions = function() {
    var conditions, triggers;
    conditions = _.chain(ajForm.options.fields).pluck('conditionals').compact().pluck('conditions').value();
    triggers = _.map(conditions, function(c) {
      return _.keys(c);
    });
    triggers = _.unique(_.flatten(triggers));
    return _.each(triggers, function(t) {
      var element;
      element = ajForm.findFieldElement(t);
      return $(element).bind('change', ajForm.triggerConditional);
    });
  };
  ajForm.triggerConditional = function(evt) {
    var conditionalFields, triggerName, triggerValue;
    triggerValue = $(evt.target).val();
    triggerName = $(evt.target).attr('name');
    conditionalFields = _.filter(ajForm.options.fields, function(field, index) {
      if (field.conditionals && _.has(field.conditionals.conditions, triggerName)) {
        field.name = index;
        return field;
      }
    });
    return _.each(conditionalFields, function(field) {
      var conditions, matchCount, requiredMatches, success;
      conditions = field.conditionals.conditions;
      requiredMatches = field.conditionals.type === 'any' ? 1 : _.size(conditions);
      matchCount = 0;
      success = false;
      _.each(conditions, function(c, index) {
        var ele;
        ele = ajForm.findFieldElement(index);
        switch (c.operator) {
          case '=':
            if (ele.val() === c.value) {
              matchCount++;
            }
            break;
          case '>':
            if (parseInt(ele.val()) > parseInt(c.value)) {
              matchCount++;
            }
            break;
          case '<':
            if (parseInt(ele.val()) < parseInt(c.value)) {
              matchCount++;
            }
            break;
          case 'like':
            if (s.contains(ele.val(), c.value)) {
              matchCount++;
            }
        }
        if (matchCount === requiredMatches) {
          return success = true;
        }
      });
      if (success) {
        if (field.conditionals.display === 'show') {
          return $(ajForm.formElement).find('.ajForm-' + field.name).show();
        } else {
          return $(ajForm.formElement).find('.ajForm-' + field.name).hide();
        }
      } else {
        if (field.conditionals.display === 'show') {
          return $(ajForm.formElement).find('.ajForm-' + field.name).hide();
        } else {
          return $(ajForm.formElement).find('.ajForm-' + field.name).show();
        }
      }
    });
  };
  return ajForm.findFieldElement = function(name) {
    var element;
    element = $(ajForm.formElement).find("input[name='" + name + "']");
    if (element.length === 0) {
      element = $(ajForm.formElement).find("select[name='" + name + "']");
    }
    return element;
  };
});