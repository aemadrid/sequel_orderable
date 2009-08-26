# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sequel_orderable}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adrian Madrid"]
  s.date = %q{2009-08-26}
  s.email = %q{aemadrid@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "CHANGELOG",
     "COPYING",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/sequel_orderable.rb",
     "spec/orderable_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/aemadrid/sequel_orderable}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Update of Aman Gupta's Sequel Orderable Plugin}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/orderable_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
