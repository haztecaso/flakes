# flakes

To add a dir as a flake input:
```nix
{
  inputs = {
    moodle-dl.url = "github:haztecaso/flakes?dir=moodle-dl";
    jekyll-flake.url = "github:haztecaso/flakes?dir=jekyll-flake";
  };
}
```
