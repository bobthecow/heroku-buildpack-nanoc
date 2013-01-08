Heroku buildpack: nanoc
=======================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) for [nanoc static sites](http://nanoc.ws).


Zero to nanoc in 25.4 seconds
-----------------------------

    gem install bundler nanoc
    nanoc create-site hello-world
    cd hello-world/
    cat << EOF > Gemfile
    source :rubygems
    gem 'nanoc'
    gem 'rack'
    EOF
    bundle install
    git init
    git add .
    git commit -m 'initial commit'
    heroku create --buildpack https://github.com/bobthecow/heroku-buildpack-nanoc.git
    git push heroku master


Usage
-----

Example Usage:

    $ ls
    config.yaml  content  Gemfile  Gemfile.lock  layouts  lib  output  Rules tmp

    $ heroku create --buildpack https://github.com/bobthecow/heroku-buildpack-nanoc.git

    $ git push heroku master
    ...
    -----> Fetching custom git buildpack... done
    -----> nanoc app detected
    -----> Installing dependencies using Bundler version 1.3.0.pre.2
           Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin --deployment
           Fetching gem metadata from http://rubygems.org/..........
           Installing colored (1.2)
           Installing cri (2.3.0)
           Installing nanoc (3.4.3)
           Installing rack (1.4.3)
           Using bundler (1.3.0.pre.2)
           Your bundle is complete! It was installed into ./vendor/bundle
           Cleaning up the bundler cache.
    -----> Adding default config.ru
    -----> Compiling nanoc site
           Loading site data…
           Compiling site…
           create  [0.00s]  output/style.css
           create  [0.01s]  output/index.html
           Site compiled in 0.08s.
    -----> Discovering process types
           Procfile declares types -> (none)
           Default types for nanoc -> console, rake, web
    -----> Compiled slug size: 596K
    -----> Launching... done, v1

In addition to a nanoc site, this buildpack requires both `Gemfile` and `Gemfile.lock` files in the root directory. It will then proceed to run `bundle install` after setting up the appropriate environment for [ruby](http://ruby-lang.org) and [Bundler](http://gembundler.com).


#### Bundler

For non-windows `Gemfile.lock` files, the `--deployment` flag will be used. In the case of windows, the Gemfile.lock will be deleted and Bundler will do a full resolve so native gems are handled properly. The `vendor/bundle` directory is cached between builds to allow for faster `bundle install` times. `bundle clean` is used to ensure no stale gems are stored between builds.


#### Pre- and post-compile hooks

If you define `nanoc:precompile` or `nanoc:postcompile` Rake tasks, they will be performed just before and after running `nanoc compile`. For example:

    # Rakefile
    
    namespace :nanoc do
      task :precompile  => [:update]
      task :postcompile => ['my-custom-command']
    
      task :update do
        system 'bundle', 'exec', 'nanoc', 'update', '-y'
      end
    
      task 'my-custom-command' do
        system 'bundle', 'exec', 'nanoc', 'my-custom-command'
      end
    end


Hacking
-------

To use this buildpack, fork it on Github.  Push up changes to your fork, then create a test app with `--buildpack <your-github-url>` and push to it.

This uses the default Heroku Ruby buildpack vendored binaries. For more information on those (or to use your own), see [heroku-buildpack-ruby](https://github.com/heroku/heroku-buildpack-ruby).


Flow
----

Here's the basic buildpack flow:

 * runs Bundler
 * installs binaries
   * installs node if the `execjs` gem is detected
 * adds a default `config.ru` unless one is already present
 * runs `rake nanoc:precompile` (if applicable)
 * runs `nanoc compile`
 * runs `rake nanoc:postcompile` (if applicable)
 * boots `rackup -c config.ru` (or `thin start` if applicable) unless a custom `web` process is declared


What happend to the old `heroku-buildpack-nanoc`?
-------------------------------------------------

The old `heroku-buildpack-nanoc` was an opinionated nanoc + Apache + PHP stack, which was distinctly less awesome if you didn't want (or need) Apache and PHP. It is still available as [`heroku-buildpack-nanoc-apache-php`](https://github.com/bobthecow/heroku-buildpack-nanoc-apache-php).
