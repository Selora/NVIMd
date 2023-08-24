#!/bin/bash
# entrypoint.sh

nvim /workspace

echo "Checking commit diffs"
cd /home/nvim-user/.config/nvim
#git diff > /workspace/nvimd.patch

files=$(git status --porcelain --ignored | grep -E "^\s?(M|A|R|RM|\?\?)" | awk '{print $NF}' | git check-ignore --stdin --no-index --non-matching --verbose)
git status --porcelain --ignored | grep -E "^\s?(M|A|R|RM|\?\?)" | awk '{print $NF}' | git check-ignore --stdin --no-index --non-matching --verbose

read
# Check if files are non-empty and create diff for them
if [[ ! -z $files ]]; then
  timestamp=$(date +%Y%m%d%H%M%S)
  random=$(shuf -i 0-10000 -n 1)
  echo $files
  git add . 
  git diff HEAD -- $files > /workspace/NVIMd-config_changes_${timestamp}_${random}.patch
  read
 # git diff --cached > changes_${timestamp}_${random}.patch
fi
