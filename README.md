# NVIMd

## Introduction

Neovim is a pretty interesting piece of software. Community-driven, plugin-centric, it has so much features it can practically become your full-time job to just set it up the way you like.

Since every plugin is maintained by anyone really, this has some pretty interesting security implications as well: 

***Any plugin you have is untrusted code from an internet strangers running as your user***

Here's a best-effort-given-just-how-little-time-I-have attempt at mitigating this to make me more comfortable using a fully-loaded Neovim environment in my day-to-day. 

It's basically a Docker wrapper that installs all your plugin, build an image, and runs neovim inside it while mounting the local directory as a volume.

That way, you can have some level of confidence that the only thing you might be sharing with internet strangers would be the directory you chose to run NVIMd from.

Think of it like a workspace...

Note: For all the security implications that this entails, the container runs the app as root. I'd suggest running rootless containers on Linux for this reason.

## HOWTO

###REQUIREMENTS

- Have a container environment setup. Anything docker-compatible should do. I'm using `nerdctl` and `containerd` without any problems. 
- I strongly recommend running unprivileged containers if you're on Linux. [This gives a good overview](https://www.tutorialworks.com/podman-rootless-volumes/)
  
###STEPS

1. Get the repo: `git clone --recursive https://github.com/Selora/NVIMd`
2. Build the image: `nerdctl build . -t nvimd`
3. Test it: `nerdctl run -it --rm -v (pwd):/workspace nvimd`
4. Make an alias...

Important notes: Since you might be tempted to change the Neovim configuration while using it inside docker, any changes to the baseline configuration repo will be diffed and a patch file will be create inside a hidden directory `.nvimd_diffpatches`.
