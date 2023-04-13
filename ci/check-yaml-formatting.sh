#!/usr/bin/env sh

set -o errexit
set -o xtrace

exit_code=0

# Iterate over all the YAML files in the repository.
for file in $(find "." -type f -name "*.yml" -o -name "*.yaml"); do
	# Format the YAML file.
	cp "${file}" "${file}.formatted"
	yq --inplace "${file}.formatted"

	# Compare the original vs the formatted.
	diff -u "${file}" "${file}.formatted" || exit_code=$?

	# Cleanup.
	rm "${file}.formatted"
done

exit "${exit_code}"
