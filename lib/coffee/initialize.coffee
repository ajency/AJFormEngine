jQuery(document).ready ($)->

	# window.WP_API_NONCE = ''

	# $(@).on 'aj:form:initialized', (event, data)->
	# 	console.log 'aj:form:initialized'

	# $(@).on 'aj:form:section:added', (event, data)->
	# 	console.log 'aj:form:section:added'

	$(@).on 'aj:form:submitted', (event, data)->
		console.log 'aj:form:submitted'
		console.log JSON.stringify data

	# $(@).on 'aj:form:ajax:before:submit', (event, data)->
	# 	console.log 'aj:form:ajax:before:submit'

	# $(@).on 'aj:form:ajax:submit:complete', (e, xhr)->
	# 	console.log 'aj:form:ajax:submit:complete'
	# 	xhr
	# 		.done (response)->
	# 			console.log 'SUBMIT RESPONSE'
	# 			console.log response
	# 		.fail (error)->
	# 			console.log 'SUBMIT ERROR'
	# 			console.log error


	#Button event
	$(@).on '$on:do:something', (event, data)->
		console.log '$on:do:something'


	
	formbuilderOptions = 
		columns : 2
		submitUrl: '' 
		# nav:true
		mode: 'view'
		# displayEmpty: false #True by default
		fields:					
			role: 
				type	: 'dropdown'
				options	: 
					[{value: 'pvt_individual', label: 'Private Individual'}
					{value: 'plc', label: 'Private Limited Company'}
					]
				default: 'plc'
				validation: required: true
				link: url: 'http://www.google.com/', openNew: true #True by default

			role1: 
				type: 'dropdown'
				options: ['a', 'b']
				default: 'b'

			buy_items:
				type: 'multiselect_dropdown'
				options: ['cheese', 'tomatoes', 'mozarella', 'mushrooms']

			personal_details:
				type: 'section'
				fields:
					textarea:
						type: 'textarea'
						# attributes: ['disabled']

					random_label:
						type: 'label'
						html: 'Some random label' #Plain text
						# html: '<p><b>Some random text</b></p>' #Html

					hidden_field:
						type: 'hidden'

					# do_something:
					# 	type: 'button'
					# 	triggerClick: '$on:do:something'

					dob:
						type: 'date'
						label: 'date of birth'
						min: '2015/03/05'
						max: 'today'

					text1: 
						type	: 'textbox'
						# validation: required: true

					text2: 
						type	: 'textbox'
						conditionals:
							type: 'all'
							display: 'show'
							conditions: 
								text1: 
									operator: 'like'
									value	: 'one'
								status: 
									operator: '='
									value	: 'active'

					status: 
						type	: 'autosuggest'
						options	: ['active','suspended']
			
			other_details:
				type: 'section'
				fields:
					primary_advisor: 
						type	: 'autosuggest'
						validation: required: true
						options : ['Network Manager','Firm Principal','Firm Management','Network Firm','Simply Firm','Phoenix','Network Manager2']

				cities: 
					type	: 'autosuggest'
					optionsUrl: 'http://nicolasbize.com/magicsuggest/get_cities.php'

				gender:
					type	: 'radio'
					options : ['male','female']
					default: 'male'

				mood:
					type: 'checkbox'
					options: ['happy', 'sad', 'angry', 'pissed', 'mad']
					# options	: 
					# 	[{value: 'happy', label: 'Happy'}
					# 	{value: 'sad', label: 'Sad'}
					# 	{value: 'angry', label: 'Angry'}
					# 	{value: 'pissed', label: 'Pissed'}
					# 	{value: 'mad', label: 'Mad'}
					# 	]
					default: ['angry', 'sad', 'mad']

			business_type:
				type	: 'dropdown'
				options : ['pvt_individual','partnership','sole_trader','plc']
				selectLabel: 'Select the business type'
				link: url: 'http://www.google.com/'

			pvt_individual:
				type: 'section',
				conditionals: business_type : 'pvt_individual'

				fields:
					first_name	: type	: 'textbox'
					last_name	:  type	: 'textbox'
					email		: 
						type	: 'textbox'
						validation: type: 'email'

					phone		: type	: 'textbox'
					company:
						type: 'dropdown'
						options: ['live', 'dead']
						default: 'dead'


			partnership:
				type: 'section',
				conditionals: business_type : 'partnership'
				fields:
					first_name		: type	: 'textbox'
					last_name		: type	: 'textbox'
					business_name	: type	: 'textbox'
					email			: type	: 'textbox',validation: type: 'email'
					phone			: type	: 'textbox'
					status: 
						type	: 'autosuggest'
						options	: ['active1','suspended1']
					partner	:
						type : 'repeatable_section'
						fields:
							first_name	: type	: 'textbox'
							last_name		: type	: 'textbox'
							business_name	: type	: 'textbox'
							email			: type	: 'textbox',validation: type: 'email'
							phone			: type	: 'textbox'
							places: 
								type	: 'autosuggest'
								optionsUrl: 'http://nicolasbize.com/magicsuggest/get_cities.php'
							start_date: 
								type  : 'date'
								min: '2015/03/10'
								max: '2015/03/20'
							buy_items:
								type: 'multiselect_dropdown'
								options: ['cheese', 'tomatoes', 'mozarella', 'mushrooms']
							company:
								type: 'dropdown'
								options: ['live', 'dead']
								default: 'dead'

			sole_trader:
				columns: 3
				type: 'section',
				conditionals: business_type: 'sole_trader'
				fields:
					first_name	: type	: 'textbox'
					last_name		: type	: 'textbox'
					email			: type	: 'textbox', validation: type: 'email'
					business_name	: type	: 'textbox'
					phone			: type	: 'textbox'

			pvt_ltd_company:
				columns: 4
				type: 'section',
				conditionals: business_type : 'plc'
				fields:
					director:
						type: 'repeatable_section'
						fields:
							first_name	: type	: 'textbox'
							last_name	: type	: 'textbox'
							company		: type	: 'textbox'
							email		: type	: 'textbox', validation: type: 'email'
							phone		: type	: 'textbox'

				
			# additional_info: 
			# 	type	: 'richtext'
			# 	attributes: ['disabled']
	
	# serializedData = {"role":"pvt_individual","role1":"a","buy_items":null,"personal_details":{"textarea":"Some text data","hidden_field":"","dob":"2015-04-16","text1":"Random text","status":""},"other_details":{"primary_advisor":""},"business_type":"pvt_individual","pvt_individual":{"first_name":"Deepak","last_name":"Prabhudesai","email":"deepak@ajency.in","phone":"654635644","company":"live"}}
	# serializedData = {"role":"pvt_individual","role1":"a","buy_items":null,"personal_details":{"textarea":"some text ","hidden_field":"","dob":"2015-04-02","text1":"Some randrom text","status":""},"other_details":{"primary_advisor":""},"business_type":"partnership","partnership":{"first_name":"wdwdwd","last_name":"wdwdwd","business_name":"wdwdwdw","email":"deepak@ajency.in","phone":"242424","status":"","partner":{"akJp7":{"first_name":"wdewdw","last_name":"wdwdw","business_name":"wdwdw","email":"deepak@ajency.in","phone":"223232","places":"","start_date":"2015-03-16","buy_items":null,"company":"live"}}}}
	serializedData = {"role":"pvt_individual","role1":"a","buy_items":null,"personal_details":{"textarea":"some text ","hidden_field":"","dob":"2015-04-16","text1":"Some randrom text","status":""},"other_details":{"primary_advisor":""},"business_type":"partnership","partnership":{"first_name":"wdwdwd","last_name":"wdwdwd","business_name":"wdwdwdw","email":"deepak@ajency.in","phone":"242424","status":"","partner":{"akJp7":{"first_name":"wdewdw","last_name":"wdwdw","business_name":"wdwdw","email":"deepak@ajency.in","phone":"223232","places":"","start_date":"2015-04-16","buy_items":null,"company":"live"},"357aX":{"first_name":"defde","last_name":"efefe","business_name":"efef","email":"dede@kefe.in","phone":"343434","places":"","start_date":"","buy_items":null,"company":"dead"}}}}
	$.AJFormEngine $('.form-div'), formbuilderOptions, serializedData



