# urllist | source: https://gist.github.com/gabldotink/91a749a83dbc75af71e720999d0bbfd6
urllist() { # usage: urllist url "wget options" > file.csv
	wget --spider --no-parent --mirror \
	--force-html -e robots=off "${1}" 2>&1 \
	| grep '^--' | awk '{print $3}' | awk '!seen[$0]++'
}
