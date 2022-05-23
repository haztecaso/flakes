# Jekyll flake with plugins

## Update gems

- Modify [Gemfile](./Gemfile)
- Update [Gemfile.lock](./Gemfile.lock) and [gemset.nix](./gemset.nix):
  ```bash
  nix flake run .\#lock
  ```
