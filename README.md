# mruby-criu
CRIU, Checkpoint Restart In Userspace for Linux, bindig for mruby.
## install by mrbgems 
- add conf.gem line to `build_config.rb` 

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :git => 'https://github.com/matsumoto-r/mruby-criu.git'
end
```
## Dump and Restore Process
### Isolated process run
##### loop.sh
```bash
#!/bin/bash
cont=0
while :; do
  sleep 1
  cont=`expr $cont + 1`
  echo $cont
done
```
##### run
```bash
setsid ./loop.sh < /dev/null &> loop_log.txt  &
```
##### get pid
```bash
ps -C loop.sh
  PID TTY          TIME CMD
 4823 ?        00:00:00 loop.sh
[1]+  Done                    setsid ./loop.sh < /dev/null &>loop_log.txt
```
##### check log
```bash
tail -f loop_log.txt
1
2
3
...
```
### Dump(Checkpoint)
```ruby
socket = "/var/run/criu_service.socket"
images = "/tmp/dump_test"
log = "dump.log"
pid = 4823

c = CRIU.new
c.set_pid pid
c.set_images_dir images
c.set_service_address socket
c.set_log_file log

c.dump
```
##### dump loop.sh 
```
./bin/mruby dump.rb
```
then, ``loop.sh`` was killed.
```bash
tail -f loop_log.txt
1
2
3

(stopped)
```
### Restore
```ruby
socket = "/var/run/criu_service.socket"
images = "/tmp/dump_test"
log = "restore.log"

c = CRIU.new
c.set_service_address socket
c.set_images_dir images
c.set_log_file log

c.restore
```
##### restore loop.sh
```
./bin/mruby restore.rb
```
then, loop.sh was restored
```bash
tail -f loop_log.txt
(restored)
4
5
6
...
```
## License
under the MIT License:
- see LICENSE file
