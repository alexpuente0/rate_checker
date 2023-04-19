require_relative 'lib/rate_checker/version'

Gem::Specification.new do |spec|
  spec.name = 'rate_checker'
  spec.version = RateChecker::VERSION
  spec.authors = ['alexpuente0']
  spec.email = ['manu.puente0@hotmail.com']

  spec.summary = 'Ruby gem for connecting to the FedEx web service and obtaining shipping rates.'
  spec.homepage = 'https://github.com/alexpuente0/rate_checker'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.2'

  # Dependencies
  spec.add_dependency 'net-http', '~> 0.1'
  spec.add_dependency 'nokogiri', '~> 1.10'
  spec.add_development_dependency 'rspec', '~> 3.12'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
  #   end
  # end
  spec.files = Dir['lib/rate_checker.rb', 'lib/rate_checker/version.rb', 'lib/rate_checker/xml_helper.rb']

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
