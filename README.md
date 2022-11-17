## Git Flow

1. Pull from develop branch
   - `git checkout develop && git pull`
2. Create a feature branch
   - `git checkout -b <feature_branch_name>`
3. Work on feature branch until ready for deployment on staging environment
4. Create a release branch
   - `git checkout -b release-<version_number>`
5. Merge feature branch into release branch
   - `git merge --no-ff <feature_branch_name>`
6. Update CHANGELOG.MD and package.json
7. Deploy release branch into staging environment for testing
    - `git push heroku.staging <release_branch_name>:main -f`
8. Test on staging environment until ready for production
9. Merge release branch into main branch
    - `git checkout main`
    - `git merge --no-ff <release_branch_name>`
10. Add a git tag
    - `git tag -a <version_number>`
11. Merge main branch into develop
    - `git checkout develop`
    - `git merge --no-ff main`
12. Deploy main branch into production environmment
    - `git checkout main`
    - `git push heroku.production main -f`

## Occasional Tasks

Run these rake tasks on first deployment/whenever any changes are made to the Shopify store products/variants.

`bundle exec rake shopify:update_products_and_variants`

`bundle exec rake shopify:update_tattoo_sizes`

## Initial Setup

### Development
1. Generate an access token for Shopify OAuth. Go to `https://ctd-sales.ngrok.io/admin/shopify_auth`
2. Run `rake shopify:update_all_data`
### Testing
1. Run `RAILS_ENV=test rails c`
2. Run `AppConfig.set_shopify_session(ACCESS_TOKEN)`
3. Run `TransactionalEmail.create(name: 'test', smart_id: '24efb69-c442-423c-a674-1b5d51a713c3'`
4. Run `RAILS_ENV=test rake shopify:update_all_data`