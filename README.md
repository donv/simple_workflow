simple_workflow
===============

[![Gem Version](https://badge.fury.io/rb/simple_workflow.svg)](https://badge.fury.io/rb/simple_workflow)
[![Build Status](https://travis-ci.org/donv/simple_workflow.svg?branch=master)](https://travis-ci.org/donv/simple_workflow)

* http://github.com/donv/simple_workflow
* http://rubydoc.info/gems/simple_workflow
* https://rubygems.org/gems/simple_workflow

## DESCRIPTION

Extension to Rails to allow simple workflow browser navigation using detours
with returns.

## FEATURES

* switch your "link_to" lines to "detour_to" and your controller "redirect_to"
  to "back_or_redirect_to" to allow users to return from whence they came.

## SYNOPSIS:

In views:

    detour_to controller: :my_models, action: :create
    back_or_link_to controller: :welcome, action: :index
    image_button_to controller: :my_models, action: :create

    link_to 'Link with custom origin', with_detour(destination, origin)

In controllers:

    back_or_redirect_to controller: :my_models, action: :index

In your tests:

    def test_valid_login_redirects_as_specified
      add_stored_detour "/bogus/location"
      post :login, user: { login: "tesla", password: "atest" }
      assert_logged_in users(:tesla)
      assert_response :redirect
      assert_redirected_to "http://#{request.host}/bogus/location"
    end

## REQUIREMENTS

* Ruby 2.2 or newer.  **JRuby** supported!
* Rails 4.2 or newer.

## INSTALL

    gem install simple_workflow

or in Gemfile

    gem 'simple_workflow'

## LICENSE

(The MIT License)

Copyright (c) 2009-2016 Uwe Kubosch

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
