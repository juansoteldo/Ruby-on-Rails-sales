# /events/create?assigned_to=CTD%20Sales&event_type_uuid=HECE4MVOPUJJBV7R
#   &event_type_name=Tattoo%20Consulatation&event_start_time=2019-03-06T14:00:00-05:00
#   &event_end_time=2019-03-06T14:15:00-05:00&invitee_uuid=GDB2G722G65N5PKI&invitee_first_name=John
#   &invitee_last_name=Smith&invitee_email=john%40example.com&answer_1=%2B14165551212&answer_2=WhatsApp
require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @existing_request = requests(:fresh)
    Event.where(request_id: @existing_request.id).delete_all
    start_time = Time.now + 1.day
    end_time = start_time + 15.minutes
    @event_params = {
      assigned_to: "CTD Sales",
      event_type_uuid: "HECE4MVOPUJJBV7R",
      event_type_name: "Tattoo Consultation",
      event_start_time: start_time,
      event_end_time: end_time,
      invitee_uuid: "GDB2G722G65N5PKI",
      invitee_first_name: "John",
      invitee_last_name: "Smith",
      invitee_email: @existing_request.user.email,
      answer_1: "+14165551212",
      answer_2: "WhatsApp"
    }
  end

  test "should create event" do
    get events_create_path(@event_params)
    assert_response :redirect
    new_uuid = @response.body.gsub(%r{^.+/([a-z0-9]{20,})".+$}, '\\1')
    new_event = Event.find_by_uuid(new_uuid)
    assert_not new_event.nil?
    assert_not new_event.request_id == @existing_request.id
    assert new_event.starts_at.to_i == @event_params[:event_start_time].to_i
    assert new_event.ends_at.to_i == @event_params[:event_end_time].to_i
  end
end
