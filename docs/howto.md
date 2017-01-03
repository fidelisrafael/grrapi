## Grrapi docs

---

## How to use

First of all, you need to know that this option is better suitable for **new projects**, of course you can integrate it with your existing application, but this will need some manual work. With this said, let me introduce how simple is to start a new project with all boilerplate code up & running:

### 0 - Decide which kind of project you need

Well, first things, first! This template basically supports two generator modes:

| mode | description | recommendation |
| ---- | ----------- | -------------- |
| minimal | only basic components are installed in your application | very minimal start point, just a clean architecture to start your project(this fits any kind of API project) |
| auth | minimal + auth components are installed in your application; | most of use cases, include session management(including password request new/update handling) |
| complete | auth + cache and images upload processing setup(with carrierwave) | medium to big port applications|
| full | complete + system notifications + push notifications(Android/iOS using ParseServer) + user preferences + cities + states + soft delete(using [`paranoia`](https://github.com/rubysherpas/paranoia])) | May not fit all kinds of API projects, but must be your coffee of tea, who knows?! |

Below show the mainly differences between each mode:

#### Minimal:
* Simple Rails container application - I call it *container application* because this Rails application is **only used to mount Grape application**, leveraging Rails conventions to quick setup things.
This application did not include `ActionPack, ActionController` and thanks God is free of `ActiveRecord` weird stuffs too.
* [Grape](https://github.com/intridea/grape) + [NiftyServices](https://github.com/fidelisrafael/nifty_services) + [ActiveModelSerializer integration](https://github.com/rails-api/active_model_serializers)
* [Sequell](https://github.com/jeremyevans/sequel) as ORM (way more flexible than ActiveRecord)
* Configuration via ENV variables & Organization(with [Figaro](https://github.com/laserlemon/figaro))
* Simple ACL(Access Level Setup) when handling services
* Rake Tasks(to print all api routes, or to generate stats about app)
* Deployment(capistrano for private cloud or Heroku)
* I18n responses setup
* Minimal Rspec setup
* Rollbar error tracking integration
* New Relic grape agent (to harvest metrics of your Grape application)

#### Auth

Everything in **Minimal**, plus:

* Account and Auth Management
* Database and models setup (**3 total tables**):
  * Authorization `authorizations`
  * User `users`
  * Origin `origins`
* Minimal sidekiq implementation (just to delivery emails and update user)


#### Complete

Everything in **Auth**, plus:

* User preferences(endpoints to get and update - preferences are an `json` column in `users` table)
* File upload handling with [Carrierwave](https://github.com/carrierwaveuploader/carrierwave)
* Sequell integration with carrierwave through [carrierwave-sequel](https://github.com/carrierwaveuploader/carrierwave-sequel)
* Image file optimization using [Piet](https://github.com/albertbellonch/piet)
* Very simple and configurable cache strategy for endpoints(this time using SimpleCache)

 
#### Full

Everything existing in **Complete**, plus:

* Soft delete for your database records(using [Paranoia gem](https://github.com/rubysherpas/paranoia))
* System notifications (including endpoint to fetch all notifications, and to mark notification as read)
* Push Notifications deliveries almost without any configuration. This include endpoints to register/deregister devices, every communcation with remote API is done using Sidekiq.
Notifications are sent to mobile devices using [ParseServer](https://github.com/ParsePlatform/parse-server)
* Integrations (Automagically integration with SendGrid and Memcachier)
* Database and models setup(**8 total tables**):
  * Address (`addresses` _Polymorphic association_ to enable addressing for resources)
  * UserDevice ( `user_devices` for push notifications delivery)
  * Notifications (`notifications` for storing system notifications)
  * State (`states` - With default seed data including all states for Brazil)
  * City (`cities`) With default seed data including all cities for Brazil)

PS: This versions include a patch in `uniqueness_validator` to patch `ActiveRecord` when using `paranoia`(soft delete)

---

#### 1 - Clone this repository 

Now, just clone this repository to an acessible location in your workstation:

```
git clone git@github.com:fidelisrafael/Grape-as-Ruby-REST-API-Starter-Boilerplate.git
```

Keep in mind where you downloaded this repository, you will need the path in next step.


#### 2 - Init your Rails project

After studing your application use cases, you've choosed one the template mode bettween `mininal` and `complete`(the default value), now lets create our Rails application.

To use _Grrapi_, you need to run your Rails project creation the command passing the the template URL option(`-m TEMPLATE_URL`) and `--grrapi-template-mode="mode"` which will tell the template what kind of setup to do. For example:

```
rails new myApiProject -m /path/to/Grape-as-Ruby-REST-API-Starter-Boilerplate/template.rb --grrapi-template-mode="complete" --skip-assets --skip-javascript 
```

For your API projects you must want to skip all `sprockets` handling passing `--skip-assets --skip-javascript` (*)

For Rails 5, you can use `--api` flag:

```
rails new myApiProject -m /path/to/Grape-as-Ruby-REST-API-Starter-Boilerplate/template.rb --api --grrapi-template-mode="complete"
```

**OBS**:  Grrapi(Grape as Ruby Rest API) take care of removing  sprockets middlewares from rack stack, this is important because your API must be always fast as possible, and removing this processement from response management is a big win).


#### 3 - Install dependencies

```
cd myApiProject

bundle install
```

#### 4 - Configure your application:

Open `config/application.yml` and see all the configurations, you may want to change some values to reflect better your enviroment.

You can read more detailed configuration documentation [here](#configuration).

##### Setup your database:

Configure `config/database.yml` and add your local postgres credentials:

```
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
``` 

#### 5 - Run the application:

Just run: `bundle exec rails s -p 8080` and your REST API server will start running at `http://localhost:8080/api`

"Test" the installation: 
```
➔ curl -I "http://localhost:8080/api/v1/swagger_doc"
HTTP/1.1 200 OK
(...)
```

Simple as that.

---

### Next

See [Server Dependencies](./server_dependencies.md)