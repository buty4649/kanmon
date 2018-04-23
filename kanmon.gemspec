
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kanmon/version"

Gem::Specification.new do |spec|
  spec.name          = "kanmon"
  spec.version       = Kanmon::VERSION
  spec.authors       = ["Yuki Koya"]
  spec.email         = ["buty4649@gmail.com"]

  spec.summary       = %q{CLI tool of add public IP to Securoity Group on OpenStack.}
  spec.description   = %q{CLI tool of add public IP to Securoity Group on OpenStack.}
  spec.homepage      = "https://github.com/buty4649/kanmon/"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "yao", ">= 0.4.1"
  spec.add_dependency "thor", ">= 0.20.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
