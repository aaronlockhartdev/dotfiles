#!/bin/bash

# Install Rust and rbw
if [ ! command -v cargo ]; then
    curl https://sh.rustup.rs -sSf | sh
    source "$HOME/.cargo/env"
fi
cargo install rbw

rbw config set base_url $BITWARDEN_HOST
rbw config set email $BITWARDEN_EMAIL
rbw config set pinentry "pinentry-tty"
