jQuery(document).ready ($)->

	# $(@).on 'aj:form:initialized', (event, data)->
	# 	console.log 'aj:form:initialized'

	# $(@).on 'aj:form:section:added', (event, data)->
	# 	console.log 'aj:form:section:added'

	$(@).on 'aj:form:submitted', (event, data)->
		console.log 'aj:form:submitted'
		console.log data
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
		# mode: 'view'
		# displayEmpty: false #True by default
		cancelButton: 
			display: true
			link: 'http://www.google.com/'
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

			# buy_items:
			# 	type: 'multiselect_dropdown'
			# 	# options	: 
			# 	# 	[{value: 'pvt_individual', label: 'Private Individual'}
			# 	# 	{value: 'plc', label: 'Private Limited Company'}
			# 	# 	]
			# 	# default: ['plc']
			# 	options : ['private individual', 'private limited company']
			# 	default: ['private limited company']

			buy_items:
				type: 'multiselect_dropdown'
				options: ['cheese', 'tomatoes', 'mozarella', 'mushrooms']
				default: ['mozarella']

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
						validation: required: true

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
						# optionsUrl: 'http://awmphoenixtest.com/api/v1/phoenix-users?filters[autosuggest]=1&filters[capability]=advisor'

					gender:
						type	: 'radio'
						options : ['male', 'female', 'bot']
						default: 'bot'

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
								default: ['mozarella']
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
	
	
	
	# serializedData = {"role":"plc","role1":"b","buy_items":["pvt_individual"],"personal_details":{"textarea":"Hello, this is a textarea","hidden_field":"","dob":"2015-04-20","text1":"This is text 1","status":"[{\"id\":\"suspended\",\"name\":\"Suspended\"}]"},"other_details":{"primary_advisor":"[{\"id\":\"Firm Principal\",\"name\":\"Firm Principal\"},{\"id\":\"Network Firm\",\"name\":\"Network Firm\"}]","cities":"[{\"id\":1,\"name\":\"New York\"},{\"id\":2,\"name\":\"Gotham\"}]","gender":"female","mood":true},"business_type":"partnership","partnership":{"first_name":"Deepak","last_name":"Prabhudesai","business_name":"test business","email":"deepak@ajency.in","phone":"54546664656464","status":"[\"suspended1\"]","partner":{"nkBjD":{"first_name":"Again Deepak","last_name":"Again Prabhudesai","business_name":"test business","email":"deepak@ajency.in","phone":"894564666","places":"","start_date":"2015-04-20","buy_items":["tomatoes","mushrooms"],"company":"dead"}}}}
	serializedData = {"role":"plc","role1":"b","buy_items":["tomatoes","mozarella"],"personal_details":{"textarea":"","hidden_field":"","dob":"","text1":"","status":""},"other_details":{"primary_advisor":"","cities":"","gender":"bot","mood":true},"business_type":"partnership","partnership":{"first_name":"","last_name":"","business_name":"","email":"","phone":"","status":"","partner":{"0":{"first_name":"","last_name":"","business_name":"","email":"","phone":"","places":"","start_date":"","buy_items":["tomatoes","mozarella","mushrooms"],"company":""}}}}
	
	console.log serializedData = eval(serializedData)

	$.AJFormEngine $('.form-div'), formbuilderOptions #, serializedData



