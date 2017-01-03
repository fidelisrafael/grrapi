## Grrapi docs

---

## Features

Please, refer to ["What's included"](./whats_included.md) for a more deeper overview of features, below only the main points highlighted.

### The tech stack

in a nutshell, this projects rely on:

* Ruby >= 2 *_as perfect language_*
* PostgreSQL *_as incridble database_*
* Ruby on Rails *_as base application container_*
* Grape framework *_as http request-response framework_*
* Swagger _as developer API documentation_
* NiftyServices *_as SOA oriented layer_*
* Active Model Serializer _as handyman objects serializers for responses_
* Carrierwave [optional] *_as file uploader_*
* Capistrano *_for simple deployment_*
* Puma *_as application server_*
* Sidekiq *_as background jobber_*
* Redis *_as backend database for sidekiq and others small stuff_*
* Memcached *_as blazing fast cache backend_*
* Factory Girl _as test data creation_
* Rspec _as BDD test framework_
* Paranoia _as soft delete integration_
* Piet _as image optimizer_
* Rollbar _as application error tracker_

### Account Management

* User Registration (system and social signup)
  * Allow to force account confirmation through email to enable login 
* User auth (system and social login)
* User password management (forgot password, reset password)

#### Social Integrations for auth

Currently theses social integrations are supported:

* Facebook
* Google Plus

More detailed documentation of **Auth & Session** in our Wiki [**Authorization**](./whats_included-auth.md).


### Codebase organization

A well defined project structure to allow a very modular and reusable codebase. Cames with default endpoints versioning forcing developers to follow strict rules, giving more flexibility and speed when developing news features without breaking the dependending applications.

You can read more detailed explanation [**here**](./whats_included-code-organization.md).

### Configuration

Control your application using a centralized configuration API.

More detailed explanation and samples in our [**Configurations wiki**](./whats_included-configurations.md)

### Rake Tasks

Rake tasks to see application routes or to deploy to heroku.

More detailed explanation [**here**](./whats_included-rake-tasks.md)


### Deployment

Quickly Deploy to **Heroku** or private cloud server of your choice. (such AWS, Digital Ocean or Softlayer)

To learn more about deployment see [**Deployment**](./whats_included-deployment.md)


### Sidekiq

Your API project must respond fast as possible, this is way we use **Sidekiq**. Sidekiq is an great tool to process things in background (async processing).

You can read more about [**Sidekiq here**](./whats_included-sidekiq.md)

---

### Next

See [How to use e configure](./howto.md)