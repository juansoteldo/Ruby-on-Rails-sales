require 'task_helper'

namespace :export do
  
  desc "Export fresh marketing emails to CM list"
  task fresh_users_to_cm: :environment do

    creds         = Rails.application.credentials
    username      = creds.cm[:username]
    dev_list_id   = creds.cm[:dev_list_id]
    prod_list_id  = creds.cm[:prod_list_id]
    list_id       = Rails.env.development? ? dev_list_id : prod_list_id

    threshold_date = DateTime.parse '2020-11-20'
    url = "https://api.createsend.com/api/v3.2/subscribers/#{list_id}.json"

    basic_auth = {
      username: username,
      password: 'whatever'
    }

    headers = {
      'Content-Type': 'application/json'
    }

    body = {
      "Resubscribe": true,
      "ConsentToTrack": "Yes"
    }

    query = User.subscribed_to_marketing
      .where('updated_at > ?', threshold_date)
      .includes(:requests)

    query.find_each.with_index do |u, index|
      body['EmailAddress'] = u.email
      body['Name'] = u.first_name.present? ? u.first_name : ''
      body['CustomFields'] = u.cm_custom_fields

      HTTParty.post(url,
        basic_auth: basic_auth,
        headers: headers,
        body: body.to_json
      )
      print '.' if (index % 25).zero?
    end
    puts "\n"
  end

end