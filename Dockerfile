FROM gitpod/workspace-base

USER root

# Install Nix
RUN addgroup --system nixbld \
  && adduser gitpod nixbld \
  && for i in $(seq 1 30); do useradd -ms /bin/bash nixbld$i &&  adduser nixbld$i nixbld; done \
  && mkdir -p -m 0755 /nix && chown gitpod /nix \
  && mkdir -p -m 0755 /workspace && chown gitpod /workspace \
  && mkdir -p /etc/nix \
  && echo 'sandbox = false' >> /etc/nix/nix.conf \
  && echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf
  # && ln -s /workspace/gitpod-flake-ghc9/.nix /nix \
  # && mkdir -p -m 0755 /workspace/gitpod-flake-ghc9/.nix/nix && chown -R gitpod /workspace/gitpod-flake-ghc9/.nix \
  # && echo 'allow-symlinked-store = true' >> /etc/nix/nix.conf \
  # && echo 'allowed-uris = ["/workspace/gitpod-flake-ghc9/.nix"]' >> /etc/nix/nix.conf \

# Install Nix
USER gitpod
ENV USER gitpod
WORKDIR /home/gitpod

RUN touch .bash_profile \
  && curl https://releases.nixos.org/nix/nix-2.7.0/install | sh

RUN echo '. /home/gitpod/.nix-profile/etc/profile.d/nix.sh' >> /home/gitpod/.bashrc
RUN  mkdir -p /home/gitpod/.config/nixpkgs \
  && echo '{ allowUnfree = true; }' >> /home/gitpod/.config/nixpkgs/config.nix
  # mkdir -p /home/gitpod/.config/nix \
  # && echo 'store = /workspace/gitpod-flake-ghc9/.nix' >> /home/gitpod/.config/nix/nix.conf

# Install cachix
RUN . /home/gitpod/.nix-profile/etc/profile.d/nix.sh \
  && nix-env -iA cachix -f https://cachix.org/api/v1/install \
  && cachix use cachix

# Install git
RUN . /home/gitpod/.nix-profile/etc/profile.d/nix.sh \
  && nix profile install nixpkgs#git nixpkgs#git-lfs
  # && nix-env -iA git git-lfs
  # && nix registry add nixpkgs ~/.nix-defexpr/channels/nixpkgs \

# Install direnv
RUN . /home/gitpod/.nix-profile/etc/profile.d/nix.sh \
  && nix profile install nixpkgs#direnv \
  && direnv hook bash >> /home/gitpod/.bashrc

# Whitelist direnv workspace
RUN mkdir -p /home/gitpod/.config/nix \
  && echo 'sandbox = false' >> /home/gitpod/.config/nix/nix.conf \
  && mkdir -p /home/gitpod/.config/direnv \
  && echo '[whitelist]\nprefix = [ "/workspace" ]' >> /home/gitpod/.config/direnv/direnv.toml

CMD /bin/bash -c "bash"
