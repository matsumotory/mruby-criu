# swrk mode example

images = "/tmp/criu/images"
log = "-"

c = CRIU.new
p c.set_service_binary "/usr/local/sbin/criu"
p c.set_images_dir images
p c.set_log_file log
p c.set_shell_job true

# Can wait restored process here / when using patched criu...
p(Process.waitpid2 c.restore_child)
