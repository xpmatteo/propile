#!/bin/bash

set -e
cd $(dirname $0)

host=propile
user=matteo

ssh $user@$host <<EOF
	set -e
	set -x
	export RAILS_ENV=production
	cd propile
	git pull
	bundle install
	bundle exec rake assets:precompile
	cat tmp/pids/server.pid | xargs kill -9 || true
	bundle exec rake db:migrate
	rails server --daemon
EOF