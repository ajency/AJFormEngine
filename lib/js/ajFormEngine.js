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
    ajForm.triggerFieldPlugins(element);
    $(formElement).bind('submit', ajForm.handleFormSubmit);
    $(formElement.find('.autogrow')).bind('keyup', ajForm.autoGrowText);
    $(formElement.find('a.add-section')).bind('click', ajForm.addSection);
    $(ajForm.formElement).trigger("aj:form:initialized", ajForm);
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
          return form += ajForm.get_section(field, name, columns, secondaryName);
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
          form += '<div class="form-group fly-group">';
          if (!_.contains(['hidden', 'button'], field.type)) {
            form += '<label class="fly-label classic">' + field.label + '</label>';
          }
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
  ajForm.get_section = function(section, sectionName, columns, secondaryName) {
    var hideElement, html, sectionClass, title;
    if (secondaryName == null) {
      secondaryName = false;
    }
    if ((section.label != null) && section.label === false) {
      title = sectionClass = '';
    } else {
      if (!section.label) {
        section.label = s.titleize(s.humanize(sectionName));
      }
      title = '<h5 class="thin">' + section.label + '</h5>';
      sectionClass = ' well';
    }
    if (section.columns) {
      columns = section.columns;
    }
    secondaryName = secondaryName ? "" + secondaryName + "[" + sectionName + "]" : sectionName;
    if (section.type === 'repeatable_section') {
      secondaryName += "[" + (ajForm.makeid()) + "]";
    }
    hideElement = section.conditionals ? ' style="display:none" ' : '';
    html = '<section class="ajForm-' + sectionName + ' ' + sectionName + '" ' + hideElement + '> <div class="' + sectionClass + '">' + title;
    html += '<div class="row"><div class="col-md-12">';
    html += ajForm.generateFields(section.fields, columns, secondaryName);
    html += '</div></div></div></section>';
    if (section.type === 'repeatable_section') {
      html += '<div class="form-group clearfix"> <a data-section="' + sectionName + '" class="add-section btn btn-default btn-sm pull-right m-t-10"><i class="fa fa-plus"></i> Add</a> </div>';
    }
    return html;
  };
  ajForm.addSection = function(evt) {
    var addedSection, button, newName, section, sectionName;
    button = $(evt.currentTarget);
    sectionName = button.attr('data-section');
    section = $(ajForm.formElement).find('.' + sectionName).first().clone();
    section.find('textarea, select').val('');
    _.each(section.find('input'), function(el) {
      if ($(el).attr('type') !== 'button') {
        return $(el).val('');
      }
    });
    $(ajForm.formElement).find('.' + sectionName).last().after(section);
    newName = "" + (ajForm.makeid());
    section.find('input, textarea, select').each((function(_this) {
      return function(index, ele) {
        var array, arraySize, completeName, name, nameToReplace;
        name = $(ele).attr('name');
        if (name) {
          array = name.split('[');
        }
        arraySize = name ? _.size(array) : 0;
        nameToReplace = '';
        if (arraySize > 1) {
          nameToReplace = array[arraySize - 2].split(']').shift();
        }
        if (nameToReplace) {
          completeName = name.replace(nameToReplace, newName);
          return $(ele).attr('name', completeName);
        }
      };
    })(this));
    addedSection = $(ajForm.formElement).find('.' + sectionName).last();
    addedSection.append('<div class="form-group clearfix"> <a class="remove-section btn btn-link pull-right">Delete</a> </div>');
    $(ajForm.formElement).find('a.remove-section').bind('click', ajForm.removeSection);
    ajForm.cleanupAddedSection(addedSection);
    ajForm.triggerFieldPlugins(addedSection);
    return $(ajForm.formElement).trigger("aj:form:section:added", addedSection);
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
    var value;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    value = field.value ? field.value : '';
    return "<input value='" + value + "' type='text' " + (ajForm.validations(field.validation)) + " class='form-control input-sm' name=" + name + ">";
  };
  ajForm.get_date = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<input type="date" ' + ajForm.validations(field.validation) + ' ' + ajForm.attributes(field.attributes) + ' class="form-control input-sm" name="' + name + '">';
  };
  ajForm.get_dropdown = function(field, name, secondaryName) {
    var html, selectLabel;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '<select ' + ajForm.validations(field.validation) + ' ' + ajForm.attributes(field.attributes) + ' name="' + name + '" class="form-control">';
    selectLabel = _.has(field, 'selectLabel') ? field.selectLabel : 'Select';
    html += '<option value="">' + selectLabel + '</option>';
    _.each(field.options, (function(_this) {
      return function(option) {
        var opt;
        opt = ajForm.formatOptions(option);
        return html += '<option value="' + opt.value + '" ' + ajForm.preSelected(field, option) + '>' + opt.label + '</option>';
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
    _.each(field.options, function(option) {
      var opt;
      opt = ajForm.formatOptions(option);
      return html += '<label class="radio-inline m-l-20"> <input ' + ajForm.validations(field.validation) + ' type="radio" name="' + name + '" value="' + opt.value + '" ' + ajForm.preSelected(field, option) + ' ' + ajForm.attributes(field.attributes) + '> <span class="lbl padding-8">' + opt.label + '</span> </label>';
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
      return html += '<label class="radio-inline m-l-20"> <input ' + ajForm.validations(field.validation) + ' type="checkbox" name="' + name + '" value="' + opt.value + '" ' + ajForm.preSelected(field, option) + ' ' + ajForm.attributes(field.attributes) + '> <span class="lbl padding-8">' + opt.label + '</span> </label>';
    });
    return html;
  };
  ajForm.get_autosuggest = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<div data-id="' + name + '" class="magicsuggest" ' + ajForm.attributes(field.attributes) + '></div>';
  };
  ajForm.get_textarea = function(field, name, secondaryName) {
    var autogrowClass;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    autogrowClass = field.autogrow ? ' autogrow ' : '';
    return '<textarea ' + ajForm.validations(field.validation) + ' ' + ajForm.attributes(field.attributes) + ' name="' + name + '" class="' + autogrowClass + ' form-control" placeholder="Enter text ..."></textarea>';
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
  ajForm.get_multiselect_dropdown = function(field, name, secondaryName) {
    var html;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    html = '<select ' + ajForm.validations(field.validation) + ' ' + ajForm.attributes(field.attributes) + ' name="' + name + '" class="form-control" multiple>';
    _.each(field.options, (function(_this) {
      return function(option) {
        var opt;
        opt = ajForm.formatOptions(option);
        return html += '<option value="' + opt.value + '">' + opt.label + '</option>';
      };
    })(this));
    return html += '</select>';
  };
  ajForm.get_hidden = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<input type="hidden" class="form-control input-sm" name="' + name + '">';
  };
  ajForm.get_label = function(field, name, secondaryName) {
    var content;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    if (_.has(field, 'html')) {
      content = field.html;
    } else {
      content = 'Missing label option (html)';
    }
    return '<label name="' + name + '">' + content + '</label>';
  };
  ajForm.get_button = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    if (!field.label) {
      field.label = s.titleize(s.humanize(name));
    }
    return '<input type="button" value="' + field.label + '" name="' + name + '" ' + ajForm.attributes(field.attributes) + ' class="btn btn-primary" />';
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
  ajForm.preSelected = function(field, option) {
    var selected;
    selected = '';
    if (_.has(field, 'default')) {
      if (field["default"] === option) {
        selected = field.type === 'dropdown' ? 'selected' : 'checked';
      }
    }
    return selected;
  };
  ajForm.attributes = function(attrs) {
    var attributes;
    attributes = '';
    if (attrs && _.isObject(attrs)) {
      _.each(attrs, function(attr) {
        return attributes += "" + attr + " ";
      });
    }
    return attributes;
  };
  ajForm.addDatePicker = function(element) {
    var dateElements;
    dateElements = element.find('input[type="date"]');
    return _.each(dateElements, function(el) {
      var dateObj, max, min;
      dateObj = ajForm.getFieldOption(el.name);
      min = max = void 0;
      if (_.has(dateObj, 'min')) {
        min = dateObj.min === 'today' ? new Date() : new Date(dateObj.min);
      }
      if (_.has(dateObj, 'max')) {
        max = dateObj.max === 'today' ? new Date() : new Date(dateObj.max);
      }
      return $(el).pickadate({
        'container': 'body',
        'selectYears': true,
        'selectMonths': true,
        'formatSubmit': 'yyyy-mm-dd',
        'min': min,
        'max': max
      });
    });
  };
  ajForm.addAutoSuggest = function(element) {
    var divs;
    divs = element.find('.magicsuggest');
    _.each(divs, function(el) {
      var fieldName, item, items;
      fieldName = $(el).attr('data-id');
      item = ajForm.getFieldOption(fieldName);
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
        ajaxConfig: {
          method: 'GET'
        },
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
  ajForm.addMultiselectDropdown = function(element) {
    var multiselectElements;
    multiselectElements = element.find('[multiple]');
    return _.each(multiselectElements, function(el) {
      return $(el).multiselect({
        includeSelectAllOption: true
      });
    });
  };
  ajForm.handleFormSubmit = function(e) {
    var ajaxSubmit, data, form, validator;
    e.preventDefault();
    form = $(e.target).closest('form');
    validator = form.parsley({
      excluded: ':hidden',
      errorsContainer: function(ParsleyField) {
        return $(ParsleyField.$element).closest('.form-group');
      }
    });
    validator.destroy();
    validator.validate();
    if (validator.isValid()) {
      data = Backbone.Syphon.serialize(this);
      $(form).trigger("aj:form:submit", data);
      if (_.has(ajForm.options, 'submitUrl')) {
        ajaxSubmit = $.ajax({
          url: ajForm.options.submitUrl,
          type: 'POST',
          data: data
        });
        return $(form).trigger("aj:form:ajax:submit:complete", ajaxSubmit);
      }
    }
  };
  ajForm.bindConditions = function() {
    var conditions, triggers;
    conditions = ajForm.getConditions(ajForm.options.fields);
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
  ajForm.getConditions = function(fields, conditions) {
    if (conditions == null) {
      conditions = [];
    }
    _.each(fields, function(field) {
      if (field.conditionals) {
        if (field.conditionals.conditions) {
          conditions.push(field.conditionals.conditions);
        } else {
          conditions.push(field.conditionals);
        }
      }
      if (field.fields) {
        return ajForm.getConditions(field.fields, conditions);
      }
    });
    return conditions;
  };
  ajForm.getAffectableFields = function(fields, triggerName, conditionals) {
    if (conditionals == null) {
      conditionals = [];
    }
    _.each(fields, function(field, index) {
      if (field.conditionals) {
        if (_.has(field.conditionals, triggerName) || _.has(field.conditionals.conditions, triggerName)) {
          field.name = index;
          conditionals.push(field);
        }
      }
      if (field.fields) {
        return ajForm.getAffectableFields(field.fields, triggerName, conditionals);
      }
    });
    return conditionals;
  };
  ajForm.triggerConditional = function(evt) {
    var affectableFields, triggerName, triggerValue;
    triggerValue = $(evt.target).val();
    triggerName = $(evt.target).attr('name');
    affectableFields = ajForm.getAffectableFields(ajForm.options.fields, triggerName);
    return _.each(affectableFields, function(field) {
      var fieldConditionType, fieldConditions, fieldDisplay, fieldDivEl, matchCount, requiredMatches, success;
      if (field.conditionals.conditions) {
        fieldConditions = field.conditionals.conditions;
        fieldConditionType = field.conditionals.type;
        fieldDisplay = field.conditionals.display;
      } else {
        fieldConditions = {};
        _.each(field.conditionals, function(c, index) {
          return fieldConditions[index] = {
            operator: '=',
            value: c
          };
        });
        fieldConditionType = 'any';
        fieldDisplay = 'show';
      }
      requiredMatches = fieldConditionType === 'any' ? 1 : _.size(fieldConditions);
      matchCount = 0;
      success = false;
      _.each(fieldConditions, function(c, index) {
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
      fieldDivEl = $(ajForm.formElement).find('.ajForm-' + field.name);
      if (success) {
        if (fieldDisplay === 'show') {
          return fieldDivEl.show();
        } else {
          return fieldDivEl.hide();
        }
      } else {
        if (fieldDisplay === 'show') {
          return fieldDivEl.hide();
        } else {
          return fieldDivEl.show();
        }
      }
    });
  };
  ajForm.findFieldElement = function(name) {
    var element;
    element = $(ajForm.formElement).find("input[name='" + name + "']");
    if (element.length === 0) {
      element = $(ajForm.formElement).find("select[name='" + name + "']");
    }
    return element;
  };
  ajForm.getFieldOption = function(name) {
    var fieldPathArr, item;
    if (s.contains(name, '[')) {
      fieldPathArr = name.split('[');
      item = ajForm.options;
      _.each(fieldPathArr, function(pathItem, index) {
        pathItem = s.replaceAll(pathItem, ']', '');
        if (item.fields[pathItem] != null) {
          return item = item.fields[pathItem];
        }
      });
    } else {
      item = ajForm.options.fields[name];
    }
    return item;
  };
  ajForm.bindButtonEvents = function(element) {
    var buttonElements;
    buttonElements = element.find('input[type="button"]');
    return _.each(buttonElements, function(el) {
      var buttonObj;
      buttonObj = ajForm.getFieldOption(el.name);
      if (_.has(buttonObj, 'triggerClick')) {
        return $(el).bind('click', function(e) {
          return $(ajForm.formElement).trigger("" + buttonObj.triggerClick, e);
        });
      }
    });
  };
  ajForm.triggerFieldPlugins = function(element) {
    ajForm.addDatePicker(element);
    ajForm.addAutoSuggest(element);
    ajForm.setAutogrowTextHeight(element);
    ajForm.addMultiselectDropdown(element);
    $(element).find('.richtext').wysihtml5();
    return ajForm.bindButtonEvents(element);
  };
  return ajForm.cleanupAddedSection = function(addedSection) {
    return $(addedSection).find('.multiselect').closest('.btn-group').remove();
  };
});
