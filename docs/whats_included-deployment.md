## Grapi documentation

---

### Deployment

This project force the developer to start from the beginning thinking in staging and production environment for deploy. See below the deployment options that RAS gives to you:

#### Option 1: Deploy your application to Heroku

This is super handy, your can deploy per enviroment simple running a `rake task`:

| env | command |
| --------------| ------------|
| **staging** | `rake heroku:staging:deploy` |
| **production** | `rake heroku:production:deploy` |


Ok ok, take a breathe and before you start, configure your heroku remote git urls in `config/.heroku-deploy.yml`:

```
# config/.heroku-deploy.yml
staging:
  app_name: my-api-app-staging
  remote_name: heroku-stg
  branch_name: develop

production:
  app_name: my-api-app-production
  remote_name: heroku-prod
  branch_name: master
```

#### Tips
 
> Your default heroku git remote will be `origin`, but now you need a git remote **per environment**, so its good ideia to rename your `origin` to `heroku-prod`, you can do this running: `git remote rename origin heroku-prod`. 
To add a staging application, you can run: `git remote add heroku-stg YOUR_STAGING_HEROKU_REMOTE`
This is an example of a repository with configured git remotes: `git remote -v`

```
# output of `git remote -v`
heroku-prd  https://git.heroku.com/my-api-project.git (fetch)
heroku-prd  https://git.heroku.com/my-api-project.git (push)
heroku-stg  https://git.heroku.com/my-api-project-staging.git (fetch)
heroku-stg  https://git.heroku.com/my-api-project-staging.git (push)
```

---
#### Option 2: Deploy your application to your cloud server using capistrano

Maybe heroku is not your cup of tea - or it's just too much expensive :P -, or maybe you just want to run your application code in your [**cloud IaaS**](https://en.wikipedia.org/wiki/Cloud_computing) (*such AWS, Softlayer, Digital Ocean*) of choice, or even in your own infrastructure.
RAS trust on *capistrano* to deployment, the only things you need to do in your server is to install **all required dependencies**(such `pngoptimin`).

To deploy your awesome application to an environment, simple run:

```
# cap [enviroment] task
cap staging deploy
```

If is your **initial or first deploy**, it's a good pratice to run the following to deploy:

```
# cap enviroment task
cap staging safe_deploy_to:ensure
cap staging ssh:doctor
cap staging doctor

cap staging deploy:initial # sends code to server
cap deploy:upload_yml # upload YAML configuration files
cap staging puma:nginx_config # configure nginx as reverse proxy
```

#### Capistrano deploy configuration

But again, take a breathe and configure capistrano using the following files:

* `config/deploy.rb` -> Configure your `application` and `repo_url`.
* `config/deploy/staging.rb` -> Configure your staging servers 
* `config/deploy/production.rb` -> Configure your production servers 

Just as note, you can deploy **even without touching a single configuration line**, you can pass the configurations to capistrano **as environment variables** in system, or in running time:

```
SERVER_NAMES="staging.myawesomeapi.com" APP_IPS="191.250.112.118, 201.102.118.112"  DEPLOY_APP_NAME="my_api_project" GIT_REPO_URL=" git@bitbucket.org:fidelisrafael/my-awesome-api-project.git" cap staging deploy
```

<br />
##### Tips

> Make sure you configure rollbar(`rollbar_access_token` key in `config/application.yml`) with your rollbar private keys, this way capistrano can send deploy notifications to rollbar dashboard(and users get emailed after each deploy).

---

### Next

See [Out of the box integrations](./whats_included-integrations.md)