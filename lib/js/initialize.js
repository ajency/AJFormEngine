jQuery(document).ready(function($) {
  var formbuilderOptions;
  formbuilderOptions = {
    columns: 2,
    fields: {
      role: {
        type: 'dropdown',
        options: ['lead'],
        validation: {
          required: true
        }
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
              value: 'test'
            },
            status: {
              operator: '=',
              value: 'suspended'
            }
          }
        }
      },
      status: {
        type: 'dropdown',
        options: ['active', 'suspended']
      },
      primary_advisor: {
        type: 'autosuggest',
        options: ['Network Manager', 'Firm Principal', 'Firm Management', 'Network Firm', 'Simply Firm', 'Phoenix', 'Network Manager2']
      },
      business_type: {
        type: 'dropdown',
        options: ['pvt_individual', 'partnership', 'sole_trader', 'plc']
      },
      pvt_individual: {
        type: 'section',
        conditionals: {
          type: 'any',
          display: 'show',
          conditions: {
            business_type: {
              operator: '=',
              value: 'pvt_individual'
            }
          }
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
          type: 'all',
          display: 'show',
          conditions: {
            business_type: {
              operator: '=',
              value: 'partnership'
            },
            status: {
              operator: '=',
              value: 'active'
            }
          }
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
              }
            }
          }
        }
      },
      sole_trader: {
        columns: 3,
        type: 'section',
        conditionals: {
          type: 'any',
          display: 'show',
          conditions: {
            business_type: {
              operator: '=',
              value: 'sole_trader'
            }
          }
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
          type: 'any',
          display: 'show',
          conditions: {
            business_type: {
              operator: '=',
              value: 'plc'
            }
          }
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
      lead_info: {
        type: 'section',
        columns: 3,
        fields: {
          recieved_date: {
            type: 'date'
          },
          lead_status: {
            type: 'textbox'
          },
          lead_source: {
            type: 'textbox'
          }
        }
      },
      referral: {
        type: 'section',
        columns: 3,
        fields: {
          referral_name: {
            type: 'textbox'
          },
          type: {
            type: 'textbox'
          }
        }
      }
    }
  };
  return $.AJFormEngine($('.form-div'), formbuilderOptions);
});
