#!/bin/bash
filename=$(curl -s http://cdn.opensuse.org/source/distribution/leap/16.0/repo/oss/src/ | grep 'glibc-2.*\.src\.rpm' | awk -F 'href="./' '{print $2}'|awk -F '"' '{print $1}'|head -n 1)
if [ -e "$filename" ]; then
echo File exist
exit
else
rm *.src.rpm
if [ -n "$filename" ]; then
wget "http://cdn.opensuse.org/source/distribution/leap/16.0/repo/oss/src/${filename}"
#script_name=$(basename "$0")
rpm2cpio $filename |cpio -idu
sed -i '1i\
%define _unpackaged_files_terminate_build 0' glibc.spec
LINE_NO=$(grep -n '# Install base glibc' glibc.spec| awk -F: '{print $1}')
LINE_NO=$(($LINE_NO+1))
awk -v line="$LINE_NO" '
NR > line && !done && /^$/ {print "mkdir -p %{buildroot}/usr/lib64;ln -s %{buildroot}/usr/lib64 %{buildroot}/usr/lib"; done=1; next}
{print}
' glibc.spec > .glibc.spec.tmp && mv .glibc.spec.tmp glibc.spec
fi
fi
