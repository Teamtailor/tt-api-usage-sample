# README

This is a sample Rails project that provides a simple tool to filter/export resources using Teamtailor public API. At
the moment, only candidates resource is supported but the code can easily be extended to supported any type
of [Teamtailor resources](https://docs.teamtailor.com/).

## How to use:

* Clone the repo
* Install dependencies using `bundle install` and `yarn`.
* Start the server with `rails server`
* Visit [http://localhost:3000](http://localhost:3000) to access the app home page
* Enter your Teamtailor API key the hit Submit.
* You can then select the supported resource and start filtering/exporting data.

## Under the hood:

This sample app core functionality is based on the Teamtailor Api Client that interacts with Teamtailor public API. It
implements the following features:

* **Rate limit**: It uses redis to keep track of the remaining API requests and the reset time returned by Teamtailor
  API. More information can be found [here](https://docs.teamtailor.com/#rate-limit).
* **Retry mechanism**: The Teamtailor Api Client will retry the failed request up to 3 times when a rate limit exceeded
  error is thrown. After that, it will raise an Error to the user.
* **Caching requests**: To avoid unnecessary API calls and improve the speed, the HTTP requests made will automatically
  be cached (in Redis) for 10 min.
* **Parallelized HTTP requests**: The client interacts with Teamtailor public API using the
  popular [Typhoeus gem](https://github.com/typhoeus/typhoeus). It's basically a wrapper around libcurl library and it
  allows to make fast and reliable concurrent http requests.

## How to extend the app to other resources:

Let's say I want to add users resources to the supported list

1- Add the users resource route to routes.rb: `resources :users, only: [:index]`

2- Create users controller inheriting from resources controller (eg. controllers/candidates_controller.rb). All what's
needed to change is the following methods:

* filters_params: (filters supported on the resource)
* resource_type: which should return 'users' in this case
* includes: This defines any relationships you would like to include in the response.

3- Create index and filters form for the users page under views/users repository. You can use `index.html`
and `_form_candidate_filters.html.erb` as templates. Please note that when building the filters form, the filter field
name should be the same as the field name in Teamtailor API.

4- Finally you can add a link to the users resource from the home page. This can easily be achieved by
adding `<li><%= link_to 'Users', users_path %></li>` to views/dashboards/index.html.erb file.
