{ config, lib, pkgs, ... }:
{
  options = with lib; {
    name = mkOption {
      type = types.str;
      default = "jekyll";
      description = "Package name.";
    };
    gems = mkOption {
      type = with types; listOf str;
      default = [];
      example = [
        "jekyll-contentblocks"
        "jekyll-image-size"
        "jekyll-minifier"
        "jekyll-seo-tag"
        "jekyll-sitemap"
        "ruby-thumbor"
      ];
      description = "Ruby dependencies.";
    };
  };
  config = {
    gems = [ "jekyll" ];
  };
}
