# Add the repo if needed

case node[:platform]

when 'centos'
    if node[:platform_version].to_i == 6
        include_recipe 'yum::remi'
    end

when 'ubuntu'

    if node['platform_version'].to_f <= 10.04
        apt_repository 'ondrej-php5' do
            uri 'http://ppa.launchpad.net/ondrej/php5/ubuntu'
            distribution node['lsb']['codename']
            components ['main']
            keyserver 'keyserver.ubuntu.com'
            key 'E5267A6C'
            action :add
        end
    end
end


node[:php][:fpm_packages].each do |pkg|
    package pkg do
        action :install
    end
end


directory node[:php][:fpm][:log_dir] do
    action :create
    mode '755'
end

template node[:php][:fpm_config] do
    source node[:php][:fpm_config_template]
    mode '0644'
end

template node[:php][:fpm_pool_config] do
    source 'fpm-www.conf.erb'
    mode '0644'
end

template "#{node[:php][:conf_dir]}/php.ini" do
    source 'php.ini.erb'
    mode '0644'
end


service node[:php][:fpm_service] do
    action [:enable, :restart]
end


template '/etc/logrotate.d/php-fpm' do
    source 'logrotate.erb'
    mode '644'
end
