## Grapi documentation

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

### Next

See [Features](./features.md)