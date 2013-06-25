SpreeOxxo
=========

Introduction goes here.


Install
-------

    bundle exec rails g spree_oxxo:install
    
Delayed Job
-----------
	bundle exec rails generate delayed_job
	bundle exec rails generate delayed_job:active_record
	bundle exec rake db:migrate
	bundle exec rake jobs:work
	bundle exec rake jobs:clean
	


Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2013 [name of extension creator], released under the New BSD License
