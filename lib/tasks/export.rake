namespace :export do
  
  desc "Export fresh emails to CM list"
  task fresh_users_to_cm: :environment do

    username = Rails.application.credentials.cm[:username]
    list_id = '441e021df19eba26d01a093820471bba'
    
    url = "https://api.createsend.com/api/v3.2/subscribers/#{list_id}.json"

    basic_auth = {
      username: username,
      password: 'whatever'
    }

    headers = {
      'Content-Type': 'application/json'
    }

    body = {
      "Resubscribe": false,
      "ConsentToTrack": "Yes"
    }

    User.where('created_at > ?', 6.months.ago).where(marketing_opt_in: true).find_each do |u|
      body['EmailAddress'] = u.email
      body['Name'] = u.first_name.present? ? u.first_name : ''

      HTTParty.post(url, 
        body: body.to_json,
        headers: headers,
        basic_auth: basic_auth
      )
    end
  end

end