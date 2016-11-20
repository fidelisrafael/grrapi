## Grrapi docs

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


---

### Next

See [Configurations](./whats_included-configurations.md)
