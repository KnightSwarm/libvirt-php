#!/bin/bash

nf=$1
tests=( "test-connect" "test-version-check" "test-version-get" "test-domain-define-undefine" "test-domain-define-create-destroy" "test-domain-create"
	"test-domain-create-and-get-xpath" "test-domain-create-and-coredump" "test-logging" "test-conn-limit" "test-get-emulator" "test-install" )

run_test()
{
	local name=$1
	local nf=$2
	ret=0

	php $name.phpt
	if [ "x$?" != "x0" ]; then
		if [ "x$nf" == 'x1' ]; then
			ret=1
		else
			exit 1
		fi
	fi

	return $ret
}

touch /tmp/test-libvirt-php.tmp

error=0
for atest in ${tests[@]}
do
	run_test $atest $nf; ret="$?"

	if [ "x$ret" == "x1" ]; then
		error=1
	fi
done

qemu-img create -f qcow2 /tmp/example-test.qcow2 1M > /dev/null
run_test "test-domain-snapshot" $nf; ret="$?"
if [ "x$ret" == "x1" ]; then
	error=1
fi
rm -f /tmp/example-test.qcow2

if [ "x$error" == "x0" ]; then
	echo "All tests passed successfully"
else
	echo "Some (or all) of the tests have failed"
fi

rm -f /tmp/test-libvirt-php.tmp
exit $error
