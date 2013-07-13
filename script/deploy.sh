#!/bin/bash

set -e
cd $(dirname $0)

host=propile
user=matteo

ssh $user@$host <<EOF
	export RAILS_ENV=production
	set -e
	cd propile
	set -x
	git pull
	cat tmp/pids/server.pid | xargs kill -9 || true
	bundle exec rake db:migrate
#	bundle exec rake assets:precompile
	rails server --daemon
EOF