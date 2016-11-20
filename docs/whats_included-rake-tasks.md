## Grapi documentation

---

### Rake Tasks

Being a grape-oriented application makes your `rake routes` command just listing an empty set of routes. (the ones this template made the setup)  
To fix this, this projects include one rake task to list all application routes:

#### Routes tasks

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

---

#### Heroku deployment tasks

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


---

#### Codebase Stats

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

### Next

See [Sidekiq](./whats_included-sidekiq.md)
