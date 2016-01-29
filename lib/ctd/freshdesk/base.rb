class CTD::FreshDesk::Base
  def initialize(source)
    @source = source
  end

  def new_client
    client = FreshdeskAPI::Client.new do |config|
      config.base_url = ENV['FRESHDESK_URL']
      config.username = ENV['FRESHDESK_USER']
      config.password = ENV['FRESHDESK_PASSWORD']
    end
    client
  end

  def method_missing(symbol, *args)
    @source.send(symbol, *args)
  end
end
