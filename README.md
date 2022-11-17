## Initial Setup

### Development
1. Generate an access token for Shopify OAuth. Go to `https://ctd-sales.ngrok.io/admin/shopify_auth`
2. Run `rake shopify:update_all_data`
3. Update Campaign Monitor smart IDs for auto quote emails
### Testing
1. Run `RAILS_ENV=test rake db:migrate`
2. Run `RAILS_ENV=test rails c`
3. Run `AppConfig.set_shopify_session(ACCESS_TOKEN)`
4. Run `TransactionalEmail.create(name: 'test', smart_id: '824efb69-c442-423c-a674-1b5d51a713c3')`
5. Run `RAILS_ENV=test rake shopify:update_all_data`

## Occasional Tasks

Run these rake tasks on first deployment/whenever any changes are made to the Shopify store products/variants.\
`bundle exec rake shopify:update_products_and_variants`\
`bundle exec rake shopify:update_tattoo_sizes`
