jQuery(document).ready ($)->
	
	formbuilderOptions = 
		columns : 2
		submitUrl: '' 
		fields:					
			role: 
				type	: 'dropdown'
				options	: ['lead', 'user']
				default: 'user'
				validation: required: true

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
				default: 'female'

			mood:
				type: 'checkbox'
				options: ['happy', 'sad', 'angry']
				default: 'angry'

			business_type:
				type	: 'dropdown'
				options : ['pvt_individual','partnership','sole_trader','plc']

			pvt_individual:
				type: 'section',
				conditionals:
					type: 'any'
					display: 'show'
					conditions: 
						business_type: 
							operator: '='
							value	: 'pvt_individual'

				fields:
					first_name	: type	: 'textbox'
					last_name	:  type	: 'textbox'
					email		: 
						type	: 'textbox'
						validation: type: 'email'

					phone		: type	: 'textbox'

			partnership:
				type: 'section',
				conditionals:
					type: 'all'
					display: 'show'
					conditions: 
						business_type: 
							operator: '='
							value	: 'partnership'
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

			sole_trader:
				columns: 3
				type: 'section',
				conditionals:
					type: 'any'
					display: 'show'
					conditions: 
						business_type: 
							operator: '='
							value	: 'sole_trader'
				fields:
					first_name	: type	: 'textbox'
					last_name		: type	: 'textbox'
					email			: type	: 'textbox', validation: type: 'email'
					business_name	: type	: 'textbox'
					phone			: type	: 'textbox'

			pvt_ltd_company:
				columns: 4
				type: 'section',
				conditionals:
					type: 'any'
					display: 'show'
					conditions: 
						business_type: 
							operator: '='
							value	: 'plc'
				fields:
					director:
						type: 'repeatable_section'
						fields:
							first_name	: type	: 'textbox'
							last_name	: type	: 'textbox'
							company		: type	: 'textbox'
							email		: type	: 'textbox', validation: type: 'email'
							phone		: type	: 'textbox'

				
			additional_info: 
				type	: 'richtext'
				
	$.AJFormEngine $('.form-div'), formbuilderOptions	
