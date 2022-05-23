{ config, lib, pkgs }:
{
  options = with lib; {
    ruby-packages = mkOption {
      type = types.lines;
      default = ''
      '';
      example = ''
        jekyll-contentblocks
        jekyll-image-size
        jekyll-minifier
        jekyll-seo-tag
        jekyll-sitemap
        ruby-thumbor
      '';
    };
  };
}
