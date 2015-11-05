# Capistrano::Ghostinspector

[![Scrutinizer Code Quality](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/badges/quality-score.png?b=develop)](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/?branch=develop) [![Build Status](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/badges/build.png?b=develop)](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/build-status/develop) [![Gem Version](https://badge.fury.io/rb/capistrano-ghostinspector.svg)](https://badge.fury.io/rb/capistrano-ghostinspector)


[Ghost Inspector](https://ghostinspector.com/ "Ghost Inspector") is an automated website regression testing tool. This [Capistrano](http://capistranorb.com/ "Capistrano") plugin is a simple, configurable gem that will provide the following features.


#### Features
- Set individual tests/suites to run from command line
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

The Google Analytics property must be inserted into the `ga_property` in order to log deployments and errors. Simply update your YAML to include this `ga_property: "UA-XXXXXXXX-1"`. To disable the Google Analytics tracking just leave the `ga_property` as empty string i.e. `ga_property: ""` in your YAML.

Since version `0.3.0`, Google Analytics now uses Custom Dimensions as outlined in the [Google Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters?hl=en#cd_ "Google Measurement Protocol") documentation. When you define a new custom dimension in Google Analytics you are given a new dimension index. Default accounts have 20 available indexes where as premium accounts have 200. The `ga_custom_1` property is used to define the custom dimension for the testname and `ga_custom_2` is used to define the Jira tickets*. If you do not set the `ga_custom_1` or `ga_custom_2` properties then the default index of `1` & `2` will be used.

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
