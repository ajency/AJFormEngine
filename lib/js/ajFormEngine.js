var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

jQuery(document).ready(function($) {
  window.scrollToDivScript = function(){
		$(window).scroll(function(){
			var window_top = $(window).scrollTop() + 12; 
		   // the "12" should equal the margin-top value for nav.stickydiv
		   div = $('.ajFormNav #checkdiv')
		   if(div.length>0){
				var div_top = div.offset().top;
				if (window_top >= div_top) {
						$('.ajFormNav .bs-docs-sidebar').addClass('stickydiv');
					} else {
						$('.ajFormNav .bs-docs-sidebar').removeClass('stickydiv');
					}
		   }
		});
		
		$(document).on("scroll", onScroll);

		$('.ajFormNav .nav li').on('click', function (e) {
		  e.preventDefault();
			$(document).off("scroll");
			$('.ajFormNav .sub-menu ul li').removeClass('active');
			$(this).addClass('active');
			 var target = $(this).find('a').attr('section-id'), menu = target;
			$target = $(".ajForm section[id='"+target+"']");
		   $('html, body').stop().animate({
				'scrollTop': $target.offset().top+2
			}, 600, 'swing', function () {
				$(document).on("scroll", onScroll);
			});
		});
		
		var onScroll = function(event) {
			var scrollPos = $(document).scrollTop();
			$('.ajFormNav .nav li').each(function () {
				var currLink = $(this);
				target = currLink.find('a').attr("section-id")
				var refElement = $("section[id='"+target+"']");
				if (refElement.position().top <= scrollPos && refElement.position().top + refElement.height() > scrollPos) {
					$('.nav li').removeClass("active");
					currLink.addClass("active");
				}
				else{
					currLink.removeClass("active");
				}
			});
			}
		};
  var ajForm;
  ajForm = {};
  if (window.ionic) {
    window.ajForm = ajForm;
  }
  $.AJFormEngine = function(element, opts, data) {
    var form, formElement;
    if (data == null) {
      data = [];
    }
    ajForm.autoSuggest = [];
    ajForm.formData = data;
    ajForm.options = opts;
    form = '<form class="ajForm">';
    form += '<div class="list list-inset">';
    form += ajForm.generateFields(opts.fields, opts.columns);
    if (ajForm.options.mode !== 'view') {
      if (opts.cancelButton && opts.cancelButton.display) {
        form += ajForm.get_submit__plus_cancel_button();
      } else {
        form += ajForm.get_submit_button();
      }
    }
    form += '</div>';
    form += '</form>';
    ajForm.appendForm(form, element);
    if (!_.isEmpty(data)) {
      Backbone.Syphon.deserialize(element.find('form')[0], data);
    }
    ajForm.formElement = formElement = element.find('form');
    if (!_.isEmpty(data)) {
      ajForm.fillFormSections(data);
    }
    ajForm.bindConditions();
    if (ajForm.options.mode === 'view') {
      ajForm.showConditions();
      ajForm.hideEmptyFieldsInViewMode();
    }
    ajForm.triggerFieldPlugins(element);
    $(formElement).bind('submit', ajForm.handleFormSubmit);
    $(formElement.find('.autogrow')).bind('keyup', ajForm.autoGrowText);
    $(formElement.find('a.add-section')).bind('click', ajForm.addSection);
    $(ajForm.formElement).trigger("aj:form:initialized", ajForm);
    if (!_.isEmpty(data)) {
      $(ajForm.formElement.find('input,select')).trigger('change');
    }
    if (ajForm.options.nav) {
      ajForm.addSideNav(element);
    }
    if (!window.ionic) {
      $('body').scrollspy({
        target: '.bs-docs-sidebar'
      });
    }
    window.scrollToDivScript();
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
      var columnClass, fieldFunction, hideElement, mode, _ref;
      if (!columns) {
        columns = 1;
      }
      columnClass = 12 / columns;
      if (field.type === 'hidden') {
        return form += ajForm.get_hidden(field, name, secondaryName);
      } else if ((_ref = field.type) === 'section' || _ref === 'repeatable_section' || _ref === 'html_section') {
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
        mode = ajForm.options.mode;
        if (mode === 'view') {
          form += ajForm.generateFieldsInViewMode(field, name, secondaryName);
        } else {
          fieldFunction = ajForm['get_' + field.type];
          if (typeof fieldFunction === 'function') {
            if (field.label !== false && !field.label) {
              field.label = s.humanize(name);
            }
            if (field.validation && field.validation.required) {
              field.label += '<i class="fa fa-asterisk"></i>';
            }
            form += '<div class="form-group fly-group">';
            if (field.label && !_.contains(['hidden', 'button'], field.type)) {
              form += '<label class="fly-label classic">' + field.label + '</label>';
            }
            form += fieldFunction(field, name, secondaryName);
            form += '</div>';
          }
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
      sectionClass = ' section-div';
    }
    if (section.columns) {
      columns = section.columns;
    }
    secondaryName = secondaryName ? "" + secondaryName + "[" + sectionName + "]" : sectionName;
    if (secondaryName) {
      sectionName = secondaryName;
    }
    if (section.type === 'repeatable_section') {
      secondaryName += "[" + (ajForm.makeid()) + "]";
    }
    hideElement = section.conditionals ? ' style="display:none" ' : '';
    html = '<section id="' + secondaryName + '" data-type="' + section.type + '" data-name="' + sectionName + '" class="ajForm-' + sectionName + '" ' + hideElement + '> <div class="' + sectionClass + '">' + title;
    html += '<div class="row"><div class="col-md-12">';
    html += ajForm.generateFields(section.fields, columns, secondaryName);
    html += '</div></div></div></section>';
    if (section.type === 'repeatable_section' && ajForm.options.mode !== 'view') {
      html += '<div class="form-group clearfix"> <a data-section="' + sectionName + '" class="add-section btn btn-default btn-sm pull-right m-t-10"><i class="fa fa-plus"></i> Add</a> </div>';
    }
    return html;
  };
  ajForm.addSection = function(evt) {
    var addedSection, button, newName, sectionEl, sectionName;
    button = $(evt.currentTarget);
    sectionName = button.attr('data-section');
    sectionEl = $(ajForm.formElement).find('section[data-name="' + sectionName + '"]');
    addedSection = sectionEl.first().clone();
    addedSection.find('textarea, select').val('');
    _.each(addedSection.find('input'), function(el) {
      if ($(el).attr('type') !== 'button') {
        return $(el).val('');
      }
    });
    sectionEl.last().after(addedSection);
    newName = "" + (ajForm.makeid());
    addedSection.find('input, textarea, select').each((function(_this) {
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
    $(addedSection).removeClass('hidden');
    ajForm.addDeleteSectionLink(addedSection);
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
    var sectionName;
    sectionName = $(evt.target).closest('section').attr('data-name');
    if ($("section[data-name='" + sectionName + "']:visible").length > 1) {
      return $(evt.target).closest('section').fadeOut('fast', function() {
        return $(ajForm.formElement).trigger("aj:form:section:removed");
      });
    } else {
      return alert("Cannot delete");
    }
  };
  ajForm.addDeleteSectionLink = function(sectionEl) {
    if (ajForm.options.mode !== 'view') {
      sectionEl.append('<div class="form-group clearfix"> <a class="remove-section btn btn-link pull-right">Delete</a> </div>');
      return $(sectionEl).find('a.remove-section').bind('click', ajForm.removeSection);
    }
  };
  ajForm.get_submit_button = function() {
    return '<div class="row"> <div class="col-md-12"> <input type="submit" value="Save" class="btn btn-primary" /> </div> </div>';
  };
  ajForm.get_submit__plus_cancel_button = function() {
    var href, opts;
    opts = ajForm.options;
    href = opts.cancelButton.link ? "href='" + opts.cancelButton.link + "'" : '';
    return '<div class="row"> <div class="col-md-1"> <input type="submit" value="Save" class="btn btn-primary" /> </div> <div class="col-md-1 cancel"> <a ' + href + ' class="btn btn-primary">Cancel</a> </div> </div>';
  };
  ajForm.get_textbox = function(field, name, secondaryName) {
    var value;
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    value = field.value ? field.value : '';
    return "<input value='" + value + "' type='text' " + (ajForm.validations(field.validation)) + " " + (ajForm.attributes(field.attributes)) + " class='form-control input-sm' name=" + name + ">";
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
        if (opt) {
          return html += '<option value="' + opt.value + '" ' + ajForm.preSelected(field, option) + '>' + opt.label + '</option>';
        }
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
    return '<div data-id="' + name + '" class="magicsuggest" ' + ajForm.attributes(field.attributes) + '></div> <input type="hidden" name="' + name + '" />';
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
        return html += '<option value="' + opt.value + '" ' + ajForm.preSelected(field, option) + '>' + opt.label + '</option>';
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
  ajForm.get_geoSearch = function(field, name, secondaryName) {
    if (secondaryName) {
      name = "" + secondaryName + "[" + name + "]";
    }
    return '<div class="geoSearch" id="geoSearch"></div>';
  };
  ajForm.get_address = function(field, name, secondaryName) {
    field.label = 'Address';
    field.type = 'repeatable_section';
    field.fields = {
      type: {
        type: 'dropdown',
        options: ['meeting', 'residential', 'office']
      },
      address: {
        type: 'textarea'
      },
      country: {
        type: 'textbox',
        vallue: 'United Kingdom'
      },
      region: {
        type: 'textbox'
      },
      city: {
        type: 'textbox'
      },
      postcode: {
        label: 'Postal Code',
        type: 'textbox'
      },
      notes: {
        type: 'textarea'
      },
      lat: {
        type: 'hidden'
      },
      lng: {
        type: 'hidden'
      },
      geoSearch: {
        label: false,
        type: 'section',
        columns: 1,
        fields: {
          geoSearch: {
            type: 'geoSearch',
            label: false
          }
        }
      }
    };
    return ajForm.generateFields({
      address: field
    }, 2);
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
      value = opt;
      opt = {
        label: label,
        value: value
      };
    }
    return opt;
  };
  ajForm.preSelected = function(field, option) {
    var optionDefaults, selected;
    selected = '';
    optionDefaults = {
      multiple: function() {
        if ((_.isObject(option) && _.contains(field["default"], option.value)) || _.contains(field["default"], option)) {
          return true;
        } else {
          return false;
        }
      },
      single: function() {
        if ((_.isObject(option) && field["default"] === option.value) || (field["default"] === option)) {
          return true;
        } else {
          return false;
        }
      }
    };
    if (_.has(field, 'default')) {
      switch (field.type) {
        case 'dropdown':
          if (optionDefaults.single()) {
            selected = 'selected="selected"';
          }
          break;
        case 'multiselect_dropdown':
          if (optionDefaults.multiple()) {
            selected = 'selected="selected"';
          }
          break;
        case 'radio':
          if (optionDefaults.single()) {
            selected = 'checked="checked"';
          }
          break;
        case 'checkbox':
          if (optionDefaults.multiple()) {
            selected = 'checked="checked"';
          }
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
      var fieldName, fieldValue, item, items, magicSuggest, preselected;
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
      fieldValue = ajForm.getFormDataItem(fieldName);
      preselected = [];
      if (fieldValue && _.size(fieldValue) > 0) {
        if (fieldValue.id != null) {
          preselected = [fieldValue.id];
        }
      }
      preselected = _.compact(preselected);
      if (_.isEmpty(preselected) && !_.isEmpty(_.compact(fieldValue))) {
        preselected = _.pluck(fieldValue, 'id');
        if (_.isEmpty(_.compact(preselected))) {
          preselected = fieldValue;
        }
      }
      preselected = eval(preselected);
      magicSuggest = $(el).magicSuggest({
        maxSelection: item.maxSelection ? item.maxSelection : false,
        data: items,
        value: !_.isEmpty(_.compact(preselected)) ? preselected : void 0,
        ajaxConfig: {
          method: 'GET',
          headers: window.WP_API_NONCE ? {
            'X-WP-Nonce': WP_API_NONCE
          } : void 0
        }
      });
      $(magicSuggest).on('selectionchange', function(e, m) {
        return $(ajForm.formElement).find("input[name='" + fieldName + "']").val(JSON.stringify(this.getSelection()));
      });
      return ajForm.autoSuggest.push({
        field: fieldName,
        magicSuggest: magicSuggest
      });
    });
    return divs;
  };
  ajForm.getFormDataItem = function(fieldName) {
    var evalStr, i, item, nameArr, str, _i, _len;
    nameArr = fieldName.split('[');
    str = '';
    for (_i = 0, _len = nameArr.length; _i < _len; _i++) {
      item = nameArr[_i];
      i = s.replaceAll(item, ']', '');
      str += "['" + i + "']";
      evalStr = 'ajForm.formData' + str;
      if (_.isUndefined(eval(evalStr))) {
        break;
      }
    }
    evalStr = 'ajForm.formData' + str;
    return item = eval(evalStr);
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
  ajForm.filterDateFieldsForSerialization = function() {
    var dateElements;
    dateElements = $('.picker__input');
    return _.each(dateElements, function(el) {
      var name;
      name = el.name;
      return $('input[name="' + name + '_submit"]').attr('name', name);
    });
  };
  ajForm.handleFormSubmit = function(e) {
    var data, excludeItems, form, hiddenItems, validator;
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
      hiddenItems = ajForm.formElement.find('[class^=ajForm-]:hidden input, [class^=ajForm-]:hidden select, [class^=ajForm-]:hidden textarea');
      excludeItems = _.map(hiddenItems, function(item) {
        return $(item).attr('name');
      });
      ajForm.filterDateFieldsForSerialization();
      data = Backbone.Syphon.serialize(this, {
        exclude: excludeItems
      });
      $(form).trigger("aj:form:submitted", data);
      if (_.has(ajForm.options, 'submitUrl')) {
        return $.ajax({
          url: ajForm.options.submitUrl,
          type: 'POST',
          data: data,
          beforeSend: function(xhr) {
            return $(form).trigger("aj:form:ajax:before:submit", data);
          },
          complete: function(xhr) {
            return $(form).trigger("aj:form:ajax:submit:complete", xhr);
          }
        });
      }
    }
  };
  ajForm.bindConditions = function() {
    var conditions, triggers;
    conditions = ajForm.getConditions(ajForm.options.fields);
    triggers = _.map(conditions, function(c) {
      return _.keys(c);
    });
    ajForm.triggers = _.unique(_.flatten(triggers));
    return _.each(ajForm.triggers, function(t) {
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
  ajForm.triggerConditional = function(evt, triggerItem) {
    var affectableFields, triggerName, triggerValue;
    if (evt) {
      triggerValue = $(evt.target).val();
      triggerName = $(evt.target).attr('name');
    } else {
      triggerValue = triggerItem.value;
      triggerName = triggerItem.name;
    }
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
        var ele, eleVal, mode;
        ele = ajForm.findFieldElement(index);
        eleVal = ele.val();
        mode = ajForm.options.mode;
        if (mode === 'view') {
          eleVal = ajForm.getFormDataItem(index);
        }
        if (mode !== 'view') {
          if (ele.attr('type') === 'radio') {
            eleVal = $("input[name=" + ele.attr('name') + "]:checked").val();
          }
        }
        switch (c.operator) {
          case '=':
            if (eleVal === c.value) {
              matchCount++;
            }
            break;
          case '>':
            if (parseInt(eleVal) > parseInt(c.value)) {
              matchCount++;
            }
            break;
          case '<':
            if (parseInt(eleVal) < parseInt(c.value)) {
              matchCount++;
            }
            break;
          case 'like':
            if (s.contains(eleVal, c.value)) {
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
          fieldDivEl.show();
        } else {
          fieldDivEl.hide();
        }
      } else {
        if (fieldDisplay === 'show') {
          fieldDivEl.hide();
        } else {
          fieldDivEl.show();
        }
      }
      return ajForm.formElement.trigger("aj:conditional:triggered");
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
    ajForm.addGeoSearch(element);
    return ajForm.bindButtonEvents(element);
  };
  ajForm.cleanupAddedSection = function(addedSection) {
    return $(addedSection).find('.multiselect').closest('.btn-group').remove();
  };
  ajForm.fillFormSections = (function(_this) {
    return function(data) {
      var repeatableSections;
      repeatableSections = $(ajForm.formElement).find('section[data-type="repeatable_section"]');
      return _.each(repeatableSections, function(section) {
        var dataName, dataRecords;
        dataName = $(section).attr('data-name');
        dataRecords = ajForm.getFormDataItem(dataName);
        if (_.isEmpty(dataRecords)) {
          dataRecords = [{}];
        }
        _.each(dataRecords, (function(_this) {
          return function(record, key) {
            var sectionEle;
            sectionEle = $(section).first().clone();
            sectionEle.find('input, textarea, select, b.ajFormBold').val('');
            sectionEle.find('input, textarea, select, b.ajFormBold').each(function(index, ele) {
              var array, completeName, field, fieldText, fieldValue, field_name, name, nameToReplace, newSectionID, property;
              field_name = $(ele).attr('name');
              name = s.ltrim(field_name, dataName);
              array = name.split('[');
              if (array[0]) {
                nameToReplace = array[0].split(']').shift();
              } else {
                nameToReplace = array[1].split(']').shift();
              }
              if (nameToReplace) {
                newSectionID = sectionEle.attr('id').replace(nameToReplace, key);
                sectionEle.attr('id', newSectionID);
                completeName = field_name.replace(nameToReplace, key);
                $(ele).attr('name', completeName);
                property = name.split('[').pop().slice(0, -1);
                $(ele).val(record[property]);
              } else {
                $(ele).val(key);
              }
              if (ajForm.options.mode === 'view') {
                field = JSON.parse($(ele).attr('field'));
                name = $(ele).attr('el-name');
                fieldValue = ajForm.getFieldValueForViewMode(field, name, newSectionID);
                fieldText = ajForm.getFieldTextForViewMode(field, fieldValue);
                return $(ele).text(fieldText);
              }
            });
            ajForm.addDeleteSectionLink(sectionEle);
            return $(section).last().after(sectionEle);
          };
        })(this));
        if (dataRecords) {
          return $(section).first().addClass('hidden');
        }
      });
    };
  })(this);
  ajForm.appendForm = function(form, element) {
    var html;
    if (ajForm.options.nav) {
      html = '<div class="row"> <div class="ajFormNav col-sm-3"> <div id="checkdiv"></div> <nav class="bs-docs-sidebar sub-menu"> <ul class="sub-menu-links nav"></ul> </nav> </div> <div class="col-sm-9"> <div id="formSteps">' + form + '</div> </div> </div>';
      return element.append(html);
    } else {
      return element.append(form);
    }
  };
  ajForm.addSideNav = function(element) {
    var fields, items;
    items = [];
    fields = ajForm.options.fields;
    _.each(fields, function(field, fieldName) {
      return ajForm.getNavItem(field, fieldName, items);
    });
    return element.find('.sub-menu-links').append(items.join(''));
  };
  ajForm.getNavItem = function(field, fieldName, items) {
    var label, _ref;
    if (items == null) {
      items = [];
    }
    if (((_ref = field.type) === 'section' || _ref === 'repeatable_section') && !field.hideNav) {
      if ($(ajForm.formElement).find("section[data-name='" + fieldName + "']").is(':visible')) {
        label = field.label ? field.label : s.titleize(s.humanize(fieldName));
        items.push("<li><a section-id='" + fieldName + "'>" + label + "</a>");
        if (_.findWhere(field.fields, {
          'type': 'section'
        }) && !field.hideNav) {
          items.push("<ul class='nav nav-stacked'>");
        }
        _.each(field.fields, function(field, fName) {
          return ajForm.getNavItem(field, "" + fieldName + "[" + fName + "]", items);
        });
        if (_.findWhere(field.fields, {
          'type': 'section'
        }) && !field.hideNav) {
          items.push("</ul>");
        }
        items.push("</li>");
      }
    }
    return items;
  };
  ajForm.addGeoSearch = function(element) {
    var geoSearchEls;
    geoSearchEls = element.find('.geoSearch');
    return _.each(geoSearchEls, function(el) {
      var addressEl, cityEl, countryEl, geocoder, latEl, latlng, lngEl, map, marker, options, postcodeEl, regionEl, section;
      section = $(el).closest('section[data-name="address"]');
      lngEl = section.find('input[name$="[lng]"]');
      latEl = section.find('input[name$="[lat]"]');
      addressEl = section.find('textarea[name$="[address]"]');
      countryEl = section.find('input[name$="[country]"]');
      regionEl = section.find('input[name$="[region]"]');
      cityEl = section.find('input[name$="[city]"]');
      postcodeEl = section.find('input[name$="[postcode]"]');
      if (lngEl.val() && latEl.val()) {
        latlng = new google.maps.LatLng(latEl.val(), lngEl.val());
      } else {
        latlng = new google.maps.LatLng(51.49506473014368, -0.087890625);
      }
      options = {
        zoom: 6,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      map = new google.maps.Map(el, options);
      geocoder = new google.maps.Geocoder();
      marker = new google.maps.Marker({
        map: map,
        draggable: true,
        position: latlng,
        title: "Si el domicilio que desea agendar no es este, por favor mueva este marcador a la posición correcta."
      });
      google.maps.event.addListener(marker, 'dragend', function() {
        return geocoder.geocode({
          'latLng': marker.getPosition()
        }, function(results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            if (results[0]) {
              latEl.val(marker.getPosition().lat());
              lngEl.val(marker.getPosition().lng());
              $(addressEl).val(results[0]['formatted_address']);
              return ajForm.updateAddressLocations(section, results[0]['address_components']);
            }
          }
        });
      });
      return $(el).closest('section[data-name="address"]').find('textarea[name$="[address]"], input[name$="[country]"], input[name$="[region]"], input[name$="[city]"]').bind('change', function(e) {
        var term;
        term = '';
        if (addressEl.val()) {
          term += ' ' + addressEl.val();
        } else {
          if (countryEl.val()) {
            term += ' ' + countryEl.val();
          }
          if (regionEl.val()) {
            term += ' ' + regionEl.val();
          }
          if (cityEl.val()) {
            term += ' ' + cityEl.val();
          }
        }
        return geocoder.geocode({
          'address': term
        }, function(results, status) {
          var latlong, location;
          if ((results != null) && results.length > 0) {
            latlong = results[0]['geometry']['location'];
            latEl.val(latlong['k']);
            lngEl.val(latlong['D']);
            location = new google.maps.LatLng(latlong['k'], latlong['D']);
            marker.setPosition(location);
            map.setCenter(location);
            return ajForm.updateAddressLocations(section, results[0]['address_components']);
          }
        });
      });
    });
  };
  ajForm.updateAddressLocations = function(section, addressComponents) {
    var cityEl, countryEl, postcodeEl, regionEl;
    countryEl = section.find('input[name$="[country]"]');
    regionEl = section.find('input[name$="[region]"]');
    cityEl = section.find('input[name$="[city]"]');
    postcodeEl = section.find('input[name$="[postcode]"]');
    countryEl.val('');
    regionEl.val('');
    postcodeEl.val('');
    cityEl.val('');
    return _.each(addressComponents, function(addr) {
      if (__indexOf.call(addr.types, 'country') >= 0) {
        countryEl.val(addr.long_name);
      }
      if (__indexOf.call(addr.types, 'administrative_area_level_1') >= 0) {
        regionEl.val(addr.long_name);
      }
      if (!regionEl.val() && __indexOf.call(addr.types, 'administrative_area_level_2') >= 0) {
        regionEl.val(addr.long_name);
      }
      if (__indexOf.call(addr.types, 'postal_town') >= 0) {
        cityEl.val(addr.long_name);
      }
      if (__indexOf.call(addr.types, 'postal_code') >= 0) {
        return postcodeEl.val(addr.long_name);
      }
    });
  };
  ajForm.showConditions = function() {
    return _.each(ajForm.triggers, function(trigger) {
      var item;
      item = {
        name: trigger,
        value: ajForm.getFormDataItem(trigger)
      };
      return ajForm.triggerConditional(null, item);
    });
  };
  ajForm.getFieldValueForViewMode = function(field, name, secondaryName) {
    var fieldValue;
    if (secondaryName) {
      fieldValue = ajForm.getFormDataItem(secondaryName);
      if (fieldValue) {
        fieldValue = fieldValue[name];
      }
    } else {
      fieldValue = ajForm.getFormDataItem(name);
    }
    return fieldValue;
  };
  ajForm.getFieldTextForViewMode = function(field, fieldValue) {
    var filteredOption, ids, labelValue, tempArr;
    labelValue = '';
    switch (field.type) {
      case 'dropdown':
        if (field.options[0].value) {
          filteredOption = _.filter(field.options, function(opt) {
            return opt.value === fieldValue;
          });
          labelValue = filteredOption[0].label;
        } else {
          labelValue = s.humanize(fieldValue);
        }
        break;
      case 'multiselect_dropdown':
        tempArr = [];
        _.each(fieldValue, function(val) {
          if (field.options[0].value) {
            filteredOption = _.filter(field.options, function(opt) {
              return opt.value === val;
            });
            return tempArr.push(filteredOption[0].label);
          } else {
            return tempArr.push(s.humanize(val));
          }
        });
        labelValue = tempArr.join(', ');
        break;
      case 'autosuggest':
        fieldValue = eval(fieldValue);
        if (!_.isUndefined(fieldValue) && !_.isEmpty(fieldValue)) {
          if (fieldValue[0].id) {
            ids = _.pluck(fieldValue, 'name');
            labelValue = ids.join(', ');
          } else {
            labelValue = fieldValue.join(', ');
          }
        }
        break;
      default:
        labelValue = fieldValue;
    }
    return labelValue;
  };
  ajForm.generateFieldsInViewMode = function(field, name, secondaryName) {
    var boldText, elFormName, fieldStr, fieldText, fieldValue, form, openNew, target;
    elFormName = secondaryName ? "" + secondaryName + "[" + name + "]" : name;
    if (field.label !== false && !field.label) {
      field.label = s.humanize(name);
    }
    fieldStr = JSON.stringify(field);
    fieldValue = ajForm.getFieldValueForViewMode(field, name, secondaryName);
    fieldText = ajForm.getFieldTextForViewMode(field, fieldValue);
    if (_.isUndefined(fieldValue) || _.isNull(fieldValue)) {
      fieldText = '';
    }
    form = '<div class="form-group fly-group">';
    form += '<label class="fly-label classic">' + field.label + ': ';
    boldText = "<b name='" + elFormName + "' el-name='" + name + "' field='" + fieldStr + "' class='ajFormBold'>" + fieldText + "</b>";
    if (field.link) {
      openNew = field.link.openNew;
      if (_.isUndefined(openNew)) {
        openNew = true;
      }
      target = openNew ? '_blank' : '_self';
      form += "<a target='" + target + "' href='" + field.link.url + "'>" + boldText + "</a>";
    } else {
      form += "<label>" + boldText + "</label>";
    }
    form += '</label>';
    return form += '</div>';
  };
  return ajForm.hideEmptyFieldsInViewMode = function() {
    var boldElements, displayEmpty;
    displayEmpty = ajForm.options.displayEmpty;
    if (_.isUndefined(displayEmpty)) {
      displayEmpty = true;
    }
    if (!displayEmpty) {
      boldElements = $(ajForm.formElement).find('b.ajFormBold');
      return _.each(boldElements, function(el) {
        var childElements, emptyRow, parent;
        if ($(el).text() === '') {
          parent = $(el).closest('.row');
          childElements = parent.find('b.ajFormBold');
          emptyRow = true;
          _.each(childElements, function(child) {
            if ($(child).text() !== '') {
              return emptyRow = false;
            }
          });
          if (emptyRow) {
            return parent.hide();
          } else {
            return $(el).closest('.col-md-6').hide();
          }
        }
      });
    }
  };
});
