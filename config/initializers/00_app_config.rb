# frozen_string_literal: true

module CTD
  URL_HOST = Rails.env.production? ? 'api.customtattoodesign.ca' : 'localhost:3001'
  CHROME_EXTENSION_URL = 'https://sdk.customtattoodesign.ca/chrome_extension.zip'
end
