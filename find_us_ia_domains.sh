#!/usr/bin/env bash
# find domains with format ia######.us.archive.org
# CC0 Public Domain
# https://gist.github.com/gabldotink/02076e1c66935de876f6a59ac1cd16e7

unset n
declare -i n='0'

printf 'looking for domains\n' >&2

until [[ "${n}" -gt 9 ]]; do
	if curl -s https://ia00000"${n}".us.archive.org &> /dev/null; then
		printf 'https://ia00000%d.us.archive.org\n' "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 99 ]]; do
	if curl -s https://ia0000"${n}".us.archive.org &> /dev/null; then
		printf 'https://ia0000%d.us.archive.org\n' "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 999 ]]; do
	if curl -s https://ia000"${n}".us.archive.org &> /dev/null; then
		printf 'https://ia000%d.us.archive.org\n' "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 9999 ]]; do
	if curl -s https://ia00"${n}".us.archive.org &> /dev/null; then
		printf 'https://ia00%d.us.archive.org\n' "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 99999 ]]; do
	if curl -s https://ia0"${n}".us.archive.org &> /dev/null; then
		printf 'https://ia0%d.us.archive.org\n' "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 999999 ]]; do
	if curl -s https://ia"${n}".us.archive.org &> /dev/null; then
		printf 'https://ia%d.us.archive.org\n' "${n}"
	fi
	declare -i n="${n}+1"
done

printf 'finished\n' >&2
printf 'note that if you had an unstable connection while searching, some domains may have been missed\n' >&2
