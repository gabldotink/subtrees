urllist() { # format: urllist url > file.csv
	wget --spider --no-parent --page-requisites \
	--mirror --force-html -e robots=off "$1" 2>&1 \
	| grep '^--' | awk '{print $3}'
}