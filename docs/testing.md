## Testing

Before you can run the app in a testing environment, you need to first get a Shopify access token to set up OAuth.

To do this, you have to run the app in development first and generat the access token. Access tokens that are generated in development can also be used in testing.

1. `RAILS_ENV=test rails c`
2. `AppConfig.set_shopify_session(ACCESS_TOKEN)`
3. `RAILS_ENV=test rake shopify:update_products_and_variants`
4. `rails test` or `rake test TEST=test/models/request_test.rb:86`