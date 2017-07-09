MarketingEmail.create( state: 'fresh,quoted', days_after_state_change: 1,
                       from: 'Lee Roller <leeroller@customtattoodesign.ca>',
                       subject_line: 'Lee Roller Custom Tattoo Design/Owner',
                       template_name: '24_hour_reminder_email', template_path: 'box_mailer/lead_reminders' )

MarketingEmail.create( state: 'fresh,quoted', days_after_state_change: 7,
                       from: '"Brittany Greenhill" <brittany@customtattoodesign.ca>',
                       subject_line: 'New amazing artists for you from Custom Tattoo Design',
                       template_name: '1_week_reminder_email', template_path: 'box_mailer/lead_reminders' )

MarketingEmail.create( state: 'fresh,quoted', days_after_state_change: 14,
                       from: 'Brittany Greenhill <brittany@customtattoodesign.ca>',
                       subject_line: 'Touching Base Brittany Custom Tattoo Design',
                       template_name: '2_week_reminder_email', template_path: 'box_mailer/lead_reminders' )


MarketingEmail.create( state: 'deposited,completed', days_after_state_change: 2,
                       from: 'Kayla McKee <kaylamckee@customtattoodesign.ca>',
                       subject_line: 'Creating The Best Tattoo with Custom Tattoo Design',
                       template_name: '48_hour_follow_up_email', template_path: 'box_mailer/customer_follow_ups' )

MarketingEmail.create( state: 'deposited,completed', days_after_state_change: 14,
                       from: 'Kayla McKee <kaylamckee@customtattoodesign.ca>',
                       subject_line: 'How Is Your Experience with Custom Tattoo Design?',
                       template_name: '2_week_follow_up_email', template_path: 'box_mailer/customer_follow_ups' )