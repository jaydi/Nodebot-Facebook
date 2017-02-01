#!/bin/bash

ssh kiki.video
cd waikiki
git pull
bundle install
bundle exec pumactl -S shared/pids/puma.state phased-restart
bundle exec sidekiqctl stop shared/pids/sidekiq.pid
bundle exec sidekiq -e production
exit