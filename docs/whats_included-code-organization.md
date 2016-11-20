## Grapi documentation

---

#### Project e Code organization (for real)

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

---

### Next

See [Rake Tasks](./whats_included-rake-tasks.md)
