jQuery(document).ready(function($) {
  var formbuilderOptions;
  window.WP_API_NONCE = '';
  $(this).on('aj:form:initialized', function(event, data) {
    return console.log('aj:form:initialized');
  });
  $(this).on('aj:form:section:added', function(event, data) {
    return console.log('aj:form:section:added');
  });
  $(this).on('aj:form:submitted', function(event, data) {
    console.log('aj:form:submitted');
    return console.log(data);
  });
  $(this).on('$on:do:something', function(event, data) {
    return console.log('$on:do:something');
  });
  formbuilderOptions = {
    columns: 2,
    submitUrl: '',
    fields: {
      role: {
        type: 'dropdown',
        options: [
          {
            value: 'pvt_individual',
            label: 'Private Individual'
          }, {
            value: 'plc',
            label: 'Private Limited Company'
          }
        ],
        "default": 'plc'
      },
      role1: {
        type: 'dropdown',
        options: ['a', 'b'],
        "default": 'b'
      },
      buy_items: {
        type: 'multiselect_dropdown',
        options: ['cheese', 'tomatoes', 'mozarella', 'mushrooms']
      },
      textarea: {
        type: 'textarea',
        attributes: ['disabled']
      },
      random_label: {
        type: 'label',
        html: '<p><b>Some random text</b></p>'
      },
      hidden_field: {
        type: 'hidden'
      },
      do_something: {
        type: 'button',
        triggerClick: '$on:do:something'
      },
      dob: {
        type: 'date',
        label: 'date of birth',
        min: '2015/03/05',
        max: 'today'
      },
      text1: {
        type: 'textbox'
      },
      text2: {
        type: 'textbox',
        conditionals: {
          type: 'all',
          display: 'show',
          conditions: {
            text1: {
              operator: 'like',
              value: 'one'
            },
            status: {
              operator: '=',
              value: 'active'
            }
          }
        }
      },
      status: {
        type: 'autosuggest',
        options: ['active', 'suspended']
      },
      primary_advisor: {
        type: 'autosuggest',
        validation: {
          required: true
        },
        options: ['Network Manager', 'Firm Principal', 'Firm Management', 'Network Firm', 'Simply Firm', 'Phoenix', 'Network Manager2']
      },
      cities: {
        type: 'autosuggest',
        optionsUrl: 'http://nicolasbize.com/magicsuggest/get_cities.php'
      },
      gender: {
        type: 'radio',
        options: ['male', 'female'],
        "default": 'male'
      },
      mood: {
        type: 'checkbox',
        options: ['happy', 'sad', 'angry', 'pissed', 'mad'],
        "default": ['angry', 'sad', 'mad']
      },
      business_type: {
        type: 'dropdown',
        options: ['pvt_individual', 'partnership', 'sole_trader', 'plc'],
        selectLabel: 'Select the business type'
      },
      pvt_individual: {
        type: 'section',
        conditionals: {
          business_type: 'pvt_individual'
        },
        fields: {
          first_name: {
            type: 'textbox'
          },
          last_name: {
            type: 'textbox'
          },
          email: {
            type: 'textbox',
            validation: {
              type: 'email'
            }
          },
          phone: {
            type: 'textbox'
          }
        }
      },
      partnership: {
        type: 'section',
        conditionals: {
          business_type: 'partnership'
        },
        fields: {
          first_name: {
            type: 'textbox'
          },
          last_name: {
            type: 'textbox'
          },
          business_name: {
            type: 'textbox'
          },
          email: {
            type: 'textbox',
            validation: {
              type: 'email'
            }
          },
          phone: {
            type: 'textbox'
          },
          status: {
            type: 'autosuggest',
            options: ['active1', 'suspended1']
          },
          partner: {
            type: 'repeatable_section',
            fields: {
              first_name: {
                type: 'textbox'
              },
              last_name: {
                type: 'textbox'
              },
              business_name: {
                type: 'textbox'
              },
              email: {
                type: 'textbox',
                validation: {
                  type: 'email'
                }
              },
              phone: {
                type: 'textbox'
              },
              places: {
                type: 'autosuggest',
                optionsUrl: 'http://nicolasbize.com/magicsuggest/get_cities.php'
              },
              start_date: {
                type: 'date',
                min: '2015/03/10',
                max: '2015/03/20'
              },
              buy_items: {
                type: 'multiselect_dropdown',
                options: ['cheese', 'tomatoes', 'mozarella', 'mushrooms']
              }
            }
          }
        }
      },
      sole_trader: {
        columns: 3,
        type: 'section',
        conditionals: {
          business_type: 'sole_trader'
        },
        fields: {
          first_name: {
            type: 'textbox'
          },
          last_name: {
            type: 'textbox'
          },
          email: {
            type: 'textbox',
            validation: {
              type: 'email'
            }
          },
          business_name: {
            type: 'textbox'
          },
          phone: {
            type: 'textbox'
          }
        }
      },
      pvt_ltd_company: {
        columns: 4,
        type: 'section',
        conditionals: {
          business_type: 'plc'
        },
        fields: {
          director: {
            type: 'repeatable_section',
            fields: {
              first_name: {
                type: 'textbox'
              },
              last_name: {
                type: 'textbox'
              },
              company: {
                type: 'textbox'
              },
              email: {
                type: 'textbox',
                validation: {
                  type: 'email'
                }
              },
              phone: {
                type: 'textbox'
              }
            }
          }
        }
      },
      additional_info: {
        type: 'richtext',
        attributes: ['disabled']
      }
    }
  };
  return $.AJFormEngine($('.form-div'), formbuilderOptions);
});
