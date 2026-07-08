module Upright::ApplicationHelper
  def current_or_default_site
    Upright::Current.site || Upright.sites.first
  end

  def site_name(site)
    "#{country_flag(site.country)} #{site.city}"
  end

  def page_title_tag(app_name = "Upright")
    tag.title [ @page_title, app_name ].compact.join(" · ")
  end

  def upright_stylesheet_link_tag(**options)
    Upright::Engine.root.join("app/assets/stylesheets/upright").glob("*.css")
      .map { |f| "upright/#{f.basename('.css')}" }.sort
      .then { |stylesheets| stylesheet_link_tag(*stylesheets, **options) }
  end

  private

  def country_flag(country_code)
    country_code&.upcase&.gsub(/[A-Z]/) { |c| (c.ord + 0x1F1A5).chr(Encoding::UTF_8) }
  end
end
