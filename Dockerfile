FROM alpine:edge

# Adding testing repos to apk
# Currently only for ruff
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update

# Install neovim and curl (for plugin manager)
RUN apk add --no-cache neovim neovim-doc curl git ripgrep fzf fd unzip wget gzip bash fish shadow tmux
# Install a compiler for mason
RUN apk add --virtual dev-env build-base gcc tree-sitter tree-sitter-cli
RUN apk add --virtual dev-env-go go
# NPM required for pylint?
RUN apk add --virtual dev-env-python python3 py3-pip npm black py3-pylint py3-isort ruff
# Terraform env. Not needed, taken care of by Mason
#RUN apk add --virtual dev-env-terraform tflint terraform terraform-ls

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN echo 'export LC_ALL=en_US.UTF-8' >> /etc/profile.d/locale.sh && \
  sed -i 's|LANG=C.UTF-8|LANG=en_US.UTF-8|' /etc/profile.d/locale.sh

# Building locale
#RUN locale

# Create a non-root user and give it ownership of /workspace and /home/user
RUN mkdir /workspace
RUN mkdir ~/.config

# Copy your Neovim configuration file
#ADD --chown=nvim-user:nvim-user ./nvim /home/nvim-user/.config/nvim
#WORKDIR /home/nvim-user/.config
RUN git clone https://github.com/Selora/NVIMd-config ~/.config/nvim

WORKDIR /workspace

# Setup plugins 
RUN nvim --headless +LazyUpdate +qa
RUN nvim --headless +MasonUpdate +qa
# This seems impossible to do this without vim auto-quitting.
# See https://github.com/nvim-treesitter/nvim-treesitter/issues/2533
RUN nvim --headless +TSUpdateSync +qa 
RUN timeout 60 nvim --headless +TSInstallSync c cpp bash fish html xml javascript json csv yaml bash fish || exit 0

# Mason Terraform env
RUN nvim --headless "+MasonInstall terraform-ls tflint" +qa

# Mason python env
# !TODO

## Start Neovim when the container is run
COPY --chmod=0755 ./entrypoint.sh /root/entrypoint.sh
#ADD --chmod=0755 ./entrypoint.sh ~/entrypoint.sh

# Switch back to root user for the rest, so it works with rootless containers with GUID remapping as well
ENTRYPOINT ["/root/entrypoint.sh"]
#CMD ["nvim"]
