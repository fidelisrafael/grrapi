# Ruby API Starter Boilerplate

## About

The aim of this project is to enable **super fast & amazing architected development and deployment** of REST API projects using Ruby as server side language.
You can learn all the benefits RAS will give to you through this documentation. 

To be more cleaner, I was tired of moving along pieces of code through all new API project I started, so I decided to create a **minimal API starter boilerplate** for my projects, and this saved me **A LOT** of time. (And not only time, but wasted time, cuz I will need to develop again e again things that I've implemented before, so it's not super funny time, and this get worse when you don't have such too much time to spend configurating and doing things that you can automatized to get results faster).

##### If you want to see an quickly overview, please refer to [**"1 minute Overview"**](#1-minute-overview). 

---

## Table of Contents

* [About](#about)
* [1 minute overview](#1-minute-overview)
* [Acknowledgements](./docs/acknowledgements.md#acknowledgements)
  * [It's not a gem](./docs/acknowledgements.md#hi-im-not-a-gem)
  * [I'm not exactly a Rails project](./docs/acknowledgements.md#im-not-exactly-a-rails-project)
  * [I try to be secure](./docs/acknowledgements.md#i-try-to-secure-by-default)
  * [I'm production ready](./docs/acknowledgements.md#im-production-ready)
* [Features](./docs/features.md#features)
  * [The Tech Stack](./docs/features.md#the-tech-stack)
  * [Account Management](./docs/features.md#account-management)
    * [Social integrations](./docs/features.md#social-integrations-for-auth) 
  * [Codebase organization](./docs/features.md#codebase-organization)
  * [Deployment](./docs/features.md#deployment)
* [How to use](./docs/howto.md#how-to-use)
  * [Decide your project type](./docs/howto.md#decide-which-kind-of-project-you-need)
  * [Clone this repository](./docs/howto.md#clone-this-repository)
  * [Do the magic!](./docs/howto.md#init-your-rails-project)
* [Server Dependencies](./docs/server_dependencies.md#server-dependencies)
* [What's included in this starter project](./docs/whats_included.md)
  * [User Session Management](./docs/whats_included-auth.md#1---user-session-management)
    * [AngularJS front-end client](./docs/whats_included-auth.md#account-confirmation-and-password-reset-front-end-client)
      * [App Screenshots](./docs/whats_included-auth.md#app-screenshots)
  * [Project Organization (for real)](./docs/whats_included-code-organization.md#2---project-organization-for-real)
    * [Code versioning](./docs/whats_included-code-organization.md#code-versioning)
    * [Folder structures](./docs/whats_included-code-organization.md#folder-structures)
      * [Project Structure](./docs/whats_included-code-organization.md#project-structure)
    * [Configuration](./docs/whats_included-code-organization.md#configuration)
      * [Rack Middlewares](./docs/whats_included-code-organization.md#rack-middlewares)
      * [Rails Default Generators](./docs/whats_included-code-organization.md#rails-default-generators)
      * [CORS - Cross Origin Resource Sharing](./docs/whats_included-code-organization.md#cors)
      * [Routing setup](./docs/whats_included-code-organization.md#routing)
      * [Database seed](./docs/whats_included-code-organization.md#database-data-seeding)
      * [Path prefix & versioning](./docs/whats_included-code-organization.md#url-path-versioniong-and-prefix)
    * [Rake Tasks](./docs/whats_included-rake-tasks.md#rake-tasks)
      * [Route tasks](./docs/whats_included-rake-tasks.md#routes-tasks)
      * [Heroku deployment tasks](./docs/whats_included-rake-tasks.md#heroku-deployment-tasks) 
      * [Codebase statistics tasks](./docs/whats_included-rake-tasks.md#codebase-stats)
  * [Sidekiq](./docs/whats_included-sidekiq.md#3---sidekiq)
  * [Deployment](./docs/whats_included-deployment.md#4---deployment)
    * [Heroku](./docs/whats_included-deployment.md#option-1-deploy-your-application-to-heroku)
    * [Your IaaS - AWS, DO](./docs/whats_included-deployment.md#option-2-deploy-your-application-to-your-cloud-server-using-capistrano)
  * [Integrations](./docs/whats_included-integrations.md#5---out-of-box-integrations)
* [How it Works](#how-it-works)
* [Deeper Look](./docs/deeper_look.md)
* [Roadmap](#calendar-roadmap-)
* [Development](#computer-development)
* [Contributing](#thumbsup-contributing)
* [License - MIT](#memo-license)


---

## 1 minute overview

So ok, are you running of time as _a usual_ and you need to convice your brain that this project deserve the required attention. Fair enough. 

So to quickly sumarize: This projects is mounted as a Rails application, but uses [Grape](https://github.com/intridea/grape) as HTTP requests handling. The code is projected to be very modular and well versioned (and documented too). 

Just by using this template, you can save **weeks of work** from your team, this mean gaining a little more of chance to be on air soon, since the development process is acelerated by this pre defined application structure.

#### Current implemented features:

| feature | description |
|---------|-------------|
| :clipboard: organizated project | modular, standartized and versioned application codebase |
| :lock: system authentication | fully local/system(email/password) user registration and login |
| :white_check_mark: account validation  | forces users to confirm their email address before logging |
| :busts_in_silhouette: social authentication | social integrations for login and registrations. Currently supports Facebook and Google Plus |
| :envelope: forgot password | request password reset e-mail [configurable] |
| :key: password update | endpoint to update user password (with validations) |
| :x: delete account | hard or soft delete of user data |
| :construction: automated deployment | for heroku our cloud(such AWS, Digital Ocean) |
| :vertical_traffic_light: configurable environment | use system environment variables to ocnfigure sensitive application configurations |
| :computer: front-end client | use this [AngularJS project](https://github.com/fidelisrafael/ruby-api-starter-boilerplate-angularjs-client) as basic starter point for client applications |

Things exposed above are really time taking in most of projects, because almost every product have this same key necessities(eg: configuration, deployment) and features(such login, password management, registration). By using **Ruby API Starter (RAS)** you can save weeks of work with a very well structured base boilerplate for your projects by starting and deploying your application in matter of minutes.

Interested? Procced to [**Acknowledgements**](./docs/acknowledgements.md)

---

## How it Works

The project glues [all components](#the-tech-stack) together and delegate HTTP flow of request-response to **Grape**


```
user -> rack -> puma -> rails -> grape -> service -> serializer -> response
```

--

## :calendar: Roadmap <a name="roadmap"></a>

- :white_medium_small_square: Create demo application with Postman collection available

---

## :computer: Development


---

## :thumbsup: Contributing

Bug reports and pull requests are welcome on GitHub at http://github.com/fidelisrafael/ruby-rest-api-starter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

---

## :memo: License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).