class CTD::FreshDesk::Ticket < CTD::FreshDesk::Base

  def self.freshdesk_tickets(email)
    Rails.cache.fetch(expires_in: 1.minutes) do
      client = Freshdesk.new("http://customtattoodesign.freshdesk.com/", ENV['FRESHDESK_API_KEY'])
      FreshDesk::Product.find(:all)
    end
  end
end
