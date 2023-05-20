#!/usr/bin/env bash

set -o errexit
set -o xtrace

exit_code=0

# Iterate over all the YAML files in the repository.
while IFS= read -r -d '' file; do
	# Format the YAML file.
	cp "${file}" "${file}.formatted"
	yq --inplace "${file}.formatted"

	# Compare the original vs the formatted.
	diff -u "${file}" "${file}.formatted" || exit_code=$?

	# Cleanup.
	rm "${file}.formatted"
done < <(find "./.github" -type f \( -name "*.yml" -o -name "*.yaml" \) -print0)

exit "${exit_code}"
