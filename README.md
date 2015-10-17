# Capistrano::Ghostinspector

[![Scrutinizer Code Quality](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/badges/quality-score.png?b=develop)](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/?branch=develop) [![Build Status](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/badges/build.png?b=develop)](https://www2.scrutinizer-ci.com/g/richdynamix/capistrano-ghostinspector/build-status/develop)


[Ghost Inspector](https://ghostinspector.com/ "Ghost Inspector") is an automated website regression testing tool. This [Capistrano](http://capistranorb.com/ "Capistrano") plugin is a simple, configurable gem that will provide the following features.


#### Features
- Set individual tests/suites to run from command line
- Exclude individual stages
- Auto rollback to previous version on failed tests (can be disabled in config per stage)
- Auto configure start URL to reuse tests across multiple stages

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
