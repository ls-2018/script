#!/usr/bin/env ruby

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

# 生成hosts内容并赋给变量
hosts_content = []
hosts_content << "# Generated hosts entries for Vagrant VMs"
hosts_content << "# Current hostname: #{current_hostname}"
hosts_content << ""

# 遍历settings生成hosts条目
settings['vm'].each do |vm_config|
  hosts_content << "#{vm_config['ip']} #{vm_config['hostname']}"
end

hosts_content << ""
hosts_content << "# Copy the above lines to /etc/hosts"

# 将内容合并为一个字符串
hosts_string = hosts_content.join("\n")

puts "=== Generated HOSTS_CONTENT ==="
puts hosts_string
puts "=== End HOSTS_CONTENT ==="

puts "\n=== Testing environment variable simulation ==="
puts "HOSTS_CONTENT='#{hosts_string}'"
puts "\n=== Testing echo command simulation ==="
puts "echo \"$HOSTS_CONTENT\" would output:"
puts hosts_string

puts "\n=== Testing printf command simulation ==="
puts "printf \"%s\\n\" \"$HOSTS_CONTENT\" would output:"
printf "%s\n", hosts_string

puts "\n=== Hex dump of the string ==="
require 'stringio'
io = StringIO.new
hosts_string.each_byte do |byte|
  io.printf "%02x ", byte
end
puts io.string 