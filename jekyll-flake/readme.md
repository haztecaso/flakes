# Jekyll flake with plugins

## Update gems

- Modify [Gemfile](./Gemfile)
- Update [gemset.nix](/gemset.nix)
  ```bash
  nix-shell -p bundler -p bundix --run 'bundler update; bundler lock; bundler package --no-install --path vendor; bundix; rm -rf vendor'
  ```
