FROM jmatsushita/gitpod-flake-ghc9:latest

RUN mkdir -p /home/gitpod/.config/nix && \
    echo 'sandbox = false' >> /home/gitpod/.config/nix/nix.conf && \
    mkdir -p /home/gitpod/.config/direnv && \
    echo '[whitelist]\nprefix = [ "/workspace/gitpod-flake-ghc9" ]' >> /home/gitpod/.config/direnv/direnv.toml
