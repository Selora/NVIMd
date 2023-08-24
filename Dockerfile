FROM alpine:edge

# Adding testing repos to apk
# Currently only for ruff
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update

# Install neovim and curl (for plugin manager)
RUN apk add --no-cache neovim neovim-doc curl git ripgrep fzf fd unzip wget gzip bash fish shadow
# Install a compiler for mason
RUN apk add --virtual dev-env build-base gcc tree-sitter tree-sitter-cli
RUN apk add --virtual dev-env-go go
# NPM required for pylint?
RUN apk add --virtual dev-env-python python3 py3-pip npm black py3-pylint py3-isort ruff

# Create a non-root user and give it ownership of /workspace and /home/user
RUN adduser -D nvim-user \
    && mkdir /workspace \
    && chown -R nvim-user:nvim-user /workspace /home/nvim-user 

RUN chsh -s /usr/bin/fish nvim-user

# Switch to the new user
USER nvim-user

RUN mkdir /home/nvim-user/.config

# Copy your Neovim configuration file
#ADD --chown=nvim-user:nvim-user ./nvim /home/nvim-user/.config/nvim
#WORKDIR /home/nvim-user/.config
RUN git clone https://github.com/Selora/NVIMd-config /home/nvim-user/.config/nvim

WORKDIR /workspace

# Setup plugins 
RUN nvim --headless +LazyUpdate +qa
RUN nvim --headless +MasonUpdate +qa
# This seems impossible to do this without vim auto-quitting.
# See https://github.com/nvim-treesitter/nvim-treesitter/issues/2533
RUN nvim --headless +TSUpdateSync +qa 
#RUN timeout 60 nvim --headless +TSInstallSync c cpp bash fish html xml javascript json csv yaml bash fish

# Start Neovim when the container is run
COPY ./entrypoint.sh /home/nvim-user/entrypoint.sh
ADD --chmod=755 ./entrypoint.sh /home/nvim-user/entrypoint.sh
ENTRYPOINT ["/home/nvim-user/entrypoint.sh"]
#CMD ["nvim"]
