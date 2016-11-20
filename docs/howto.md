## Grapi documentation

---

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

---

### Next

See [Server Dependencies](./server_dependencies.md)