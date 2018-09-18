module CRIU
  unless CRIU.const_defined? :CRIU_VERSION
    CRIU_VERSION = "3.10"
  end
end

require_relative 'tasks/staticify'

MRuby::Gem::Specification.new('mruby-criu') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'

  if spec.build.cc.defines.flatten.include?("MRB_CRIU_USE_STATIC")
    spec.extend CRIU::Staticify
    spec.bundle_libcriu
  else
    spec.linker.libraries << 'criu'
  end
end
