#!/bin/bash -x

version=4.1.0
source_path=_output/SOURCES

mkdir -p ${source_path}

# NOTE(dulek): rpmbuild requires that inside the tar there will be a
#              ${service}-${version} directory, hence this --transform option.
#              Also note that for some reason it doesn't work without excluding
#              .git directory. Excluding .tox is convenient for local builds.
tar -czvf ${source_path}/kuryr-kubernetes.tar.gz --exclude=.git --exclude=.tox --transform "flags=r;s|\.|kuryr-kubernetes-${version}|" .
cp kuryr.logrotate ${source_path}
cp kuryr-controller.service ${source_path}
cp openshift-kuryr.tmpfs ${source_path}
cp kuryr-cni.service ${source_path}

# FIXME(dulek): For some reason python2-pbr is not available in CI ecosystem.
#               I'm injecting it from the repo, but need to fix this.
yum install -y python2-pbr-3.1.1-3.el7ar.noarch.rpm python-devel

rpmbuild -ba -D "_topdir `pwd`/_output" openshift-kuryr-kubernetes.spec
createrepo _output/RPMS/noarch
