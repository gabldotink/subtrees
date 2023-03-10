#!/usr/bin/env bash
# find domains with format ia######.us.archive.org
# CC0 Public Domain
# [gist url]

unset n
declare -i n='0'

until [[ "${n}" -gt 9 ]]; do
	if curl -s https://ia00000"${n}".us.archive.org &> /dev/null; then
		printf "00000%d\n" "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 99 ]]; do
	if curl -s https://ia0000"${n}".us.archive.org &> /dev/null; then
		printf "0000%d\n" "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 999 ]]; do
	if curl -s https://ia000"${n}".us.archive.org &> /dev/null; then
		printf "000%d\n" "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 9999 ]]; do
	if curl -s https://ia00"${n}".us.archive.org &> /dev/null; then
		printf "00%d\n" "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 99999 ]]; do
	if curl -s https://ia0"${n}".us.archive.org &> /dev/null; then
		printf "0%d\n" "${n}"
	fi
	declare -i n="${n}+1"
done

until [[ "${n}" -gt 999999 ]]; do
	if curl -s https://ia"${n}".us.archive.org &> /dev/null; then
		printf "%d\n" "${n}"
	fi
	declare -i n="${n}+1"
done

printf "finished\n" 1>&2
printf "note that if you had an unstable connection while searching, some domains may have been missed\n" 1>&2
