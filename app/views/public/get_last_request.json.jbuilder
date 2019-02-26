
json.customer_email @user.email
json.total_requests @user.requests.count
if @request.present?
  json.request do
    json.first_name @request.first_name
    json.last_name @request.last_name
    json.email @request.user.email
    json.is_first_time @request.is_first_time
    json.gender @request.gender
    json.position @request.position
    json.description @request.description
    json.has_color @request.has_color
  end
  json.stats "Updated #{time_ago_in_words(@request.updated_at)} ago"
end
