require "pathname"

# General Language Pack module
module LanguagePack

  # detects which language pack to use
  # @param [Array] first argument is a String of the build directory
  # @return [LanguagePack] the {LanguagePack} detected
  def self.detect(*args)
    Dir.chdir(args.first)

    # For now there's only one, since this handles both the generic case and the
    # custom Rack config case...
    pack = [ Nanoc ].detect do |klass|
      klass.use?
    end

    pack ? pack.new(*args) : nil
  end

end

require "language_pack/nanoc"
