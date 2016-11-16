### Ruby API Starter Boilerplate

## About

The aim of this project is to enable **super fast & amazing architected development and deployment** of REST API projects using Ruby as server side language.
You can learn all the benefits RAS will give to you through this documentation. 

To be more cleaner, I was tired of moving along pieces of code through all new API project I started, so I decided to create a **minimal API starter boilerplate** for my projects, and this saved me **A LOT** of time. (And not only time, but wasted time, cuz I will need to develop again e again things that I've implemented before, so it's not super funny time, and this get worse when you don't have such too much time to spend configurating and doing things that you can automatized to get results faster).

##### If you want to see an quickly overview, please refer to [**"1 minute Overview"**](#1-Minute-Overview). 

---

## Table of Contents

* [About](#about)
* [1 minute overview](#1-minute-overview)
* [Acknowledgements](#acknowledgements)
  * [It's not a gem](#hi-im-not-a-gem)
  * [I'm not exactly a Rails project](#im-not-exactly-a-rails-project)
  * [I try to be secure](#i-try-to-secure-by-default)
  * [I'm production ready](#im-production-ready)
* [Features](#features)
  * [The Tech Stack](#the-tech-stack)
  * [Account Management](#account-management)
    * [Social integrations](#social-integrations-for-auth) 
  * [Codebase organization](#codebase-organization)
  * [Deployment](#deployment)
* [How to use](#how-to-use)
  * [Decide your project type](#decide-which-kind-of-project-you-need)
  * [Clone this repository](#clone-this-repository)
  * [Do the magic!](#init-your-rails-project)
  * [Server Dependencies](#server-dependencies)
* [What's included in this starter project](#whats-included)
  * [User Session Management](#1---user-session-management)
    * [AngularJS front-end client](#account-confirmation-and-password-reset-front-end-client)
      * [App Screenshots](#app-screenshots)
  * [Project Organization (for real)](#2---project-organization-for-real)
    * [Code versioning](#code-versioning)
    * [Folder structures](#folder-structures)
      * [Project Structure](#project-structure)
    * [Configuration](#configuration)
      * [Rack Middlewares](#rack-middlewares)
      * [Rails Default Generators](#rails-default-generators)
      * [CORS - Cross Origin Resource Sharing](#cors)
      * [Routing setup](#routing)
      * [Database seed](#database-data-seeding)
      * [Path prefix & versioning](#url-path-versioniong-and-prefix)
      * [Rake Tasks](#rake-tasks)
        * [Route tasks](#routes-tasks)
        * [Heroku deployment tasks](#heroku-deployment-tasks) 
        * [Codebase statistics tasks](#codebase-stats)
  * [Sidekiq](#3---sidekiq)
  * [Deployment](#4---deployment)
    * [Heroku](#option-1-deploy-your-application-to-heroku)
    * [Your IaaS - AWS, DO](#option-2-deploy-your-application-to-your-cloud-server-using-capistrano)
  * [Integrations](#5---out-of-box-integrations)
  * [How it Works](#how-it-works)
  * [Deeper Look](#deeper-look)
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
| automated deployment :construction: | for heroku our cloud(such AWS, Digital Ocean) |
| :vertical_traffic_light: configurable environment | use system environment variables to ocnfigure sensitive application configurations |
| :computer: front-end client | use this [AngularJS project](#link) as basic starter point for client applications |

Things exposed above are really time taking in most of projects, because almost every product have this same key necessities(eg: configuration, deployment) and features(such login, password management, registration). By using **Ruby API Starter (RAS)** you can save weeks of work with a very well structured base boilerplate for your projects by starting and deploying your application in matter of minutes.

Interested? Procced to [**Acknowledgements**](#Acknowledgements)

---

## Acknowledgements

### Hi, I'm not a gem

You may think that this project delivered as a rubygems, but no, it's not. By this, I mean that **all source code is shipped direct to your application**, and not only "referenced" in your application as dependency in gem format. The most important thing in this is:  **You're owner of your source-code, not gem owners. Your application CORE code must be in project heart.**

Beside this, I think this give developers **freedom** to work, since it's much more easier to understand the relationship through the core codebase if core codebase is together and more accessible, different from dependeding of 200 rubygems without real necessity, this envolves studing infinites rubygems to understand a core concept and how is implemented. And of course, this keep your codebase standartized, since you dont rely on an infinite of "know god how is written" dependencies. 

I must say to you that all **Authentication and authorization** code is just a few lines of Ruby code. The integrations with **google plus and facebook** too, just plain old ruby code.

### I'm not exactly a Rails project

Note that this project is **mounted in a Rails application** to enable easy and quick development setup for following some of Rails pre-configured and integrated solutions(ActiveRecord, Cache, Configuration), but all **HTTP request-response** handling is managed by  **[Grape]((https://github.com/ruby-grape/grape))** and not by Rails default **[Action Controller](http://guides.rubyonrails.org/action_controller_overview.html)**

The heart of this project live in two mainly projects:

#### [Grape](https://github.com/ruby-grape/grape): 
> An opinionated framework for creating REST-like APIs in Ruby.

#### [Nifty Services](https://github.com/fidelisrafael/nifty_services)  
> The dead simple services object oriented layer for Ruby applications to give robustness and cohesion back to your code.

### I try to be secure

Leveraging the power of **Grape + NiftyServices** integration, this application forces the developers to write **safe** code, so if you do in the right way, your application will be secure by default. 

### I'm production ready

I've be using this boilerplate for years now (before this doing things manually), and I have a few of production tested applications running in this stack. I've improved this a lot through each application, so now its better than never! 
Beside this, I want to say that I got good feedbacks from all other people(coworkers in general) experiences working with this boilerplate. 

---

## Features

Please, refer to ["What's included"](#whats-included) for a more deeper overview of features, below only the main points highlighted.

#### The tech stack

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

#### Account Management

* User Registration (system and social signup)
  * Allow to force account confirmation through email to enable login 
* User auth (system and social login)
* User password management (forgot password, reset password)

#### Social Integrations for auth

Currently theses social integrations are supported:

* Facebook
* Google Plus

You can read mode detailed explation [**here**](#1---user-session-management).


### Codebase organization

A well defined project structure to allow a very modular and reusable codebase. Cames with default endpoints versioning forcing developers to follow strict rules, giving more flexibility and speed when developing news features without breaking the dependending applications.

You can read mode detailed explation [**here**](#2-Project-Organization-(for real).

### Deployment

Quickly Deploy to **Heroku** or private cloud server of your choice. (such AWS, Digital Ocean or Softlayer)

You can read mode detailed explation [**here**](#4-Deployment)

----


## How to use

First of all, you need to know that this option is better suitable for **new projects**, of course you can integrate it with your existing application, but this will need some manual work. With this said, let me introduce how simple is to start a new project with all boilerplate code up & running:

### Decide which kind of project you need

Well, first things, first! This template basically supports two generator modes:

| mode | description | recommendation |
| ---- | ----------- | -------------- |
| complete | all components are installted in your application; | most of cases (?)[data needed]
| minimal | only basic components are installed in your application | very minimal start point.

Below show the mainly differences between each mode:

#### Minimal:

* Account and Auth Management
* Configuration
* Rake Tasks
* Database and models setup (**3 total tables**):
  * Authorization `authorizations`
  * User `users`
  * Origin `origins`

#### Complete

Everything that existings in **Minimial**, plus:

* Database and models setup(**8 total tables**):
  * Address (`addresses` _Polymorphic association_ to enable addressing for resources)
  * UserDevice ( `user_devices` for push notifications delivery)
  * Notifications (`notifications` for storing system notifications)
  * State (`states` - With default seed data including all states for Brazil)
  * City (`cities`) With default seed data including all cities for Brazil)

---

### Clone this repository 

Now, just clone this repository to an acessible location in your workstation:

```
git clone git@github.com:fidelisrafael/ruby-api-starter-boilerplate.git
```

Keep in mind where you downloaded this repository, you will need the path in next step.


### Init your Rails project

After studing your application use cases, you've choosed one the template mode bettween `mininal` and `complete`(the default value), now lets create our Rails application.

To use _RAS_, you need to run your Rails project creation the command passing the the template URL option(`-m TEMPLATE_URL`) and `--ras-template-mode="mode"` which will tell the template what kind of setup to do. For example:

```
rails new myApiProject -m /path/to/ruby-api-starter-boilerplate/template.rb --ras-template-mode="complete" --skip-assets --skip-javascript 
```

For your API projects you must want to skip all `sprockets` handling passing `--skip-assets --skip-javascript` (*)

For Rails 5, you can use `--api` flag:

```
rails new myApiProject -m /path/to/ruby-api-starter-boilerplate/template.rb --api --ras-template-mode="complete"
```

**OBS**:  RAS(Ruby API Starter) take care of removing  sprockets middlewares from rack stack, this is important because your API must be always fast as possible, and removing this processement from response management is a big win).


**2 - Install dependencies**

```
cd myApiProject

bundle install
```

**3 - Configure your application**:

Open `config/application.yml` and see all the configurations, you may want to change some values to reflect better your enviroment.

You can read more detailed configuration documentation [here](#configuration).

**4 - Setup your database**

Configure `config/database.yml` and add your local postgres credentials:

```
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
``` 

**5 - Run the application**:

Just run: `bundle exec rails s -p 8080` and your REST API server will start running at `http://localhost:8080/api`

"Test" the installation: 
```
➔ curl -I "http://localhost:8080/api/v1/swagger_doc"
HTTP/1.1 200 OK
(...)
```

Simple as that.


### Server Dependencies

This is a reference list which required software and versions you may need to install in your server to properly run your application:

 - [ruby](https://rvm.io/ "RVM") __>= 2.0.0__
 - [grape](https://github.com/intridea/grape, "Grape") >= _0.12_
 - [nifty_services](https://github.com/fidelisrafael/nifty_services, "") >= _0.0.5_
 - [postgresql](http://www.postgresql.org/ "PostgreSQL") >= __9.2.0__
   - Extensions:
       - [hstore](http://www.postgresql.org/docs/9.1/static/hstore.html)
 - [redis](http://redis.io/, "Redis") >= _3.0.2_
 - [memcached](http://memcached.org/, "MemCached") >= _1.4.24_
 - [imagemagick](http://www.imagemagick.org/script/index.php, "ImageMagick") >= _6.9.1-5_
 - [optipng](http://optipng.sourceforge.net/) >= _0.7.5_
 - [pngquant](https://pngquant.org/) >= _2.0.1_
 - [jpegoptim](http://freecode.com/projects/jpegoptim) >= _1.4.2_
 - [bundle](http://bundler.io/ "Bundler") >= __1.10.0__

---

## What's included?

If you're curious about what is included in this sugar project, keep reading and prepare yourself for being amazed! See you in the next section.

---

### 1 - User Session Management

All included with in your project codebase, no gem dependency.

Just by using this project as your boilerplate template, you gain the following endpoints/features:

* **User registration**
  * With account confirmation through email [configurable] 
    * Includes endpoint for request a new confirmation mail delivery 
    * This endpoint its rate limited, meaning that each user(or a malicious bot) can only request a new mail delivery after X minutes (minutes configurable)
  * With pre formatted generic welcome mail 
  * With social login integration, currents support: 
    * **Facebook**
    * **Google Plus**
* **User password management**
  * Endpoint to ask for password reset mail.
    * With ore formatted generic mail delivery
    * With rate limit (Users can only ask for a new mail delivery after X minutes)  _[configurable]_ 
  * Endpoint to reset user password. (with token)
    * Each time user password is updated an notification mail is delivered to user account owner. _[needs to configurable]_ 
* **User Auth**
  * With max simultaneous sessions limit per provider(ex: android or ios app) integration _(configurable)_
  * With account lock when user try to login multiples times. (max attempts and block period fully configurable) 
  * Endpoint to authenticate user through `identifier`(such email) and `password`
  * With social login integration, currents support: 
    * **Facebook**
    * **Google Plus** 
* Helper methods to be used inside routes
  * Example are `current_user` or `authenticate_user!` helper methods. 

This can save **weeks of development**, I'm really talking seriously.

I'm pretty sure you're thinking: "Man, this is perfect, cant be better", but you're wrong! Pay attention, now I'll save you from another week of work doing repeated stuff. See by yourself:

#### Account confirmation and password reset front-end client

As you can see below, you can configure if a user **necessarily needs to confirm their email address** before they can login on  your application - In other words, an email with an URL to confirm account will be delivered to user. Beside this actions, there's endpoints which clients can connect to request a new password mailer delivery, all this mean that you need a **responsive web front-end application** performing HTTP requests to integrate with your API .
For your happiness, you can have this in seconds, just clone ["AngularJS ruby-api-starter front-end client"]() and follow the README instructions. <br />

As you can see in the name of project, this frontend application is developed under **AngularJS**, so it's very easy to get started.
Just remember to configure the following keys in your `config/application.yml` file for each environment: <br />

```yaml
account_confirmation_url_site_url: "http://localhost:3001"
account_confirmation_url_format: "%{site_url}/%{slug}/%{token}"
account_confirmation_url_site_slug: "confirm-account"

password_update_url_site_url: "http://localhost:3001"
password_update_url_format: "%{site_url}/%{slug}/%{token}"
password_update_url_site_slug: "reset-password"
```
<br />

Now, you saved more a few days of work, good job! Keep reading....

##### App Screenshots

Bellow a simple screenshot of AngularJS application fully integrated with our API boilerplate responses:

##### Password reset integration

| screen | success | error |
|--------|---------|-------|
|![Password Reset](http://i.imgur.com/tlWNdXy.png) | ![Password successfully updated feedback](http://i.imgur.com/FiNZbk4.png)| ![Password error feedback](http://i.imgur.com/VYZnA6z.png) |

<br />
##### Account confirmation integration

| success | success | error |
|---------|---------|-------|
|![](http://i.imgur.com/svTmMuE.png) | ![Account confirmation](http://i.imgur.com/A5fTWoE.png)| ![Invalid token](http://i.imgur.com/KOxpY5N.png) |

---
<br />


#### 2 - Project Organization (for real)

Ok, I can try to convice you to use and contribute to this project with all things above or below this, but for me the main purpose of this api starter is to start in the right way, and be this you can understand: **the organizated way**.
This project structure is **prepared** to get bigger as your product grows, let me give you a better understading of what I talking about:

#### Code Versioning

From workers, to API endpoints, **everything in this project is versioned**, this mean not only versioning API endpoints, but the whole thing related to a version in an request process, such `helpers`, `services`, `workers` and `serializers`(responses). 
Versioning is too important that needs more than a simple line of explanation, this kind of architecture gives you possibilities to expand and grows your bussiness **without fucking with your current integrations**,such your own mobile clients, or partners integrations using your API.


**API Endpoints versioning:**

All your api endpoints must belongs to a version of your API, this mean that your API endpoints will look like this: `http://myawesomeapi.com/v1/posts/10`

With this said, all of your API versions must have a **base classe**, take a look in `api/base.rb`  and `api/v1/base.rb` as reference entry point.

**Sidekiq workers versioning**

All workers must be versioned inside `lib/workers` folder, eg: (`lib/workers/v2`)

**Services versioning**

All workers must be versioned inside `lib/services` folder, eg: (`lib/services/v2`)

**Serializers versioning**

All workers must be versioned inside `lib/serializers` folder, eg: (`lib/serializers/v2`).
See "Folder structures"(below) to better explanation on this subject.

#### Folder structures

When you start your projects, "its okay" to have multiples files in a single folder, you know...its not a problem for now....but when your codebase starts to get bigger and bigger(matter of weeks), your productive start to decrease, cuz now hurts to understand where things live at, cuz everything is a complete mess....Well, **forget about this**, I'm using this structure in all my projects and I can assure that this really works for me and my coworkers.

#### Project Structure 

This projects follows a common Rails application structure, but with some additions, below a quick overview with project structure removing the unecessary folders. 


```
.
├── app
│   ├── grape
│   │   └── api
│   │       ├── helpers
│   │       │   └── v1
│   │       └── v1
│   │           └── routes
│   ├── mailers
│   ├── models
│   │   └── concerns
│   │       └── user_concerns
│   ├── policies
│   ├── uploaders
│   └── views
│       ├── layouts
│       └── users_mailer
├── config
│   ├── app_config
│   ├── deploy
│   │   └── templates
│   │       ├── production
│   │       └── staging
├── lib
│   ├── serializers
│   │   └── v1
│   │       └── user
│   │       └── (...)
│   ├── services
│   │   └── v1
│   │       ├── auth
│   │       └── users
│   │       └── (..)
│   └── workers
│       └── v1
```

One picture can talk more than a million words, so see an example of **serializers folder** of a project I was working on:

![](http://i.imgur.com/0Rbfo0q.png)

As you can see, things are really organizated. If you pain attention, will notice that all this folder is inside another folder called  `v1`, and each `resource` have your own namespace to keep related serializers together. Beside this, **every and all** serializer **must have** an **simple** and a **full** version, but this is not a topic for now, you can read more about this in "Serializers conventions"(#linkaqui)

Now, take a look of how organizated and standartized is our **Services folder**:

![Organizated and versioned services folder](http://i.imgur.com/aplh7Q5.png)

Again, versioned and per resource specific folders, this keep your project SO organizated in all phases of development, from first release when you're such a small project to the days where you're the number one of your segment.

#### Configuration

RAS cames as a very configurable friendly application, we use [**Figaro**](https://github.com/laserlemon/figaro) to our app configuration through env variables.
This is considered a best pratice cuz pratically removes **hard coded** configuration lost in the middle of your codebase.
Take a look in **Configuration internals** to better understand all possible configurations.

For better integration with your rails project, RAS expect that your project is running **postgresql**, but of course, you can use with others databases, but take note of this things:

* Users preferences are stored in a [`hstore`](./template_files/migrations/20160807164036_add_preferences_to_user.rb) column  of postgres.
 - You will need to change this in [**this migration file**](./template_files/migrations/20160807164036_add_preferences_to_user.rb) to an equivalent column type in your database, if your database don't support JSON, please use `text` as column type.(But this will not enable you to perform efficients querys againts this data)

#### Rack Middlewares

**RAS** remove the following [middlewares](http://edgeguides.rubyonrails.org/api_app.html#choosing-middleware) from being processed by Rack in **each request**:

```ruby
ActionDispatch::Static # disable static file serving(such css,js)
ActionDispatch::Cookies # disable cookie handling (of course, this is responsibility of your clients)
ActionDispatch::Session::CookieStore # Again
ActionDispatch::Flash # Not necessarily to store flash messages in session
Rack::MethodOverride # No need to check request methdo using `_method` in params
```


#### Rails Default Generators

When you use any of Rails generators(such `rails generate resource Post`, by default things such `assets`, `views`, `stylesheets`, `javascript` are created by default, one behavior you dont want in your API project, right?. **RAS** configure your application **to skip generation** for theses kind of files. (since you're an API you *dont want* to serve static files)


#### CORS

**RAS** uses `rack-cors` to enable [Cross Origin Resource Sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing). You can configure which `Origin` and `Methods` are allowed in `config/application.yml`:

```
# Use this to determine CORS configuration
access_control_allowed_origins: "*"
access_control_allowed_request_methods: "*"
```

#### Routing

An route config will be appended to your `config/routes.rb` file,  sending all requests from `/`(root) to  `API::Base`. This is important because we're telling Rails to let `Grape` handle requests processment, and not [ActionController](http://guides.rubyonrails.org/action_controller_overview.html) as default.  
Additionally another route wil be setup to route to [Sidekiq UI interface](https://github.com/mperham/sidekiq/wiki/Monitoring#web-ui) at `/sidekiq` path.

#### Database data seeding

Most of time, **seed is the most freaking thing** in every project, it's just a mess of lines of code, with files, and nothing makes sense cause data is created directly via **model objects**, this can be a huge problem...since this **skip all ACL and bussiness logic implementation**....weird.
Trying to avoid this, theres a system service(actually `V1::System::CreateDefaultDataService`) which is responsible to create seed data (this service can call anothers services in a more cleaner way).

To seed your database, you will need to run something in this format:

```
# specific
ACTIONS="create_default_users, create_default_admin_users" bundle exec rake db:seed

# run all actions in `Services::V1::System::CreateDefaultDataService`
bundle exec rake db:seed
```

#### URL Path versioniong and prefix

By default, in **development enviroment** API endpoints gets prefixed with `namespace` + `version`, in the following schema:

```
# protocol://host:port/namespace/version/endpoint
http://localhost:8080/api/v1/posts/1
```

This is the default configuration inside `config/application.yml`:

```
# enable this to prefix all routes with prefix
prefix_api_path: "true"
# prefix add to ALL routes in application
# eg: /api/users/1
api_prefix_path: 'api'
```

But in **staging and production enviroments** the **namespace** is not appended(so `prefix_api_path: "false"`), because you _probably want_ to deploy your aplication to **an isolated server** and make it **reacheable through a subdomain**(such `api.mydomain.com`) or in a self dedicated domain(such: `myawesomeapi.com`), so your endpoints in staging and production will looks more like:

```
https://api.mybussinesswebsite.com/v1/auth/facebook
```


#### Rake Tasks

Being a grape-oriented application makes your `rake routes` command just listing an empty set of routes. (the ones this template made the setup)  
To fix this, this projects include one rake task to list all application routes:

##### Routes tasks

```
➔ rake api:routes DESCRIPTION=true

GET        /api/v1/swagger_doc(.:format)
GET        /api/v1/swagger_doc/:name(.:format)
POST       /api/v1/users(.json)
GET        /api/v1/users/check_email(.json)
POST       /api/v1/users/auth(.json)
POST       /api/v1/users/auth/token(.json)
DELETE     /api/v1/users/auth(.json)
POST       /api/v1/users/password_reset(.json)
PUT        /api/v1/users/password_reset/:token(.json)
POST       /api/v1/users/activate_account/:token(.json)
POST       /api/v1/users/resend_activation_mail(.json)
(...)
```

You can show the routes description by passing the `DESCRIPTION` ENV variable, such: 

```
➔ rake api:routes DESCRIPTION=true

>> Create a new user
     POST       /api/v1/users(.json)
>> Check if user with given mail exists
     GET        /api/v1/users/check_email(.json)
(...)
```

Or even list API endpoints grouped by method:
```
➔ rake api:routes GROUPED=true

POST       /api/v1/users/auth(.json)
POST       /api/v1/users/auth/token(.json)
POST       /api/v1/users/password_reset(.json)
POST       /api/v1/users/activate_account/:token(.json)
(...)
```

##### Heroku deployment tasks

You can deploy to multiples environments just running a rake task:

```
# rake heroku:enviroment:deploy
rake heroku:staging:deploy
```

When you run the command above, the code is deployed to heroku account, and after this environment variables are [configured in Heroku using Figaro gem](https://github.com/laserlemon/figaro#heroku) to reflect your config in `config/application.yml` for given enviroment.  
**OBS:** This command **not try to migrate the database**, if you need to run the database migration files after deploy, just use:

```
RUN_MIGRATIONS=true rake heroku:staging:deploy
```

**Forcing code updating in heroku git remote.**

**CAUTION**: This is a very destructive action that you should [never try to do in production](http://willi.am/blog/2014/08/12/the-dark-side-of-the-force-push/)....but just for your information, this can be done running the rake task with `FORCE=true rake heroku:staging:deploy`:


##### Codebase Stats

I like statistics, and probably you do too! Try running:

```
➔ rake stats

+----------------------+-------+-------+---------+---------+-----+-------+
| Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |
+----------------------+-------+-------+---------+---------+-----+-------+
| Helpers              |     9 |     7 |       0 |       1 |   0 |     5 |
| Models               |     0 |     0 |       0 |       0 |   0 |     0 |
| Mailers              |   152 |   102 |       3 |      10 |   3 |     8 |
| Libraries            |  1215 |   953 |       3 |     116 |  38 |     6 |
| Presenter specs      |    72 |    56 |       0 |       0 |   0 |     0 |
| Model specs          |  2458 |  1913 |       0 |       3 |   0 |   635 |
| Serializer specs     |   265 |   226 |       0 |       0 |   0 |     0 |
| Service specs        |  3263 |  2539 |       0 |       0 |   0 |     0 |
| Helper specs         |    65 |    58 |       0 |       4 |   0 |    12 |
| Grape specs          |  2353 |  2012 |       0 |       0 |   0 |     0 |
| Mailer specs         |   119 |    89 |       2 |       2 |   1 |    42 |
| Serializers          |  4283 |  3384 |     234 |     183 |   0 |    16 |
| Presenters           |   601 |   497 |      21 |      67 |   3 |     5 |
| Services             | 14570 | 11346 |     244 |    1625 |   6 |     4 |
| Uploaders            |     0 |     0 |       0 |       0 |   0 |     0 |
| Validators           |     0 |     0 |       0 |       0 |   0 |     0 |
| Workers              |   336 |   258 |      14 |      14 |   1 |    16 |
| Grape                | 10654 |  8765 |     106 |     202 |   1 |    41 |
| Lib                  |  1215 |   953 |       3 |     116 |  38 |     6 |
| Specs                |  8991 |  7125 |       2 |      10 |   5 |   710 |
+----------------------+-------+-------+---------+---------+-----+-------+
| Total                | 50621 | 40283 |     632 |    2353 |   3 |    15 |
+----------------------+-------+-------+---------+---------+-----+-------+

```

Another cool stuff if you like statistics, is `git fame` gem.


---

### 3 - Sidekiq

No matter how big is your application, its better that you follow at least some kind of precaution before putting your code in production. This mean that is a really good idea to run all not necessarily processing in an async way, and this is way sidekiq exists \o/

By default, **all mailers and notifications are delivered async as background job** handled by Sidekiq.  
Beside this, all **origins** records are saved in database as background job too. You can read more about **record origins [here](#link)**.

You can configurate sidekiq credentials in `config/application.yml`:

```
sidekiq_username: "your-sidekiq-user"
sidekiq_password: "your-sidekiq-password"
```

To configure sidekiq, see `config/sidekiq.yml` who provides the basic configurations for running without problems.



---

### 4 - Deployment

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

### 5 - Out of box Integrations

The **optional** integrations we have so far are:

* Capistrano for deployment 
* Heroku (with multi enviroment deployment)
* Sidekiq
* Rollbar (plus capistrano integration)
* Carrierwave with [**image file optimization**](https://github.com/albertbellonch/piet) (includes AWS S3 support for upload)
* Grape + Nifty Services + ActiveModelSerializer (very stunning threesome :P)]
* SimplifiedCache (Finally handle cache in an human way)
* NewRelic with better grape integration (Monitor your application and hardware status)
* Sendgrind Integration for Heroku (automagically)
* Memcachier integration for heroky (automagically)

---

## How it Works

The project glues [all components](#the-tech-stack) together and delegate HTTP flow of request-response to **Grape**.

usuário -> rack -> puma -> rails -> grape -> service -> serializer -> response 

```
```

## Deeper look

From here to above, we will take a look 

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