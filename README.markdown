DEBESO: gist clone
=======================

installation and start
-----------------------

$ bundle install --path vendor/bundle
$ cp config/setting.yml.sample config/setting.yml
edit config/setting.yml
$ bundle exec padrino rake ar:migrate

$ bundle exec padrino start

access to http://localhost:3000

test
-----------------------
$ bundle exec padrino rake ar:migrate -e test
$ bundle exec padrino rake spec

