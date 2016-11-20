## Grapi documentation

---

### User Session Management

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
For your happiness, you can have this in seconds, just clone ["AngularJS ruby-api-starter front-end client"](https://github.com/fidelisrafael/ruby-api-starter-boilerplate-angularjs-client) and follow the README instructions. <br />

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
|![Password Reset](http://i.imgur.com/3LnuqXJ.png) | ![Password successfully updated feedback](http://i.imgur.com/jXvHU4a.png)| ![Password error feedback](http://i.imgur.com/0zgJAYM.png) |

<br />
##### Account confirmation integration

| success | success | error |
|---------|---------|-------|
|![](http://i.imgur.com/QhXEpE9.png) | ![Account confirmation](http://i.imgur.com/NI6lYg0.png)| ![Invalid token](http://i.imgur.com/0zgJAYM.png) |

---

### Next

See [Project Organization](./whats_included-code-organization.md)
