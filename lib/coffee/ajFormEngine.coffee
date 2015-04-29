##
# Dependencies: pickadate, magicsuggest, parsley, underscore, underscore.string, wysihtml,backbone.syphon
##

jQuery(document).ready ($)->
	
	`window.scrollToDivScript = function(){
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
		}`
	
	ajForm = {}
	window.ajForm = ajForm if window.ionic
	
	$.AJFormEngine =(element, opts, data=[])->
		
		ajForm.autoSuggest = []
		ajForm.formData= data
		ajForm.options = opts
		form = '<form class="ajForm">'
		form += '<div class="list list-inset">' #Ionic css | Ignored on web
		form += ajForm.generateFields opts.fields, opts.columns
		form += ajForm.get_submit_button() if ajForm.options.mode isnt 'view'
		form += '</div>'
		form += '</form>'
		
		ajForm.appendForm form, element
		
		Backbone.Syphon.deserialize(element.find('form')[0], data) if not _.isEmpty data
		
		ajForm.formElement= formElement = element.find 'form'
		
		ajForm.fillFormSections data if not _.isEmpty data
		ajForm.bindConditions()

		if ajForm.options.mode is 'view'
			ajForm.showConditions()
			ajForm.hideEmptyFieldsInViewMode()
		
		ajForm.triggerFieldPlugins element
		
		$(formElement).bind 'submit', ajForm.handleFormSubmit
		$(formElement.find('.autogrow')).bind 'keyup', ajForm.autoGrowText
		$(formElement.find('a.add-section')).bind 'click', ajForm.addSection
		
		$(ajForm.formElement).trigger "aj:form:initialized", ajForm
		
		#trigger change event on all events so that if any conditions are there they'll get triggered
		$(ajForm.formElement.find('input,select')).trigger 'change' if not _.isEmpty data
		
		ajForm.addSideNav(element) if ajForm.options.nav
		$('body').scrollspy(target: '.bs-docs-sidebar') if not window.ionic
		window.scrollToDivScript()
		form
	
	#secondary_id is used incase of repeatable sections. gives the section a common index
	ajForm.generateFields=(fields, columns, secondaryName =false)->
		form = ''
		col=0
		_.each fields, (field,name)->
			columns = 1 if not columns
			columnClass = 12 / columns
			
			if field.type is 'hidden'
				form += ajForm.get_hidden field,name,secondaryName
				
			else if field.type in ['section', 'repeatable_section', 'html_section']
				if col isnt 0
					col=0
					form += '</div>' 
					
				if field.type is 'html_section'
					form += ajForm.get_html_section field, name
				else
					form += ajForm.get_section field, name, columns,secondaryName

			else
				#start new row if column count is 0
				form += '<div class="row">' if col is 0
				
				hideElement = if field.conditionals then ' style="display:none" ' else ''
				form += "<div class='ajForm-"+name+" col-md-#{columnClass}' "+hideElement+">"
				
				mode = ajForm.options.mode
				if mode is 'view'
					form += ajForm.generateFieldsInViewMode field, name, secondaryName
				else
					fieldFunction = ajForm['get_'+field.type]
					
					if typeof fieldFunction is 'function'
						field.label = s.humanize name if field.label isnt false and not field.label
						field.label += '<i class="fa fa-asterisk"></i>' if field.validation and field.validation.required
						form += '<div class="form-group fly-group">'
						form += '<label class="fly-label classic">'+field.label+'</label>' if field.label and !_.contains(['hidden', 'button'], field.type)
						form += fieldFunction field,name,secondaryName
						form += '</div>'
				
				form += '</div>'

				#if column count is reached, end the row and reset column count
				if col is columns-1
					col=0
					form += '</div>'

				#if column count isnt reached but fields are ended, close row div
				else if name is _.last _.keys fields
					form += '</div>'

				#else continue onto next column
				else col++
		form
	
	ajForm.get_section=(section,sectionName, columns,secondaryName=false)->
		
		if section.label? and section.label is false
			title=sectionClass= ''
		else
			section.label= s.titleize s.humanize sectionName if not section.label
			title= '<h5 class="thin">'+section.label+'</h5>'
			sectionClass = ' section-div'
		
		columns = section.columns if section.columns
		secondaryName = if secondaryName then "#{secondaryName}[#{sectionName}]" else sectionName
		sectionName = secondaryName if secondaryName
		secondaryName += "[#{ajForm.makeid()}]" if section.type is 'repeatable_section'
		
		hideElement = if section.conditionals then ' style="display:none" ' else ''
		
		html = '<section id="'+secondaryName+'" data-type="'+section.type+'" data-name="'+sectionName+'" class="ajForm-'+sectionName+'" '+hideElement+'>
				<div class="'+sectionClass+'">'+title
				
		html +='<div class="row"><div class="col-md-12">'
		html += ajForm.generateFields section.fields, columns, secondaryName
		html += '</div></div></div></section>'
		
		if section.type is 'repeatable_section' and ajForm.options.mode isnt 'view'
			html +='<div class="form-group clearfix">
						<a data-section="'+sectionName+'" class="add-section btn btn-default btn-sm pull-right m-t-10"><i class="fa fa-plus"></i> Add</a>
					</div>'
		
		html
		
	ajForm.addSection = (evt)->
		button = $(evt.currentTarget)
		sectionName = button.attr 'data-section'
		sectionEl = $(ajForm.formElement).find('section[data-name="'+sectionName+'"]')
		addedSection = sectionEl.first().clone()
		addedSection.find('textarea, select').val ''

		_.each addedSection.find('input'), (el)->
			$(el).val('') if $(el).attr('type') isnt 'button' #Don't clear the button value

		sectionEl.last().after addedSection
		newName = "#{ajForm.makeid()}"
		addedSection.find('input, textarea, select').each (index, ele)=>
			name = $(ele).attr 'name'
			array = name.split('[') if name
			arraySize=if name then _.size(array) else 0
			nameToReplace = ''
			nameToReplace = array[arraySize-2].split(']').shift() if arraySize >1
			if nameToReplace 
				completeName = name.replace nameToReplace, newName
				$(ele).attr 'name', completeName
				
		$(addedSection).removeClass 'hidden'		
		ajForm.addDeleteSectionLink addedSection
		ajForm.cleanupAddedSection addedSection		
		ajForm.triggerFieldPlugins addedSection
		
		$(ajForm.formElement).trigger "aj:form:section:added", addedSection
		
	ajForm.makeid = ->
		text = ""
		possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		for i in [0...5]
			text += possible.charAt(Math.floor(Math.random() * possible.length))

		text
		
	ajForm.removeSection = (evt)->
		sectionName = $(evt.target).closest('section').attr 'data-name'
		
		if $("section[data-name='#{sectionName}']:visible").length>1
			$(evt.target).closest('section').fadeOut 'fast'
		else
			alert "Cannot delete"
	
	ajForm.addDeleteSectionLink =(sectionEl)->
		if ajForm.options.mode isnt 'view'
			sectionEl.append '<div class="form-group clearfix">
					<a class="remove-section btn btn-link pull-right">Delete</a>
				</div>'
			
			$(sectionEl).find('a.remove-section').bind 'click', ajForm.removeSection
	
	ajForm.get_submit_button=->
		'<div class="row">
			<div class="col-md-12">
				<input type="submit" value="Save" class="btn btn-primary" />
			</div>
		</div>'
	
	ajForm.get_textbox=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		value = if field.value then field.value else ''
		"<input value='#{value}' type='text' #{ajForm.validations(field.validation)} #{ajForm.attributes(field.attributes)} class='form-control input-sm' name=#{name}>"
		
	ajForm.get_date=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<input type="date" '+ajForm.validations(field.validation)+' '+ajForm.attributes(field.attributes)+' class="form-control input-sm" name="'+name+'">'
		
	ajForm.get_dropdown=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = '<select '+ajForm.validations(field.validation)+' '+ajForm.attributes(field.attributes)+' name="'+name+'" class="form-control">'
		selectLabel = if _.has(field, 'selectLabel') then field.selectLabel else 'Select'
		html += '<option value="">'+selectLabel+'</option>'
		_.each field.options, (option)=>
			opt = ajForm.formatOptions option
			if opt
				html += '<option value="'+opt.value+'" '+ajForm.preSelected(field, option)+'>'+opt.label+'</option>'
		html += '</select>'

	ajForm.get_radio=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = ''
		_.each field.options, (option)->
			opt = ajForm.formatOptions option
			html += '<label class="radio-inline m-l-20">
					<input '+ajForm.validations(field.validation)+' type="radio" name="'+name+'" value="'+opt.value+'" '+ajForm.preSelected(field, option)+' '+ajForm.attributes(field.attributes)+'>
					<span class="lbl padding-8">'+opt.label+'</span>
				</label>'
		html
	
	ajForm.get_checkbox=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = ''
		_.each field.options, (option)->
			opt = ajForm.formatOptions option
			html += '<label class="radio-inline m-l-20">
					<input '+ajForm.validations(field.validation)+' type="checkbox" name="'+name+'" value="'+opt.value+'" '+ajForm.preSelected(field, option)+' '+ajForm.attributes(field.attributes)+'>
					<span class="lbl padding-8">'+opt.label+'</span>
				</label>'
		html
		
	ajForm.get_autosuggest=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<div data-id="'+name+'" class="magicsuggest" '+ajForm.attributes(field.attributes)+'></div>
		<input type="hidden" name="'+name+'" />'
		
	ajForm.get_textarea=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		autogrowClass = if field.autogrow then ' autogrow ' else ''
		'<textarea '+ajForm.validations(field.validation)+' '+ajForm.attributes(field.attributes)+' name="'+name+'" class="'+autogrowClass+' form-control" placeholder="Enter text ..."></textarea>'
		
	ajForm.get_richtext=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<textarea '+ajForm.validations(field.validation)+' name="'+name+'" class="richtext form-control" placeholder="Enter text ..."></textarea>'
	
	ajForm.get_html_section=(section, sectionName)->
		section.label= s.titleize s.humanize sectionName if not section.label
		'<h5 class="thin">'+section.label+'</h5>
		<div class="row">
			<div class="col-md-12">
				'+section.value+'
			</div>
		</div>'

	ajForm.get_multiselect_dropdown = (field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = '<select '+ajForm.validations(field.validation)+' '+ajForm.attributes(field.attributes)+' name="'+name+'" class="form-control" multiple>'
		_.each field.options, (option)=>
			opt = ajForm.formatOptions option
			html += '<option value="'+opt.value+'" '+ajForm.preSelected(field, option)+'>'+opt.label+'</option>'
		html += '</select>'

	ajForm.get_hidden = (field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<input type="hidden" class="form-control input-sm" name="'+name+'">'

	ajForm.get_label = (field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		if _.has(field, 'html') then content = field.html
		else content = 'Missing label option (html)'
		'<label name="'+name+'">'+content+'</label>'

	ajForm.get_button = (field, name, secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		field.label = s.titleize s.humanize name if not field.label
		'<input type="button" value="'+field.label+'" name="'+name+'" '+ajForm.attributes(field.attributes)+' class="btn btn-primary" />'
	
	ajForm.get_geoSearch = (field, name, secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<div class="geoSearch" id="geoSearch"></div>'
		
	ajForm.get_address= (field, name, secondaryName)->
		field.label = 'Address'
		field.type	= 'repeatable_section'
		field.fields=
			type			: type : 'dropdown', options:['meeting','residential','office']
			address			: type : 'textarea'
			country			: type : 'textbox', vallue:'United Kingdom'
			region			: type : 'textbox'
			city			: type : 'textbox'
			postcode		: label: 'Postal Code', type : 'textbox'
			notes			: type : 'textarea'
			lat				: type : 'hidden'
			lng				: type : 'hidden'
			geoSearch		: 
				label	: false
				type	: 'section'
				columns	:1
				fields	: geoSearch : type: 'geoSearch', label: false
			
		ajForm.generateFields address:field, 2
		
	ajForm.validations=(validation)->
		validation_str = ''

		_.each validation, (value,key)->
			validation_str += " data-parsley-#{key}='#{value}'"
		
		validation_str
		
	ajForm.formatOptions=(opt)->
		if typeof opt in ['string', 'number']
			label 	= s.titleize s.humanize opt
			value 	= opt
			opt = {label: label, value: value}
		opt

	ajForm.preSelected = (field, option)->
		selected = ''
		optionDefaults = 
			multiple : ->
				if (_.isObject(option) and _.contains(field.default, option.value)) or _.contains(field.default, option) then true else false
			single : ->
				if (_.isObject(option) and field.default is option.value) or (field.default is option) then true else false

		if _.has(field, 'default')
			switch field.type
				when 'dropdown'
					if optionDefaults.single() then selected = 'selected="selected"'
				when 'multiselect_dropdown'
					if optionDefaults.multiple() then selected = 'selected="selected"'
				when 'radio'
					if optionDefaults.single() then selected = 'checked="checked"'
				when 'checkbox'
					if optionDefaults.multiple() then selected = 'checked="checked"'

		selected

	ajForm.attributes = (attrs)->
		attributes = ''
		if attrs and _.isObject(attrs)
			_.each attrs, (attr)->
				attributes += "#{attr} "
		attributes
		
	ajForm.addDatePicker=(element)->
		dateElements = element.find 'input[type="date"]'
		_.each dateElements, (el)->
			dateObj = ajForm.getFieldOption el.name
			min = max = undefined
			if _.has(dateObj, 'min')
				min = if dateObj.min is 'today' then new Date() else new Date(dateObj.min)
			if _.has(dateObj, 'max') 
				max = if dateObj.max is 'today'then new Date() else new Date(dateObj.max)
			$(el).pickadate 
				'container'		: 'body'
				'selectYears'	: true
				'selectMonths'	: true
				'formatSubmit' 	: 'yyyy-mm-dd'
				'min'           : min
				'max'           : max
			
	ajForm.addAutoSuggest=(element)->
		divs= element.find '.magicsuggest'
		_.each divs, (el)->
			fieldName = $(el).attr 'data-id'
			item= ajForm.getFieldOption fieldName
			
			if item.optionsUrl then items = item.optionsUrl
			else items=_.map item.options, (opt)->
					opt= ajForm.formatOptions opt
					data= id: opt.value, name: opt.label
					
			fieldValue = ajForm.getFormDataItem fieldName

			preselected = []
			if fieldValue and _.size(fieldValue)>0
				preselected = [fieldValue.id] if fieldValue.id? 
			
			preselected = _.compact preselected
			
			if _.isEmpty(preselected) and not _.isEmpty _.compact fieldValue
				preselected = _.pluck fieldValue, 'id' 
				preselected = fieldValue if _.isEmpty _.compact preselected

			#TODO: Remove below line
			preselected = eval preselected
			
			magicSuggest = $(el).magicSuggest
				maxSelection	: if item.maxSelection then item.maxSelection else false
				data			: items
				value			: preselected if not _.isEmpty _.compact preselected
				ajaxConfig		: 
					method: 'GET'
					headers: 'X-WP-Nonce': WP_API_NONCE if WP_API_NONCE
					
			$(magicSuggest).on 'selectionchange', (e,m)->
				$(ajForm.formElement).find "input[name='#{fieldName}']"
				# .val JSON.stringify this.getValue()
				.val JSON.stringify this.getSelection()
					
			ajForm.autoSuggest.push field: fieldName, magicSuggest: magicSuggest
					
		divs
	
	ajForm.getFormDataItem =(fieldName)->
		nameArr= fieldName.split '['
		str= ''
		for item in nameArr
			i = s.replaceAll item, ']', ''
			str += "['#{i}']"
			evalStr= 'ajForm.formData'+str
			break if _.isUndefined eval evalStr

		evalStr= 'ajForm.formData'+str
		item = eval(evalStr)
		
	ajForm.setAutogrowTextHeight = (el)->
		elements= el.find '.autogrow'

		_.each elements, (ele)->
			scrollHeight = $(ele).prop('scrollHeight')+2
			$(ele).css 'height' : scrollHeight + "px";
	
	ajForm.autoGrowText= (e)->
		ele= $ e.target

		if $(ele).prop('clientHeight') < $(ele).prop('scrollHeight')
			$(ele).css 'height' : $(ele).prop('scrollHeight') + "px";

		if $(ele).prop('clientHeight') < $(ele).prop('scrollHeight')
			$(ele).css 'height' : ($(ele).prop('scrollHeight') * 2 - $(ele).prop('clientHeight')) + "px"

	ajForm.addMultiselectDropdown = (element)->
		multiselectElements = element.find '[multiple]'
		_.each multiselectElements, (el)->
			$(el).multiselect
				includeSelectAllOption: true

	ajForm.filterDateFieldsForSerialization = ->
		dateElements = $ '.picker__input'
		_.each dateElements, (el)->
			name = el.name
			$('input[name="'+name+'_submit"]').attr 'name', name
			
	ajForm.handleFormSubmit=(e)->
		e.preventDefault()
		form = $(e.target).closest 'form'
		
		validator = form.parsley 
						excluded		: ':hidden'
						errorsContainer : (ParsleyField)-> $(ParsleyField.$element).closest '.form-group'
		validator.destroy()
		validator.validate()
		
		if validator.isValid()
			
			#excluding items hidden due to conditionals. 
			hiddenItems = ajForm.formElement.find '[class^=ajForm-]:hidden input, [class^=ajForm-]:hidden select, [class^=ajForm-]:hidden textarea'
			excludeItems = _.map hiddenItems, (item)-> $(item).attr 'name'
			
			ajForm.filterDateFieldsForSerialization()
			data = Backbone.Syphon.serialize @, exclude: excludeItems
			
			$(form).trigger "aj:form:submitted", data

			if _.has(ajForm.options, 'submitUrl')
				$.ajax 
					url: ajForm.options.submitUrl
					type: 'POST'
					data: data
					beforeSend: (xhr)->
						$(form).trigger "aj:form:ajax:before:submit", data
					complete: (xhr)->
						$(form).trigger "aj:form:ajax:submit:complete", xhr
			
	ajForm.bindConditions=->
		conditions = ajForm.getConditions ajForm.options.fields
		
		triggers = _.map conditions, (c)-> _.keys(c)
		ajForm.triggers = _.unique _.flatten triggers
		
		_.each ajForm.triggers, (t)->
			element = ajForm.findFieldElement t
			$(element).bind 'change', ajForm.triggerConditional
	
	ajForm.getConditions=(fields, conditions=[])->
		_.each fields, (field)->
			if field.conditionals
				if field.conditionals.conditions
					conditions.push field.conditionals.conditions 
				else
					conditions.push field.conditionals					
			ajForm.getConditions field.fields,conditions if field.fields 
		conditions
		
	#fields that mite be affected by the trigger
	ajForm.getAffectableFields=(fields, triggerName, conditionals=[])->
		_.each fields, (field,index)->
			if field.conditionals
				if _.has(field.conditionals,triggerName) or _.has field.conditionals.conditions,triggerName
					field.name = index
					conditionals.push field
			ajForm.getAffectableFields field.fields,triggerName,conditionals if field.fields 
		conditionals
	
	ajForm.triggerConditional=(evt, triggerItem)->
		if evt
			triggerValue= $(evt.target).val()
			triggerName = $(evt.target).attr 'name'
		else
			triggerValue= triggerItem.value
			triggerName = triggerItem.name

		affectableFields = ajForm.getAffectableFields ajForm.options.fields,triggerName
		
		#affectableFields are fields that get affected due to this change
		_.each affectableFields, (field)->
			
			if field.conditionals.conditions
				fieldConditions		= field.conditionals.conditions
				fieldConditionType	= field.conditionals.type
				fieldDisplay		= field.conditionals.display
			
			else
				fieldConditions		= {}
				_.each field.conditionals, (c,index)-> fieldConditions[index]=  operator: '=', value : c
				fieldConditionType	= 'any'
				fieldDisplay		= 'show'
			
			requiredMatches = if fieldConditionType is 'any' then 1 else _.size fieldConditions
			matchCount		= 0
			success = false
			_.each fieldConditions, (c,index)->

				ele = ajForm.findFieldElement index
				eleVal = ele.val()
				
				mode = ajForm.options.mode
				eleVal = ajForm.getFormDataItem(index) if mode is 'view'
				
				#get radio button's selected value
				if mode isnt 'view'
					eleVal = $("input[name="+ele.attr('name')+"]:checked").val() if ele.attr('type') is 'radio' 
				#TODO: handle checkboxes conditional
				
				switch (c.operator)
					when '='
						matchCount++ if eleVal is c.value
					when '>'
						matchCount++ if parseInt(eleVal) > parseInt c.value
					when '<'
						matchCount++ if parseInt(eleVal) < parseInt c.value
					when 'like'
						matchCount++ if s.contains eleVal,c.value
						
				if matchCount is requiredMatches
					success= true
			
			#show or hide the element based on display type
			fieldDivEl = $(ajForm.formElement).find '.ajForm-'+field.name
			
			if success
				if fieldDisplay is 'show' then fieldDivEl.show() else fieldDivEl.hide()
			else
				if fieldDisplay is 'show' then fieldDivEl.hide() else fieldDivEl.show()

			ajForm.formElement.trigger "aj:conditional:triggered"
				
				
	ajForm.findFieldElement=(name)->
		element = $(ajForm.formElement).find "input[name='#{name}']"
		element = $(ajForm.formElement).find "select[name='#{name}']" if element.length is 0
		element
	
	#get the option item from intialization options
	ajForm.getFieldOption=(name)->
		if s.contains name, '['
			fieldPathArr = name.split '['
			item = ajForm.options
			_.each fieldPathArr, (pathItem,index)->
				pathItem=s.replaceAll pathItem,']',''
				item = item.fields[pathItem] if item.fields[pathItem]?
		else
			item= ajForm.options.fields[name]
			
		item

	ajForm.bindButtonEvents = (element)->
		buttonElements = element.find 'input[type="button"]'
		_.each buttonElements, (el)->
			buttonObj = ajForm.getFieldOption el.name
			if _.has(buttonObj, 'triggerClick')
				$(el).bind 'click', (e)->
					$(ajForm.formElement).trigger "#{buttonObj.triggerClick}", e

		
	ajForm.triggerFieldPlugins=(element)->
		ajForm.addDatePicker element
		ajForm.addAutoSuggest element
		ajForm.setAutogrowTextHeight element
		ajForm.addMultiselectDropdown element
		$(element).find('.richtext').wysihtml5()
		ajForm.addGeoSearch element
		ajForm.bindButtonEvents element

	#remove unnecessary dom elements from the cloned section
	ajForm.cleanupAddedSection=(addedSection)->
		$(addedSection).find '.multiselect'
		.closest '.btn-group'
		.remove()
				
	ajForm.fillFormSections =(data)=>
		
		repeatableSections = $(ajForm.formElement).find 'section[data-type="repeatable_section"]'
		
		_.each repeatableSections, (section)->
			dataName = $(section).attr 'data-name'
			dataRecords = ajForm.getFormDataItem dataName
			
			#show an empty section if no data entered for that section
			dataRecords = [{}] if _.isEmpty dataRecords
			_.each dataRecords, (record, key)=>
				sectionEle = $(section).first().clone()

				sectionEle.find('input, textarea, select, b.ajFormBold').val ''
				sectionEle.find('input, textarea, select, b.ajFormBold').each (index, ele)=>
					field_name = $(ele).attr 'name'
					name =s.ltrim field_name, dataName
					array = name.split '['
					if array[0]
						nameToReplace = array[0].split(']').shift()
					else
						nameToReplace = array[1].split(']').shift()
					
					if nameToReplace
						newSectionID = sectionEle.attr('id').replace nameToReplace, key
						sectionEle.attr 'id', newSectionID

						completeName = field_name.replace nameToReplace, key
						$(ele).attr 'name', completeName
						property = name.split('[').pop().slice(0,-1)
						$(ele).val record[property]
					else
						$(ele).val key

					if ajForm.options.mode is 'view'
						field = JSON.parse $(ele).attr('field')
						name = $(ele).attr 'el-name'
						fieldValue = ajForm.getFieldValueForViewMode field, name, newSectionID
						fieldText = ajForm.getFieldTextForViewMode field, fieldValue
						$(ele).text fieldText

				ajForm.addDeleteSectionLink sectionEle

				$(section).last().after sectionEle
			
			$(section).first().addClass 'hidden' if dataRecords
			
	ajForm.appendForm = (form,element)->
		if ajForm.options.nav
			html = '<div class="row">
							<div class="ajFormNav col-sm-3">
								<div id="checkdiv"></div>
								<nav class="bs-docs-sidebar sub-menu">
									<ul class="sub-menu-links nav"></ul>
								</nav>
							</div>
							<div class="col-sm-9">
								<div id="formSteps">'+form+'</div>
							</div>
						</div>'
			element.append html
		else
			element.append form
			
		
	ajForm.addSideNav =(element)->
		
		items=[];
		
		fields =ajForm.options.fields
		_.each fields,(field,fieldName)->
			ajForm.getNavItem field,fieldName,items
		
		element.find '.sub-menu-links'
		.append items.join ''
				
	ajForm.getNavItem =(field,fieldName,items=[])->
	
		if field.type in ['section','repeatable_section'] and not field.hideNav
			if $(ajForm.formElement).find("section[data-name='#{fieldName}']").is ':visible' 
				label = if field.label then field.label else s.titleize(s.humanize(fieldName))
				items.push "<li><a section-id='#{fieldName}'>#{label}</a>"
				
				items.push "<ul class='nav nav-stacked'>" if _.findWhere(field.fields,('type': 'section')) and not field.hideNav
				_.each field.fields,(field, fName)->
					ajForm.getNavItem field,"#{fieldName}[#{fName}]",items
				items.push "</ul>" if _.findWhere(field.fields,('type': 'section')) and not field.hideNav
				
				items.push "</li>"
		items
		
	ajForm.addGeoSearch=(element)->
		
		geoSearchEls= element.find '.geoSearch'
		
		_.each geoSearchEls, (el)->
			section		= $(el).closest 'section[data-name="address"]'
			lngEl		= section.find 'input[name$="[lng]"]'
			latEl		= section.find 'input[name$="[lat]"]'
			addressEl	= section.find 'textarea[name$="[address]"]'
			countryEl	= section.find 'input[name$="[country]"]'
			regionEl	= section.find 'input[name$="[region]"]'
			cityEl		= section.find 'input[name$="[city]"]'
			postcodeEl	= section.find 'input[name$="[postcode]"]'
			
			if( lngEl.val() and latEl.val() ) 
				latlng = new google.maps.LatLng(latEl.val(),lngEl.val());
			else
				latlng = new google.maps.LatLng(51.49506473014368,-0.087890625);

			options = {
				zoom: 6,
				center: latlng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			};

			map = new google.maps.Map(el, options);

			geocoder = new google.maps.Geocoder();

			marker = new google.maps.Marker
				map: map,
				draggable: true,
				position: latlng,
				title:"Si el domicilio que desea agendar no es este, por favor mueva este marcador a la posición correcta."

			google.maps.event.addListener marker, 'dragend', ->
				geocoder.geocode {'latLng': marker.getPosition()}, (results, status)->
					if (status == google.maps.GeocoderStatus.OK) 
						if (results[0]) 
							latEl.val(marker.getPosition().lat());
							lngEl.val(marker.getPosition().lng());
							$(addressEl).val results[0]['formatted_address']
							ajForm.updateAddressLocations section, results[0]['address_components']
			
			$(el).closest('section[data-name="address"]').find 'textarea[name$="[address]"], input[name$="[country]"], input[name$="[region]"], input[name$="[city]"]'
			.bind 'change', (e)->
				term = ''
				if addressEl.val()
					term += ' '+addressEl.val() 
				else
					term += ' '+countryEl.val() if countryEl.val()
					term += ' '+regionEl.val() if regionEl.val()
					term += ' '+cityEl.val() if cityEl.val()
				
				geocoder.geocode {'address': term }, (results, status)->
					if results? and results.length > 0 
						latlong= results[0]['geometry']['location']
						latEl.val(latlong['k']);
						lngEl.val(latlong['D']);
						location = new google.maps.LatLng(latlong['k'], latlong['D']);
						marker.setPosition(location);
						map.setCenter(location);
						ajForm.updateAddressLocations section, results[0]['address_components']
						
	ajForm.updateAddressLocations =(section,addressComponents)->
		
		countryEl	= section.find 'input[name$="[country]"]'
		regionEl	= section.find 'input[name$="[region]"]'
		cityEl		= section.find 'input[name$="[city]"]'
		postcodeEl	= section.find 'input[name$="[postcode]"]'

		countryEl.val ''
		regionEl.val ''
		postcodeEl.val ''
		cityEl.val ''

		_.each addressComponents, (addr)->
			countryEl.val	addr.long_name if 'country' in addr.types
			regionEl.val	addr.long_name if 'administrative_area_level_1' in addr.types
			regionEl.val	addr.long_name if not regionEl.val() and 'administrative_area_level_2' in addr.types
			cityEl.val		addr.long_name if 'postal_town' in addr.types
			postcodeEl.val	addr.long_name if 'postal_code' in addr.types

	ajForm.showConditions = ->
		_.each ajForm.triggers, (trigger)->
			item = name: trigger, value: ajForm.getFormDataItem(trigger)
			ajForm.triggerConditional(null, item)

	ajForm.getFieldValueForViewMode = (field, name, secondaryName)->
		if secondaryName
			fieldValue = ajForm.getFormDataItem secondaryName
			fieldValue = fieldValue[name] if fieldValue
		else 
			fieldValue = ajForm.getFormDataItem name
		fieldValue

	ajForm.getFieldTextForViewMode = (field, fieldValue)->
		labelValue = ''

		switch field.type
			when 'dropdown'
				if field.options[0].value
					filteredOption = _.filter field.options, (opt) -> opt.value is fieldValue
					labelValue = filteredOption[0].label
				else labelValue = s.humanize fieldValue

			when 'multiselect_dropdown'
				tempArr = []
				_.each fieldValue, (val)->
					if field.options[0].value
						filteredOption = _.filter field.options, (opt) -> opt.value is val
						tempArr.push filteredOption[0].label
					else tempArr.push s.humanize(val)
				labelValue = tempArr.join ', '

			when 'autosuggest'
				fieldValue = eval fieldValue
				if !_.isUndefined(fieldValue) and !_.isEmpty(fieldValue)
					if fieldValue[0].id
						ids = _.pluck fieldValue, 'name'
						labelValue = ids.join ', '
					else labelValue = fieldValue.join ', '
			else
				#When textbox, textarea, date, label
				labelValue = fieldValue

		labelValue

	ajForm.generateFieldsInViewMode = (field, name, secondaryName)->
		elFormName = if secondaryName then "#{secondaryName}[#{name}]" else name
		field.label = s.humanize name if field.label isnt false and not field.label
		fieldStr = JSON.stringify field

		fieldValue = ajForm.getFieldValueForViewMode field, name, secondaryName
		fieldText = ajForm.getFieldTextForViewMode field, fieldValue

		if _.isUndefined(fieldValue) or _.isNull(fieldValue)
			fieldText = ''

		form = '<div class="form-group fly-group">'
		form += '<label class="fly-label classic">'+field.label+': '
		boldText = "<b name='"+elFormName+"' el-name='"+name+"' field='"+fieldStr+"' class='ajFormBold'>"+fieldText+"</b>"

		if field.link 
			openNew = field.link.openNew
			openNew = true if _.isUndefined openNew
			target = if openNew then '_blank' else '_self'
			form += "<a target='"+target+"' href='"+field.link.url+"'>"+boldText+"</a>"
		else 
			form += "<label>"+boldText+"</label>"

		form += '</label>'
		form += '</div>'

	ajForm.hideEmptyFieldsInViewMode = ->
		displayEmpty = ajForm.options.displayEmpty
		displayEmpty = true if _.isUndefined displayEmpty

		if !displayEmpty
			boldElements = $(ajForm.formElement).find 'b.ajFormBold'
			_.each boldElements, (el)->
				if $(el).text() is ''
					parent = $(el).closest '.row'
					childElements = parent.find 'b.ajFormBold'

					emptyRow = true
					_.each childElements, (child)->
						emptyRow = false if $(child).text() isnt ''

					if emptyRow then parent.hide()
					else $(el).closest('.col-md-6').hide()

