# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: [:show]

  # To test:
  # /events/create?assigned_to=CTD%20Sales&event_type_uuid=HECE4MVOPUJJBV7R
  #   &event_type_name=Tattoo%20Consulatation&event_start_time=2019-03-06T14:00:00-05:00
  #   &event_end_time=2019-03-06T14:15:00-05:00&invitee_uuid=GDB2G722G65N5PKI&invitee_first_name=John
  #   &invitee_last_name=Smith&invitee_email=john%40example.com&answer_1=%2B14165551212&answer_2=WhatsApp

  def create
    @event = Event.from_params(event_params)
    authorize @event
    @event.save!

    redirect_to event_path(@event.uuid)
  end

  def show
    authorize @event
  end

  private

  def set_event
    @event = Event.find_by_uuid!(params[:id])&.decorate
  end

  def event_params
    params.permit(:assigned_to, :event_type_uuid, :event_type_name, :event_start_time, :event_end_time,
                  :invitee_uuid, :invitee_first_name, :invitee_last_name, :invitee_email, :answer_1, :answer_2).to_h
  end
end
