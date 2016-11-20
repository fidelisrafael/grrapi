## Grrapi docs

---

## How to use

First of all, you need to know that this option is better suitable for **new projects**, of course you can integrate it with your existing application, but this will need some manual work. With this said, let me introduce how simple is to start a new project with all boilerplate code up & running:

### 0 - Decide which kind of project you need

Well, first things, first! This template basically supports two generator modes:

| mode | description | recommendation |
| ---- | ----------- | -------------- |
| minimal | only basic components are installed in your application | very minimal start point. (any kind of API project)
| auth | minimal + auth components are installed in your application; | most of use cases
| complete | all components are installed in your application; | medium to big port applications

Below show the mainly differences between each mode:

#### Minimal:
* Grape + NiftyServices integration
* Configuration & Organization
* Rake Tasks
* Deployment

#### Auth

Everything in **Minimal**, plus:

* Account and Auth Management
* Database and models setup (**3 total tables**):
  * Authorization `authorizations`
  * User `users`
  * Origin `origins`

#### Complete

Everything existing in **Auth**, plus:

* Sidekiq
* Integrations
* Database and models setup(**8 total tables**):
  * Address (`addresses` _Polymorphic association_ to enable addressing for resources)
  * UserDevice ( `user_devices` for push notifications delivery)
  * Notifications (`notifications` for storing system notifications)
  * State (`states` - With default seed data including all states for Brazil)
  * City (`cities`) With default seed data including all cities for Brazil)

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