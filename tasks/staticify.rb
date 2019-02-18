require 'fileutils'
require 'open3'

module CRIU::Staticify
  PATCH_PATH = File.expand_path(File.dirname(__FILE__) + '/criu_a.patch')

  def run_command env, command
    STDOUT.sync = true
    puts "EXEC\t[mruby-criu] #{command}"
    Open3.popen2e(env, command) do |stdin, stdout, thread|
      print stdout.read
      fail "#{command} failed" if thread.value != 0
    end
  end

  def bundle_libcriu
    version = CRIU::CRIU_VERSION
    tarball_url = "https://github.com/checkpoint-restore/criu/archive/v#{version}.tar.gz"

    def criu_dir(b); (ENV["CRIU_TMP_DIR"] || "#{b.build_dir}/vendor/libcriu"); end
    def libcriu_dir(b); "#{criu_dir(b)}/lib/c"; end
    def libcriu_header(b); "#{criu_dir(b)}/lib/c/criu.h"; end
    def libcriu_a(b); libfile "#{criu_dir(b)}/lib/c/libcriu"; end

    task :clean do
      FileUtils.rm_rf [libcriu_dir(build)]
    end

    file libcriu_header(build) do
      unless File.exist? libcriu_dir(build)
        tmpdir = '/tmp'
        run_command ENV, "rm -rf #{tmpdir}/libcriu-#{version}"
        run_command ENV, "mkdir -p #{File.dirname(criu_dir(build))} #{File.dirname(criu_dir(build))}"
        run_command ENV, "curl -sL #{tarball_url} | tar -xz -f - -C #{tmpdir}"
        run_command ENV, "mv -f #{tmpdir}/criu-#{version} #{criu_dir(build)}"
        run_command ENV, "cd #{criu_dir(build)} && patch -p1 < #{PATCH_PATH}"
        run_command ENV, "cd #{File.dirname(libcriu_a(build))} && ln -s .. criu" # resolve include <criu/criu.h>
      end
    end

    file libcriu_a(build) => libcriu_header(build) do
      unless File.exist?(libcriu_a(build))
        Dir.chdir criu_dir(build) do
          ENV["LD_FLAGS"] = "-lprotobuf-c"
          run_command ENV, "make lib/c/libcriu.a"
        end
      end
    end

    libmruby_a = libfile("#{build.build_dir}/lib/libmruby")
    file libmruby_a => libcriu_a(build)

    self.cc.include_paths << File.dirname(libcriu_header(build))
    self.linker.library_paths << File.dirname(libcriu_a(build))
    # NOTE: order is important!!
    self.linker.libraries << 'criu'
    self.linker.libraries << 'protobuf-c'
  end
end
