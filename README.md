# trombik.buildbot_worker

Install `buildbot-worker`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `buildbot_worker_user` | user name of `buildbot-worker` | `{{ __buildbot_worker_user }}` |
| `buildbot_worker_group` | group name of `buildbot-worker` | `{{ __buildbot_worker_group }}` |
| `buildbot_worker_package` | package name of `buildbot-worker` | `{{ __buildbot_worker_package }}` |
| `buildbot_worker_extra_packages` | list of extra packages to install | `[]` |
| `buildbot_worker_service` | service name of `buildbot-worker` | `{{ __buildbot_worker_service }}` |
| `buildbot_worker_root_dir` | root directory (and $HOME directory) of `buildbot-worker` | `{{ __buildbot_worker_root_dir }}` |
| `buildbot_worker_conf_dir` | configuration directory, usually same as `buildbot_worker_root_dir` | `{{ __buildbot_worker_conf_dir }}` |
| `buildbot_worker_conf_file` | path to configuration file, `buildbot.tac`| `{{ buildbot_worker_conf_dir }}/buildbot.tac` |
| `buildbot_worker_config` | content of `buildbot_worker_conf_file` | `""` |
| `buildbot_worker_flags` | content of startup script for `buildbot-worker` | `""` |


## Debian

| Variable | Default |
|----------|---------|
| `__buildbot_worker_user` | `buildbot` |
| `__buildbot_worker_group` | `buildbot` |
| `__buildbot_worker_service` | `buildbot-worker@default` |
| `__buildbot_worker_package` | `python3-buildbot-worker` |
| `__buildbot_worker_extra_packages` | `[]` |
| `__buildbot_worker_root_dir` | `/var/lib/buildbot` |
| `__buildbot_worker_conf_dir` | `{{ __buildbot_worker_root_dir }}/workers/default` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__buildbot_worker_user` | `buildbot` |
| `__buildbot_worker_group` | `buildbot` |
| `__buildbot_worker_service` | `buildbot-worker` |
| `__buildbot_worker_package` | `devel/py-buildbot-worker` |
| `__buildbot_worker_extra_packages` | `[]` |
| `__buildbot_worker_root_dir` | `/usr/local/buildbot_worker` |
| `__buildbot_worker_conf_dir` | `{{ __buildbot_worker_root_dir }}` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__buildbot_worker_user` | `_buildslave` |
| `__buildbot_worker_group` | `_buildslave` |
| `__buildbot_worker_service` | `buildbot_worker` |
| `__buildbot_worker_package` | `buildbot-worker` |
| `__buildbot_worker_extra_packages` | `[]` |
| `__buildbot_worker_root_dir` | `/var/buildslave` |
| `__buildbot_worker_conf_dir` | `{{ __buildbot_worker_root_dir }}` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - name: trombik.freebsd_pkg_repo
      when: ansible_os_family == 'FreeBSD'
    - ansible-role-buildbot_worker
  vars:
    os_buildbot_worker_flags:
      FreeBSD: |
        buildbot_worker_basedir="{{ buildbot_worker_conf_dir }}"
      # "
      Debian: |
        #WORKER_RUNNER=/usr/bin/buildbot-worker

        # 'true|yes|1' values in WORKER_ENABLED to enable instance and 'false|no|0' to
        # disable. Other values will be considered as syntax error.

        WORKER_ENABLED[1]=1                    # 1-enabled, 0-disabled
        WORKER_NAME[1]="default"               # short name printed on start/stop
        WORKER_USER[1]="buildbot"              # user to run worker as
        WORKER_BASEDIR[1]="{{ buildbot_worker_conf_dir }}"  # basedir to worker (absolute path)
        WORKER_OPTIONS[1]=""                   # buildbot options
        WORKER_PREFIXCMD[1]=""                 # prefix command, i.e. nice, linux32, dchroot
    # "

    buildbot_worker_flags: "{{ os_buildbot_worker_flags[ansible_os_family] | default('') }}"
    buildbot_worker_config: |
      import os
      from buildbot_worker.bot import Worker
      from twisted.application import service
      basedir = '{{ buildbot_worker_conf_dir }}'
      rotateLength = 10000000
      maxRotatedFiles = 10
      # if this is a relocatable tac file, get the directory containing the TAC
      if basedir == '.':
          import os.path
          basedir = os.path.abspath(os.path.dirname(__file__))
      # note: this line is matched against to check that this is a worker
      # directory; do not edit it.
      application = service.Application('buildbot-worker')
      from twisted.python.logfile import LogFile
      from twisted.python.log import ILogObserver, FileLogObserver
      logfile = LogFile.fromFullPath(
          os.path.join(basedir, "twistd.log"), rotateLength=rotateLength,
          maxRotatedFiles=maxRotatedFiles)
      application.setComponent(ILogObserver, FileLogObserver(logfile).emit)
      buildmaster_host = 'localhost'
      port = 9989
      workername = 'test-worker'
      passwd = 'pass'
      keepalive = 600
      umask = None
      maxdelay = 300
      numcpus = None
      allow_shutdown = None
      maxretries = None
      s = Worker(buildmaster_host, port, workername, passwd, basedir,
                 keepalive, umask=umask, maxdelay=maxdelay,
                 numcpus=numcpus, allow_shutdown=allow_shutdown,
                 maxRetries=maxretries)
      s.setServiceParent(application)

    # _______________________________________freebsd_pkg_repo
    # use my own packages because ones in ports have been broken.
    freebsd_pkg_repo:
      FreeBSD:
        enabled: "false"
        state: present
      # enable my own package repository, where the latest package is
      # available
      FreeBSD_devel:
        enabled: "true"
        state: present
        url: "http://pkg.i.trombik.org/{{ ansible_distribution_version | regex_replace('\\.', '') }}{{ansible_architecture}}-default-default/"
        mirror_type: http
        signature_type: none
        priority: 100
```

# License

```
Copyright (c) 2019 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
