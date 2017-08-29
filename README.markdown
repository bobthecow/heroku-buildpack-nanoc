# Heroku buildpack for nanoc

Compile and serve a nanoc site on Heroku.


## Zero to nanoc in 25.4 seconds

    gem install bundler nanoc
    nanoc create_site hello-world
    cd hello-world/
    cat << EOF > Gemfile
    source :rubygems
    gem 'nanoc'
    EOF
    bundle install
    git init
    git add .
    git commit -m "initial commit"
    heroku create -s cedar --buildpack https://github.com/campeterson/heroku-buildpack-nanoc.git
    git push heroku master


## License

Copyright (C) 2012 by Justin Hileman

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
