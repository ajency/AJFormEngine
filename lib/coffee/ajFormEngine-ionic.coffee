#Changes needed for ionic apps

jQuery(document).ready ($)->

	ajForm.get_submit_button=->
		'<div class="list list-inset">
			<button class="button button-block btn-primary" type="submit">
				Save
			</button>
		</div>'

	ajForm.get_textbox=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		value = if field.value then field.value else ''
		"<label class='item item-input'>
			<input value='#{value}' type='text' #{ajForm.validations(field.validation)} #{ajForm.attributes(field.attributes)} class='form-control input-sm' name=#{name}>
		</label>"

	ajForm.get_dropdown=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = '<label class="item item-input item-select">'
		html += '<select '+ajForm.validations(field.validation)+' '+ajForm.attributes(field.attributes)+' name="'+name+'" class="form-control">'
		selectLabel = if _.has(field, 'selectLabel') then field.selectLabel else 'Select'
		html += '<option value="">'+selectLabel+'</option>'
		_.each field.options, (option)=>
			opt = ajForm.formatOptions option
			html += '<option value="'+opt.value+'" '+ajForm.preSelected(field, option)+'>'+opt.label+'</option>'
		html += '</select>'
		html += '</label>'

	ajForm.get_radio=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = ''
		_.each field.options, (option)->
			opt = ajForm.formatOptions option
			html += '<label class="item item-radio">
					<input '+ajForm.validations(field.validation)+' type="radio" name="'+name+'" value="'+opt.value+'" '+ajForm.preSelected(field, option)+' '+ajForm.attributes(field.attributes)+'>
					<div class="item-content">'+opt.label+'</div>
					<i class="radio-icon ion-checkmark"></i>
					</label>'
		html

	ajForm.get_checkbox=(field,name,secondaryName)->
		name = "#{secondaryName}[#{name}]" if secondaryName
		html = ''
		_.each field.options, (option)->
			opt = ajForm.formatOptions option
			html += '<label class="checkbox">
						<input '+ajForm.validations(field.validation)+' type="checkbox" name="'+name+'" value="'+opt.value+'" '+ajForm.preSelected(field, option)+' '+ajForm.attributes(field.attributes)+'>
						'+opt.label+'
					</label>'
		html

	ajForm.triggerFieldPlugins=(element)->
		ajForm.addDatePicker element
		ajForm.addAutoSuggest element
		ajForm.setAutogrowTextHeight element
		ajForm.addMultiselectDropdown element
		# $(element).find('.richtext').wysihtml5()
		ajForm.addGeoSearch element
		ajForm.bindButtonEvents element


