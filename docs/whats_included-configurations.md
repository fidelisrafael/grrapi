## Grapi documentation

---

### Configuration

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
