jQuery(document).ready ($)->
	
	formbuilderOptions = 
		columns : 2
		fields:					
			role: 
				type	: 'dropdown'
				options	: ['lead']
				validation: required: true

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
				type	: 'dropdown'
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
							status: 
								type	: 'autosuggest'
								optionsUrl: 'http://nicolasbize.com/magicsuggest/get_cities.php' 

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
