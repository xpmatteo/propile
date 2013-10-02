#!/bin/bash

set -e
cd $(dirname $0)

host=propile
user=matteo

ssh $user@$host <<EOF
	set -e
	source .propile_config
	cd propile
	set -x
	git pull
	bundle install --deployment --quiet
	bundle exec rake assets:precompile
	sudo -i bash -c 'cd /home/matteo/propile; bundle exec thin stop' || true
	bundle exec rake db:migrate
	sudo -i bash -c 'cd /home/matteo/propile; bundle exec thin start -p 80 -d'
EOF