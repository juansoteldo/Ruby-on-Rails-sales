# frozen_string_literal: true

module CTD
    URL_HOST = Rails.env.production? ? 'api.customtattoodesign.ca' : 'ctd-worklist.dev'
    CHROME_EXTENSION_URL = 'https://sdk.customtattoodesign.ca/chrome_extension.zip'
end
