# frozen_string_literal: true

module CTD
  APP_HOST = ENV.fetch("APP_HOST", "api.customtattoodesign.ca")
  APP_URL = ENV.fetch("APP_URL", "https://api.customattoodesign.ca")
  CRM_URL = ENV.fetch "CRM_URL", "https://crm.customtattoodesign.ca"
  CHROME_EXTENSION_URL = 'https://sdk.customtattoodesign.ca/chrome_extension.zip'
  MIN_DATE = "2016-06-01T00:00:00-00:00".to_time
end
