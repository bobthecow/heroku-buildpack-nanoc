require 'language_pack'
require 'language_pack/ruby'

# Nanoc Language Pack. Nanoc like wow.
class LanguagePack::Nanoc < LanguagePack::Ruby
  BUILDPACK_VERSION   = 'v0.2.0'

  # detects if this is a valid Nanoc app by checking whether a rules file exists
  # @return [Boolean] true if it's a Nanoc app
  def self.use?
    super && %w{Rules rules Rules.rb rules.rb}.any? { |rules| File.file?(rules) }
  end

  def name
    'nanoc'
  end

  def default_config_vars
    super.merge({
      'RACK_ENV' => 'production'
    })
  end

  def default_process_types
    # let's special case thin here if we detect it
    web_process = gem_is_bundled?('thin') ?
                    'bundle exec thin start -R config.ru -e $RACK_ENV -p $PORT' :
                    'bundle exec rackup config.ru -p $PORT'

    super.merge({
      'web' => web_process
    })
  end

  def compile
    super
    install_default_rack_config
    run_nanoc_precompile
    run_nanoc_compile
    run_nanoc_postcompile
  end

private

  # sets up the profile.d script for this buildpack
  def setup_profiled
    super
    set_env_default 'RACK_ENV', 'production'
  end

  DEFAULT_RACK_CONFIG = <<-EOF.gsub(/^    /, '')
    require 'rack'

    use Rack::CommonLogger, $stderr

    module HerokuBuildpackNanoc
      class Server
        NOTFOUND = './output/404.html'

        def initialize
          @notfound = File.file?(NOTFOUND) ? File.read(NOTFOUND) : '<h1>Not Found</h1>'
          @try      = ['', '.html', 'index.html', '/index.html']
          @static   = ::Rack::Static.new(lambda { |_| [404, {}, []] }, root: 'output', urls: %w[/])
        end

        def call(env)
          orig_path = env['PATH_INFO']
          found     = nil
          @try.each do |path|
            resp = @static.call(env.merge!({'PATH_INFO' => orig_path + path}))
            break if 404 != resp[0] && found = resp
          end
          found or [404, {'Content-Type' => 'text/html'}, [@notfound]]
        end
      end
    end

    run HerokuBuildpackNanoc::Server.new
  EOF

  def install_default_rack_config
    unless File.exist? 'config.ru'
      topic 'Adding default config.ru'
      File.open('config.ru', 'w') { |file| file << DEFAULT_RACK_CONFIG }
    end
  end

  def run_nanoc_precompile
    if rake_task_defined?('nanoc:precompile')
      topic('Running precompile tasks')

      puts 'Running: rake nanoc:precompile'
      require 'benchmark'
      time = Benchmark.realtime { pipe('env PATH=$PATH:bin bundle exec rake nanoc:precompile 2>&1') }

      if $?.success?
        log 'nanoc_precompile', :status => 'success'
        puts "Precompilation completed (#{"%.2f" % time}s)"
      else
        error 'Precompilation failed'
      end
    end
  end

  def run_nanoc_compile
    require 'benchmark'

    topic 'Compiling nanoc site'
    time = Benchmark.realtime { pipe('env PATH=$PATH:bin bundle exec nanoc compile 2>&1') }
    unless $?.success?
      error "Site compilation failed (#{"%.2f" % time}s)."
    end
  end

  def run_nanoc_postcompile
    if rake_task_defined?('nanoc:postcompile')
      topic('Running postcompile tasks')

      puts 'Running: rake nanoc:postcompile'
      require 'benchmark'
      time = Benchmark.realtime { pipe('env PATH=$PATH:bin bundle exec rake nanoc:postcompile 2>&1') }

      if $?.success?
        log 'nanoc_postcompile', :status => 'success'
        puts "Postcompilation completed (#{"%.2f" % time}s)"
      else
        error 'Postcompilation failed'
      end
    end
  end

end
