require "spec_helper"
require "serverspec"

package = case os[:family]
          when "freebsd"
            "devel/py-buildbot-worker"
          end
service = case os[:family]
          when "freebsd"
            "buildbot-worker"
          end
config_dir = case os[:family]
             when "freebsd"
               "/usr/local/etc/buildbot_worker"
             end
config  = "#{config_dir}/buildbot.tac"
user    = "buildbot"
group   = "buildbot"
default_group = case os[:family]
               when "freebsd"
                 "wheel"
               else
                 "root"
               end
default_user = "root"

describe package(package) do
  it { should be_installed }
end

describe file config_dir do
  it { should be_directory }
  it { should be_grouped_into group }
  it { should be_owned_by user }
  it { should be_mode 755 }
end
describe file(config) do
  it { should be_file }
  it { should be_grouped_into user }
  it { should be_owned_by group }
  it { should be_mode 644 }
  its(:content) { should match Regexp.escape("Managed by ansible") }
  its(:content) { should match(/workername = 'test-worker'/) }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/buildbot_worker") do
    it { should be_file }
    it { should be_grouped_into default_group }
    it { should be_owned_by default_user }
    it { should be_mode 644 }
    its(:content) { should match Regexp.escape("Managed by ansible") }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end
