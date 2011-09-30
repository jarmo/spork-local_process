# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "spork-local_process"
  s.version     = "0.0.5"
  s.authors     = ["Jarmo Pertman"]
  s.email       = ["jarmo.p@gmail.com"]
  s.homepage    = "https://github.com/jarmo/spork-local_process"
  s.summary     = %q{Run your code in a local process with Spork again and again without reloading the whole environment each time.}
  s.description = %q{Run your code in a local process with Spork again and again without reloading the whole environment each time.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "spork", "~>0.9.0.rc9"
end
