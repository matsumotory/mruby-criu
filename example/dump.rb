socket = "/var/run/criu_service.socket"
images = "/var/cache/criu_dump"
log = "dump.log"
# need iij/mruby-env
pid = ENV["PID"].to_i

c = CRIU.new
p c.set_pid pid
p c.set_images_dir images
p c.set_service_address socket
#p c.set_ext_unix_sk true
#p c.set_tcp_established true
p c.set_log_file log

p c.dump
