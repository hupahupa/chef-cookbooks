#
# Cookbook Name:: basics
# Recipe:: sshusers
#
# Copyright 2012, Cogini
#
# All rights reserved - Do Not Redistribute
#

sftp = node[:ssh][:sftp]
sftp_users = sftp[:users]
sftp_upload_dir = sftp[:upload_dir]


service node[:ssh][:service] do
    supports :restart => true
end


sysadmins = node[:admin_users] | node[:sudoers]
ssh_users = node[:ssh][:users] | sysadmins.collect { |u| u[:username] }

ssh_users.each do |ssh_user|
    user ssh_user do
        home "/home/#{ssh_user}"
        shell '/bin/bash'
        supports :manage_home => true
        action :create
    end
end

group node[:ssh][:group] do
    members ssh_users
    action :create
end


# SFTP users and group

sftp_users.each do |sftp_user|
    user sftp_user do
        home "/#{sftp_upload_dir}"
        shell sftp[:shell]
        action :create
    end
    directory "#{sftp[:dir]}/#{sftp_user}/#{sftp_upload_dir}" do
        action :create
        recursive true
        owner sftp_user
    end
end

group sftp[:group] do
    members sftp_users
    action :create
end


template '/etc/ssh/sshd_config' do
    source 'sshd_config.erb'
    mode '0644'
    notifies :restart, "service[#{node[:ssh][:service]}]"
end
