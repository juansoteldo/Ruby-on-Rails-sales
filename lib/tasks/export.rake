require 'task_helper'

namespace :export do
  
  desc "Export fresh marketing emails to CM list"
  task fresh_users_to_cm: :environment do

    username      = Rails.application.credentials.cm[:username]
    dev_list_id   = Rails.application.credentials.cm[:dev_list_id]
    prod_list_id  = Rails.application.credentials.cm[:prod_list_id]
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
      "Resubscribe": false,
      "ConsentToTrack": "Yes"
    }

    query = User.where('updated_at > ?', threshold_date)
      .where(marketing_opt_in: true)
      .includes(:requests)

    query.find_each.with_index do |u, index|
      body['EmailAddress'] = u.email
      body['Name'] = u.first_name.present? ? u.first_name : ''

      if u.requests.any?
        req = u.requests.first

        fields = [
          { 'Key': 'Identify As', 'Value': u.identifies_as.to_s },
          { 'Key': 'Style', 'Value': req.style.to_s },
          { 'Key': 'Size', 'Value': req.size.to_s },
          { 'Key': 'BodyPosition', 'Value': req.position.to_s },
          { 'Key': 'Purchased', 'Value': TaskHelper.yesno(req.deposit_order_id) }
        ]

        fields << { 'Key': 'First Tattoo', 'Value': TaskHelper.yesno(req.is_first_time) } unless req.is_first_time.nil?
        fields << { 'Key': 'Colour', 'Value': TaskHelper.yesno(req.has_color) } unless req.has_color.nil?
        fields << { 'Key': 'Coverup', 'Value': TaskHelper.yesno(req.has_cover_up) } unless req.has_cover_up.nil?

        body['CustomFields'] = fields
      end

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