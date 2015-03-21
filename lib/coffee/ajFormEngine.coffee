##
# Dependencies: pickadate, magicsuggest, parsley, underscore, underscore.string, wysihtml,backbone.syphon
##

jQuery(document).ready ($)->
	
	ajForm = {}
	
	$.AJFormEngine =(element, opts)->
		
		ajForm.options = opts
		form = '<form>'
		form += ajForm.generateFields opts.fields, opts.columns
		form += ajForm.get_submit_button()
		form += '</form>'
		element.append form
		
		ajForm.formElement= formElement = element.find 'form'
		
		ajForm.bindConditions()
		
		ajForm.addDatePicker element
		ajForm.addAutoSuggest element
		ajForm.setAutogrowTextHeight element
		$(formElement).find('.richtext').wysihtml5()
		
		$(formElement).bind 'submit', ajForm.handleFormSubmit
		$(formElement.find('.autogrow')).bind 'keyup', ajForm.autoGrowText
		$(formElement.find('a.add-section')).bind 'click', ajForm.addSection
		form
	
	#secondary_id is used incase of repeatable sections. gives the section a common index
	ajForm.generateFields=(fields, columns, secondaryName = false)->
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
					form += ajForm.get_section field, name, columns 

			else
				#start new row if column count is 0
				form += '<div class="row">' if col is 0
				
				hideElement = if field.conditionals then ' style="display:none" ' else ''
				form += "<div class='ajForm-"+name+" col-md-#{columnClass}' "+hideElement+">"
				
				fieldFunction= ajForm['get_'+field.type]
				
				if typeof fieldFunction is 'function'
					field.label = s.humanize name if not field.label
					field.label += '<i class="fa fa-asterisk"></i>' if field.validation and field.validation.required
					form += '<div class="form-group fly-group">
								<label class="fly-label classic">'+field.label+'</label>'
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
	
	ajForm.get_section=(section,sectionName, columns)->
		section.label= s.titleize s.humanize sectionName if not section.label
		
		columns = section.columns if section.columns
		secondaryName = "#{sectionName}[#{ajForm.makeid()}]" if section.type is 'repeatable_section'
		
		hideElement = if section.conditionals then ' style="display:none" ' else ''
		
		html = '<section class="ajForm-'+sectionName+' '+sectionName+'" '+hideElement+'>
				<div class="well">
				<h5 class="thin">'+section.label+'</h5>'
		html +='<div class="row"><div class="col-md-12">'
		html += ajForm.generateFields section.fields, columns, secondaryName
		html += '</div></div></div></section>'
		
		if section.type is 'repeatable_section'
			html +='<div class="form-group clearfix">
						<a data-section="'+sectionName+'" class="add-section btn btn-default btn-sm pull-right m-t-10"><i class="fa fa-plus"></i> Add</a>
					</div>'
		
		html
		
	ajForm.addSection = (evt)->
		button = $(evt.target)
		sectionName = button.attr 'data-section'
		section = $(ajForm.formElement).find('.' + sectionName).first().clone()
		section.find('input, textarea, select').val ''
		$(ajForm.formElement).find('.' + sectionName).last().after section
		newName = "#{ajForm.makeid()}"
		section.find('input, textarea, select').each (index, ele)=>
			name = $(ele).attr 'name'
			array = name.split '['
			nameToReplace = array[1].split(']').shift()
			if nameToReplace 
				completeName = name.replace nameToReplace, newName
				$(ele).attr 'name', completeName
				
		$(ajForm.formElement).find('.' + sectionName).last()
		.append '<div class="form-group clearfix">
				<a class="remove-section btn btn-link pull-right">Delete</a>
			</div>'
		
		$(ajForm.formElement).find('a.remove-section').bind 'click', ajForm.removeSection
		
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
		'<input type="text" '+ajForm.validations(field.validation)+' class="form-control input-sm" name="'+name+'">'
		
	ajForm.get_date=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<input type="date" '+ajForm.validations(field.validation)+' class="form-control input-sm" name="'+name+'">'
		
	ajForm.get_dropdown=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = '<select '+ajForm.validations(field.validation)+'  name="'+name+'" class="form-control">'
		_.each field.options, (opt)=>
			opt = ajForm.formatOptions opt
			html += '<option value="'+opt.value+'">'+opt.label+'</option>'
		html += '</select>'

	ajForm.get_radio=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = ''
		_.each field.options, (opt)->
			opt = ajForm.formatOptions opt
			html += '<label class="radio-inline m-l-20">
					<input '+ajForm.validations(field.validation)+' type="radio" name="'+name+'" value="'+opt.value+'">
					<span class="lbl padding-8">'+opt.label+'</span>
				</label>'
		html
	
	ajForm.get_checkbox=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = ''
		_.each field.options, (opt)->
			opt = ajForm.formatOptions opt
			html += '<label class="radio-inline m-l-20">
					<input '+ajForm.validations(field.validation)+' type="checkbox" name="'+name+'" value="'+opt.value+'">
					<span class="lbl padding-8">'+opt.label+'</span>
				</label>'
		html
		
	ajForm.get_autosuggest=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		'<div data-id="'+name+'" class="magicsuggest"></div>'
		
	ajForm.get_textarea=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		autogrowClass = if field.autogrow then ' autogrow ' else ''
		'<textarea '+ajForm.validations(field.validation)+' name="'+name+'" class="'+autogrowClass+' form-control" placeholder="Enter text ..."></textarea>'
		
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
		
	ajForm.addDatePicker=(element)->
		dateElements = element.find 'input[type="date"]'
		_.each dateElements, (el)->
			dateObj = ajForm.getFieldOption el.name
			console.log dateObj
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
			item= ajForm.options.fields[fieldName]
			# item = ajForm.getFieldOption fieldName
			
			if item.optionsUrl then items = item.optionsUrl
			else items=_.map item.options, (opt)->
					opt= ajForm.formatOptions opt
					data= id: opt.value, name: opt.label
					
			$(el).magicSuggest
				maxSelection	: if item.maxSelection then item.maxSelection else false
				data			: items
				
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
	
	ajForm.handleFormSubmit=(e)->
		e.preventDefault()
		form = $(e.target).closest 'form'
		
		validator = form.parsley errorsContainer : (ParsleyField)-> $(ParsleyField.$element).closest '.form-group'
		validator.validate()
		if validator.isValid()
			data = Backbone.Syphon.serialize @
			$(form).trigger "ajFormSubmitted", data
			
	ajForm.bindConditions=->
		conditions= _.chain ajForm.options.fields
					.pluck 'conditionals'
					.compact()
					.pluck 'conditions'
					.value()
		
		triggers = _.map conditions, (c)-> _.keys(c)
		triggers = _.unique _.flatten triggers
		
		_.each triggers, (t)->
			element = ajForm.findFieldElement t
			$(element).bind 'change', ajForm.triggerConditional
	
	ajForm.triggerConditional=(evt)->
		
		triggerValue= $(evt.target).val()
		triggerName = $(evt.target).attr 'name'
		
		conditionalFields = _.filter ajForm.options.fields, (field,index)-> 
								if field.conditionals and _.has field.conditionals.conditions,triggerName
									field.name = index
									field
		
		#conditionalFields are fields that get affected due to this change
		_.each conditionalFields, (field)->
			conditions = field.conditionals.conditions
			
			requiredMatches = if field.conditionals.type is 'any' then 1 else _.size conditions
			matchCount		= 0
			success = false
			
			_.each conditions, (c,index)->
				ele = ajForm.findFieldElement index
				switch (c.operator)
					when '='
						matchCount++ if ele.val() is c.value
					when '>'
						matchCount++ if parseInt(ele.val()) > parseInt c.value
					when '<'
						matchCount++ if parseInt(ele.val()) < parseInt c.value
					when 'like'
						matchCount++ if s.contains ele.val(),c.value
						
				if matchCount is requiredMatches
					success= true
					
			if success
				if field.conditionals.display is 'show'
					$(ajForm.formElement).find('.ajForm-'+field.name).show()
				else
					$(ajForm.formElement).find('.ajForm-'+field.name).hide()
			else
				if field.conditionals.display is 'show'
					$(ajForm.formElement).find('.ajForm-'+field.name).hide()
				else
					$(ajForm.formElement).find('.ajForm-'+field.name).show()
				
				
	ajForm.findFieldElement=(name)->
		element = $(ajForm.formElement).find "input[name='#{name}']"
		element = $(ajForm.formElement).find "select[name='#{name}']" if element.length is 0
		element

	ajForm.getFieldOption = (fieldName)->
		fieldObj = {}
		forEach = (fields)->
			_.each fields, (field, name)->
				if name is fieldName
					fieldObj = field
				else if field.fields
					forEach field.fields
			fieldObj

		forEach ajForm.options.fields



		