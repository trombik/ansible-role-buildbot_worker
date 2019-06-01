require "spec_helper"
require "serverspec"

package = "buildbot_worker"
service = "buildbot_worker"
config  = "/etc/buildbot_worker/buildbot_worker.conf"
user    = "buildbot_worker"
group   = "buildbot_worker"
ports   = [PORTS]
log_dir = "/var/log/buildbot_worker"
db_dir  = "/var/lib/buildbot_worker"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/buildbot_worker.conf"
  db_dir = "/var/db/buildbot_worker"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("buildbot_worker") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/buildbot_worker") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
