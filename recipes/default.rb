#
# Cookbook Name:: poc_es
# Recipe:: default
#
include_recipe 'chef-sugar'
include_recipe 'java'

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  version '5.3.0'
  action :install
end

node.default['poc_es']['config'].tap do |config|
  config['bootstrap.memory_lock'] = true
  config['cluster.name']          = 'escluster'
  config['node.name']             = node['hostname']
  config['node.data']             = true
  config['node.master']           = true
  config['network.bind_host']    = '0.0.0.0'
  config['network.publish_host'] = node['ipaddress']
end

elasticsearch_plugin 'x-pack' do
  action :install
end

node.default['poc_es']['config'].tap do |config|
  config['xpack.security.enabled'] =  true
  config['xpack.security.authc.anonymous.username'] = 'anonymous_user'
  config['xpack.security.authc.anonymous.roles'] = 'superuser'
  config['xpack.security.authc.anonymous.authz_exception'] = true
end

elasticsearch_configure 'elasticsearch' do
  nofile_limit '100000'
  configuration(node['poc_es']['config'])
end

delete_resource(:elasticsearch_service, 'elasticsearch')
elasticsearch_service 'elasticsearch' do
  service_actions [ :start, :enable ]
end
