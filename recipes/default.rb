#
# Cookbook Name:: logrotate
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
cookbook_file "/usr/local/lib/logrotate.sh" do
  source "logrotate.sh"
  mode "0755"
end

cookbook_file "/etc/cron.daily/300.logrotate" do
  source "300.logrotate"
  mode "0755"
end

directory "/var/log/misc" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/var/log/misc/log" do
  owner "root"
  group "root"
  mode "0644"
  action :create_if_missing
end

service "rsyslog" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end 

file "/var/log/messages" do
  action :delete
  not_if "test -L /var/log/messages"
end

link "/var/log/messages" do
  to "/var/log/misc/log"
  notifies :restart, "service[rsyslog]"
end
