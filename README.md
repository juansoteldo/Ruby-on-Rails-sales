## Git Flow

1. Pull from develop branch
   - `git branch develop && git pull`
2. Create a feature branch
   - `git checkout -b <feature_branch_name>`
3. Work on feature branch until ready for staging
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
    - `git tag -a`
11. Merge main branch into develop
    - `git checkout develop`
    - `git merge --no-ff main`
12. Deploy main branch into production environmment
    - `git checkout main`
    - `git push heroku.production main -f`
