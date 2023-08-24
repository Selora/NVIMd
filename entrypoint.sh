#!/bin/bash
# entrypoint.sh

nvim /workspace

echo "Exiting... Checking for changes to neovim configuration..."
cd ~/.config/nvim
#git diff > /workspace/nvimd.patch

files=$(git status --porcelain --ignored | grep -E "^\s?(M|A|R|RM|\?\?)" | awk '{print $NF}' | git check-ignore --stdin --no-index --non-matching --verbose)
#git status --porcelain --ignored | grep -E "^\s?(M|A|R|RM|\?\?)" | awk '{print $NF}' | git check-ignore --stdin --no-index --non-matching --verbose

# Check if files are non-empty and create diff for them
if [[ ! -z $files ]]; then
	timestamp=$(date +%Y%m%d%H%M%S)
	random=$(shuf -i 0-10000 -n 1)
	echo "Detecting changes to neovim configuration:\n"
	echo $files

	filename=NVIMd-config_changes_${timestamp}_${random}.patch
	path_dir="/workspace/.nvimd_diffpatches"

	mkdir /workspace/.nvimd_diffpatches
	git add .
	git diff HEAD -- $files >$path_dir/NVIMd-config_changes_${timestamp}_${random}.patch

	echo "Saving diff to $path_dir/$filename"
	# git diff --cached > changes_${timestamp}_${random}.patch
fi
echo "Goodbye!"
