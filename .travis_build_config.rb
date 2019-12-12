MRuby::Build.new do |conf|
  toolchain :gcc

  # If you want to link libcriu.a statically to your app, uncomment
  # conf.cc.defines << "MRB_CRIU_USE_STATIC"

  conf.gembox 'default'
  conf.gem '../mruby-criu'
  conf.cc.defines << "MRB_CRIU_USE_STATIC"
end
