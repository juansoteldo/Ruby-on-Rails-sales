## Testing

Before you can run the app in a testing environment, you need to first get a Shopify access token to set up OAuth.

To do this, you have to run the app in development first and generate the access token. 

Access tokens that are generated in the development environment can also be used in the testing environment.

1. `RAILS_ENV=test rails c`
2. `AppConfig.set_shopify_session(ACCESS_TOKEN)`
3. `TransactionalEmail.create(name: 'test', smart_id: '24efb69-c442-423c-a674-1b5d51a713c3'`
3. `RAILS_ENV=test rake shopify:update_all_data`
4. `rake test`