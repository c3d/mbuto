#!/bin/sh -ef
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# mbuto - Minimal Builder Using Terse Options
#
# web/demo.sh: Prepare asciinema(1) demos and upload them to website
# 
# Copyright (c) 2022 Red Hat GmbH
# Author: Stefano Brivio <sbrivio@redhat.com>

setup_common() {
	export PS1='$ '
	tmux new-session -d -s mbuto

	tmux set -t mbuto window-status-format '#W'
	tmux set -t mbuto window-status-current-format '#W'
	tmux set -t mbuto status-left ''
	tmux set -t mbuto window-status-separator ''

	tmux set -t mbuto window-status-style 'bg=colour1 fg=colour15 bold'
	tmux set -t mbuto status-right ''
	tmux set -t mbuto status-style 'bg=colour1 fg=colour15 bold'
	tmux set -t mbuto status-right-style 'bg=colour1 fg=colour15 bold'
}

SCRIPT_base='
kvm -kernel /boot/vmlinuz-$(uname -r) -initrd $(./mbuto) \
	-nodefaults -nographic -append console=ttyS0 -serial stdio
##
echo Hello from the guest!
#
'

SCRIPT_kselftests='
cd ../net-next
ls
#
make -j $(nproc)
################
kvm -kernel arch/x86/boot/bzImage -initrd $(../mbuto/mbuto -p kselftests) \
  -m 4096 -cpu host -nodefaults -nographic -append console=ttyS0 -serial stdio
########################################
-
################################################################################
'

setup_base() {
	tmux rename-window -t mbuto 'Basic usage'
}

setup_kselftests() {
	tmux rename-window -t mbuto 'Running Linux kernel selftests'
}

cmd_write() {
	__str="${@}"
	while [ -n "${__str}" ]; do
		__rem="${__str#?}"
		__first="${__str%"$__rem"}"
		if [ "${__first}" = ";" ]; then
			tmux send-keys -t mbuto -l '\;'
		else
			tmux send-keys -t mbuto -l "${__first}"
		fi
		sleep 0.05 || :
		__str="${__rem}"
	done
	sleep 2
	tmux send-keys -t mbuto "C-m"
}

script() {
	IFS='
'
	for line in $(eval printf '%s\\\n' \$SCRIPT_${1}); do
		unset IFS
		case ${line} in
		"#"*)	sleep ${#line}		;;
		*)	cmd_write "${line}"	;;
		esac
		IFS='
'
	done
	unset IFS
}

teardown_base() {
	:
}

teardown_kselftests() {
	:
}

teardown_common() {
	sleep 5
	tmux kill-session -t mbuto
	sleep 5
}

printf '\e[8;22;80t'

for demo in base kselftests; do
	setup_common
	eval setup_${demo}
	asciinema rec --overwrite ${demo}.cast -c 'tmux attach -t mbuto' &
	sleep 1

	tmux send-keys -t mbuto -l 'reset'
	tmux send-keys -t mbuto C-m
	sleep 1
	tmux refresh-client

	script ${demo}
	teardown_common
	eval teardown_${demo}

	gzip -fk9 ${demo}.cast
	scp ${demo}.cast ${demo}.cast.gz mbuto.sh:/var/www/mbuto/static/
done
