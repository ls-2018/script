#!/usr/bin/env ruby

# 读取Vagrantfile并解析settings
current_hostname = `hostname`.strip

if current_hostname == "Studio.local"
  settings = {
    "vm" => [
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2004",
        "hostname" => "vm2004",
        "ip" => "192.168.31.11",
        "memory" => 3072,
        "cpus" => 2
      },
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2204",
        "hostname" => "vm2204",
        "ip" => "192.168.31.12",
        "memory" => 3072,
        "cpus" => 2
      },
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2404",
        "hostname" => "vm2404",
        "ip" => "192.168.31.13",
        "memory" => 3072,
        "cpus" => 4
      }
    ]
  }
else
  settings = {
    "vm" => [
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2004",
        "hostname" => "vm2004",
        "ip" => "192.168.33.11",
        "memory" => 3072,
        "cpus" => 2
      },
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2204",
        "hostname" => "vm2204",
        "ip" => "192.168.33.12",
        "memory" => 3072,
        "cpus" => 2
      },
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2404",
        "hostname" => "vm2404",
        "ip" => "192.168.33.13",
        "memory" => 3072,
        "cpus" => 4
      }
    ]
  }
end

puts "# Generated hosts entries for Vagrant VMs"
puts "# Current hostname: #{current_hostname}"
puts ""

# 遍历settings生成hosts条目
settings['vm'].each do |vm_config|
  puts "#{vm_config['ip']} #{vm_config['hostname']}"
end

puts ""
puts "# Copy the above lines to /etc/hosts" 