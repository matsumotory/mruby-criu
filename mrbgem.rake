module CRIU
  unless CRIU.const_defined? :CRIU_VERSION
    CRIU_VERSION = "3.10"
  end
end

require_relative 'tasks/staticify'

MRuby::Gem::Specification.new('mruby-criu') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  # spec.linker.libraries << 'criu'

  spec.extend CRIU::Staticify
  spec.bundle_libcriu
end
