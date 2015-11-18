# Capistrano::Ghostinspector

[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/badges/quality-score.png?b=develop)](https://scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/?branch=develop)
[![Build Status](https://scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/badges/build.png?b=develop)](https://scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/build-status/develop) [![Gem Version](https://badge.fury.io/rb/capistrano-ghostinspector.svg)](https://badge.fury.io/rb/capistrano-ghostinspector)


[Ghost Inspector](https://ghostinspector.com/ "Ghost Inspector") is an automated website regression testing tool. This [Capistrano](http://capistranorb.com/ "Capistrano") plugin is a simple, configurable gem that will provide the following features.


#### Features
- Choose which task to run after
- Set individual tests/suites to run from command line
- Set individual tests/suites to run from configuration on each stage
- Exclude individual stages
- Auto rollback to previous version on failed tests (can be disabled in config per stage)
- Auto configure start URL to reuse tests across multiple stages
- Send deployment information to Google Analytics
- Send errors to Google Analytics on failed tests
- Send successful test runs to Google Analytics
- Use Custom Dimensions in Google Analytics
- Send test names as Custom Dimension
- Track Jira tickets as Custom Dimension

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-ghostinspector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-ghostinspector

And the add the following to the top of your `deploy.rb` file

```ruby
require 'capistrano/ghostinspector'
```

Inside your `deploy.rb` file you need to add the following to your run list -

```ruby
after "deploy", "ghostinspector:setup"
```

You can change the run order by changing `deploy` for any other task in your deployment run list. For example, you may have a task of `run_scripts` that is executed after deployment for database migration. In this case you would change the above line to -

```ruby
after "run_scripts", "ghostinspector:setup"
```

## Configuration

First thing you need to do is create your `YAML` file (`gi_config.yaml`) in the Capistrano folder with the following format -
```
---
APIKEY: XXXXXXXXXXXXXXXXXXX
gi_enabled: true
rollback: true
suites:
    aboutpage: "XXXXXXXXXXXXXXXXXXX"
    suite2: ""
tests:
    homepage: "XXXXXXXXXXXXXXXXXXX"
    test2: ""
    test3: ""
ga_enabled: true
ga_property: "UA-XXXXXXXX-X"
ga_custom_1: 1
ga_custom_2: 2
jira_project_code: "GHOST"
```

You can obtain your API key, suite ID and test ID from your Ghost Inspector console. At the bottom right of the suite page you will see API Access e.g. 
`https://api.ghostinspector.com/v1/suites/`SUITE ID IS HERE`/execute/?apiKey=`API KEY ID IS HERE

Add as many suites or tests as you like, the name you give your test isn't important but you should make it easy to remember when executing the test.

By default the ghost inspector execution is enabled, you can disabled this for all stages by setting `gi_enabled: false` in the `YAML` file. Alternatively you can change this on a per stage basis by setting the appropriate variable 
```ruby
set :gi_enabled, false
``` 
This ensures that Ghost Inspector is not automatically run when accidentally triggered via the command line.

By default the `rollback` feature is enabled, you can disabled this for all stages by setting `rollback: false` in the `YAML` file. Alternatively you can change this on a per stage basis by setting the appropriate variable 
```ruby
set :rollback, false
```

### Configure Start URL

Ghost Inspector has a nice feature that allows you to dynamically alter the start URL for your test. This allows you to reuse the same tests across multiple environments. i.e `staging.mysite.com`, `uat.mysite.com`, `www.mysite.com`. For this feature to work you must have a domain set in your stage. i.e. for staging you might have

```ruby
set :domain, "staging.mysite.com"
```

and production might have 

```ruby
set :domain, "www.mysite.com"
```

_Failure to set the domain in any stage will revert the tests to be only run against the URL you defined in Ghost Inspector_

## Google Analytics Tracking

The Google Analytics property must be inserted into the `ga_property` in order to log deployments and errors. Simply update your YAML to include this `ga_property: "UA-XXXXXXXX-1"`. The Google Analytics feature also has a `ga_enabled` flag in your YAML file which must be `true` to successfully run. To disable the Google Analytics tracking either set the `ga_enabled` to be false or your can disable Google Analytics in each stage by setting the following - 

```ruby
set :ga_enabled, false
```

Google Analytics uses Custom Dimensions as outlined in the [Google Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters?hl=en#cd_ "Google Measurement Protocol") documentation. When you define a new custom dimension in Google Analytics you are given a new dimension index. Default accounts have 20 available indexes where as premium accounts have 200. The `ga_custom_1` property is used to define the custom dimension for the testname and `ga_custom_2` is used to define the Jira tickets*. If you do not set the `ga_custom_1` or `ga_custom_2` properties then the default index of `1` & `2` will be used.

\*_Jira tickets are extracted from the git log during the deployment. For this reason it can only track the tickets where you have correctly assigned the ticket number and identifier to the commit message. i.e._
```
git commit -am "GHOST-123 Add new item to the gem"
```

## Usage

Run a particular test when deploying to staging -

    $ cap staging deploy -s gitest=homepage


Run a multiple tests when deploying to staging -

    $ cap staging deploy -s gitest=homepage,test2,test3


Run a particular suite when deploying to staging -

    $ cap staging deploy -s gisuite=aboutpage


Run a multiple suites when deploying to staging -

    $ cap staging deploy -s gisuite=aboutpage,suite2

#### Run Default Tests

You can set your default tests/suites to run in each stage. e.g. you might want to run a certain test suite in `production` only but have other tests running in `staging`. You can now set this in your `stage.rb` file using the two flags.

i.e `production.rb` might look like this -
```ruby
set :gi_default_suite, "home"
```
and your `staging.rb` file might have the following -
```ruby
set :gi_default_test, "blog,checkout"
```
As you can see the two variables `gi_default_suite` and `gi_default_test` can also take a comma separated list to run.

## Contributing

1. Fork it ( https://github.com/richdynamix/capistrano-ghostinspector/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Credits

* Bhalin Ramabhadran - https://twitter.com/BhalinR
* Grant Kemp - https://twitter.com/ukandroid
* Steven Richardson - https://twitter.com/troongizmo
