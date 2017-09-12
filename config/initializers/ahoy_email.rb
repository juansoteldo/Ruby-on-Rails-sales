class EmailSubscriber
  def open(event)
    
  end

  def click(event)
    #event[:controller].ahoy.track "Email clicked", message_id: event[:message].id, url: event[:url]
  end
end