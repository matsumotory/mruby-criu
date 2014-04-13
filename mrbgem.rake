MRuby::Gem::Specification.new('mruby-criu') do |spec|
  spec.license = 'MIT'
  spec.authors = 'MATSUMOTO Ryosuke'
  spec.linker.libraries << 'criu'
end
