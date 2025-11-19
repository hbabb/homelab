FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Add PPAs
RUN apt-get update && apt-get install -y software-properties-common \
  && add-apt-repository ppa:neovim-ppa/unstable \
  && add-apt-repository ppa:longsleep/golang-backports \
  && apt-get update

# Install everything from apt
RUN apt-get install -y \
  curl \
  wget \
  git \
  neovim \
  golang-go \
  zsh \
  ripgrep \
  fzf \
  fd-find \
  build-essential \
  fonts-firacode \
  fontconfig \
  stow \
  && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/lib/go/bin:/root/go/bin:${PATH}"
ENV GOPATH="/root/go"

# Install Rust from rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Clone and build Lazygit
WORKDIR /tmp/lazygit
RUN git clone https://github.com/jesseduffield/lazygit.git . \
  && go install \
  && cp /root/go/bin/lazygit /usr/local/bin/ \
  && rm -rf /tmp/lazygit

# Clone and build Zellij
WORKDIR /tmp/zellij
RUN git clone https://github.com/zellij-org/zellij.git . \
  && /root/.cargo/bin/cargo build --release \
  && cp target/release/zellij /usr/local/bin/ \
  && rm -rf /tmp/zellij

# Clone and install Starship
WORKDIR /tmp/starship
RUN git clone https://github.com/starship/starship.git . \
  && /root/.cargo/bin/cargo build --release \
  && cp target/release/starship /usr/local/bin/ \
  && rm -rf /tmp/starship

# Clone Oh-My-Zsh
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh \
  && cp /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc

# Clone LazyVim starter
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim \
  && rm -rf /root/.config/nvim/.git

# Clone Nerd Fonts and install FiraCode
WORKDIR /tmp/nerd-fonts
RUN git clone --depth 1 --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git . \
  && git sparse-checkout set patched-fonts/FiraCode \
  && mkdir -p /usr/share/fonts/truetype/firacode \
  && find patched-fonts/FiraCode -name "*.ttf" -exec cp {} /usr/share/fonts/truetype/firacode/ \; \
  && fc-cache -fv \
  && rm -rf /tmp/nerd-fonts

# Kitty terminfo
WORKDIR /tmp/kitty
RUN git clone https://github.com/kovidgoyal/kitty.git . \
  && tic -x -o /root/.terminfo terminfo/kitty.terminfo \
  && rm -rf /tmp/kitty

# Set zsh as default
RUN chsh -s $(which zsh)

# Add starship to zshrc
# RUN echo 'eval "$(starship init zsh)"' >> /root/.zshrc

RUN mkdir -p /root/.config/zellij && \
  echo 'default_shell "zsh"' > /root/.config/zellij/config.kdl

# Clone dotfiles and stow them
RUN git clone https://github.com/hbabb/dotfiles-devcontainers.git /root/dotfiles \
  && cd /root/dotfiles \
  && stow --adopt lazygit nvim oh-my-zsh starship zellij zsh

WORKDIR /workspace

ENV SHELL=/usr/bin/zsh

CMD ["zsh"]
