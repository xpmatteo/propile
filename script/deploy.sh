#!/bin/bash

set -e
cd $(dirname $0)

host=propile
user=matteo

ssh $user@$host <<EOF
	set -e
	cd propile
	git pull
	kill -9 $(cat tmp/pids/server.pid) || true
	bundle exec rake db:migrate
	bundle exec rake assets:precompile
	rails server --daemon
EOF