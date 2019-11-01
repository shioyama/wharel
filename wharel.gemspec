
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wharel/version"

Gem::Specification.new do |spec|
  spec.name          = "wharel"
  spec.version       = Wharel::VERSION
  spec.authors       = ["Chris Salzberg"]
  spec.email         = ["chris@dejimata.com"]

  spec.required_ruby_version = '>= 2.2.9'

  spec.summary       = %q{Arel + Where = Wharel}
  spec.description   = %q{Use arel predicates directly from where.}
  spec.homepage      = "https://github.com/shioyama/wharel"
  spec.license       = "MIT"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/shioyama/wharel'
  spec.metadata['changelog_uri'] = 'https://github.com/shioyama/wharel/blob/master/CHANGELOG.md'

  spec.files        = Dir['{lib/**/*,[A-Z]*}']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 5', '<= 6'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"

  spec.cert_chain = ["certs/shioyama.pem"]
  spec.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
end
