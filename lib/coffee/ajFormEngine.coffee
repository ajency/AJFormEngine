##
# Dependencies: pickadate, magicsuggest, parsley, underscore, underscore.string, wysihtml,backbone.syphon
##

jQuery(document).ready ($)->
	
	ajForm = {}
	
	$.AJFormEngine =(element, opts, data=[])->
		
		ajForm.options = opts
		form = '<form>'
		form += ajForm.generateFields opts.fields, opts.columns
		form += ajForm.get_submit_button()
		form += '</form>'
		element.append form
		
		Backbone.Syphon.deserialize(element.find('form')[0], data) if not _.isEmpty data
		
		ajForm.formElement= formElement = element.find 'form'
		
		ajForm.bindConditions()
		
		ajForm.triggerFieldPlugins element
		
		$(formElement).bind 'submit', ajForm.handleFormSubmit
		$(formElement.find('.autogrow')).bind 'keyup', ajForm.autoGrowText
		$(formElement.find('a.add-section')).bind 'click', ajForm.addSection
		$(ajForm.formElement).trigger "aj:form:initialized", ajForm
		
		#trigger change event on all events so that if any conditions are there they'll get triggered
		$(ajForm.formElement.find('input,select')).trigger 'change' if not _.isEmpty data
		
		form
	
	#secondary_id is used incase of repeatable sections. gives the section a common index
	ajForm.generateFields=(fields, columns, secondaryName =false)->
		form = ''
		col=0
		_.each fields, (field,name)->
			columns = 1 if not columns
			columnClass = 12 / columns
			
			if field.type in ['section', 'repeatable_section', 'html_section']
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
				
				fieldFunction= ajForm['get_'+field.type]
				
				if typeof fieldFunction is 'function'
					field.label = s.humanize name if not field.label
					field.label += '<i class="fa fa-asterisk"></i>' if field.validation and field.validation.required
					form += '<div class="form-group fly-group">'
					form += '<label class="fly-label classic">'+field.label+'</label>' if !_.contains(['hidden', 'button'], field.type)
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
			sectionClass = ' well'
		
		columns = section.columns if section.columns
		secondaryName = if secondaryName then "#{secondaryName}[#{sectionName}]" else sectionName
		secondaryName += "[#{ajForm.makeid()}]" if section.type is 'repeatable_section'
		
		hideElement = if section.conditionals then ' style="display:none" ' else ''
		
		html = '<section class="ajForm-'+sectionName+' '+sectionName+'" '+hideElement+'>
				<div class="'+sectionClass+'">'+title
				
		html +='<div class="row"><div class="col-md-12">'
		html += ajForm.generateFields section.fields, columns, secondaryName
		html += '</div></div></div></section>'
		
		if section.type is 'repeatable_section'
			html +='<div class="form-group clearfix">
						<a data-section="'+sectionName+'" class="add-section btn btn-default btn-sm pull-right m-t-10"><i class="fa fa-plus"></i> Add</a>
					</div>'
		
		html
		
	ajForm.addSection = (evt)->
		button = $(evt.currentTarget)
		sectionName = button.attr 'data-section'
		section = $(ajForm.formElement).find('.' + sectionName).first().clone()
		section.find('textarea, select').val ''

		_.each section.find('input'), (el)->
			$(el).val('') if $(el).attr('type') isnt 'button' #Don't clear the button value

		$(ajForm.formElement).find('.' + sectionName).last().after section
		newName = "#{ajForm.makeid()}"
		section.find('input, textarea, select').each (index, ele)=>
			name = $(ele).attr 'name'
			array = name.split('[') if name
			arraySize=if name then _.size(array) else 0
			nameToReplace = ''
			nameToReplace = array[arraySize-2].split(']').shift() if arraySize >1
			if nameToReplace 
				completeName = name.replace nameToReplace, newName
				$(ele).attr 'name', completeName
				
		addedSection = $(ajForm.formElement).find('.' + sectionName).last()
		addedSection.append '<div class="form-group clearfix">
				<a class="remove-section btn btn-link pull-right">Delete</a>
			</div>'
		
		$(ajForm.formElement).find('a.remove-section').bind 'click', ajForm.removeSection
		
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
		$(evt.target).closest('section').fadeOut 'fast'
		
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
		'<div data-id="'+name+'" class="magicsuggest" '+ajForm.attributes(field.attributes)+'></div>'
		
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
			html += '<option value="'+opt.value+'">'+opt.label+'</option>'
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
	
	ajForm.validations=(validation)->
		validation_str = ''

		_.each validation, (value,key)->
			validation_str += " data-parsley-#{key}='#{value}'"
		
		validation_str
		
	ajForm.formatOptions=(opt)->
		if typeof opt in ['string', 'number']
			label 	= s.titleize s.humanize opt
			value 	= s.underscored opt
			opt = {label: label, value: value}
		opt

	ajForm.preSelected = (field, option)->
		selected = ''
		if _.has(field, 'default')
			switch field.type
				when 'dropdown'
					if (_.isObject(option) and field.default is option.value) or (field.default is option)
						selected = 'selected'
				when 'radio'
					if (_.isObject(option) and field.default is option.value) or (field.default is option)
						selected = 'checked'
				when 'checkbox'
					if (_.isObject(option) and _.contains(field.default, option.value)) or _.contains(field.default, option)
						selected = 'checked'

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
		ajForm.autoSuggest = []
		_.each divs, (el)->
			fieldName = $(el).attr 'data-id'
			item= ajForm.getFieldOption fieldName
			
			if item.optionsUrl then items = item.optionsUrl
			else items=_.map item.options, (opt)->
					opt= ajForm.formatOptions opt
					data= id: opt.value, name: opt.label
					
			magicSuggest = $(el).magicSuggest
				maxSelection	: if item.maxSelection then item.maxSelection else false
				data			: items
				ajaxConfig		: 
					method: 'GET'
					headers: 'X-WP-Nonce': WP_API_NONCE if WP_API_NONCE

			ajForm.autoSuggest.push field: fieldName, magicSuggest: magicSuggest
					
		divs
		
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

	
	ajForm.addAutoSuggestFieldsToSerializedData = (data)->
		autoSuggest = ajForm.autoSuggest
		divs = $ '.ms-ctn'
		_.each divs, (el, index)->
			field = autoSuggest[index].field
			selection = autoSuggest[index].magicSuggest.getSelection()
			arr = field.split '['
			arrSize = _.size arr
			if !$(el).is(':hidden')
				if _.size(arr) is 1
					data["#{arr[0]}"] = selection
				else
					obj = data["#{arr[0]}"]
					_.each arr, (val, i)->
						val = val.replace ']', ''
						if i > 0
							if obj["#{val}"]? then obj = obj["#{val}"] else obj["#{val}"] = {}
						if i is arrSize-1
							obj["#{val}"] = selection


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
			ajForm.addAutoSuggestFieldsToSerializedData data
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
		triggers = _.unique _.flatten triggers
		
		_.each triggers, (t)->
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
	
	ajForm.triggerConditional=(evt)->
		
		triggerValue= $(evt.target).val()
		triggerName = $(evt.target).attr 'name'
		
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
				
				#get radio button's selected value
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
		ajForm.bindButtonEvents element

	#remove unnecessary dom elements from the cloned section
	ajForm.cleanupAddedSection=(addedSection)->
		$(addedSection).find '.multiselect'
		.closest '.btn-group'
		.remove()

