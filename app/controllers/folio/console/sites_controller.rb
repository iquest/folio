# frozen_string_literal: true

module Folio
  class Console::SitesController < Console::BaseController
    def index
      redirect_to console_root_path
    end

    def edit
    end

    def update
      @site.update(site_params)
      respond_with @site, location: edit_console_site_path(@site)
    end

    private

      def site_params
        params.require(:site).permit(:title,
                                     :description,
                                     :domain,
                                     :locale,
                                     :google_analytics_tracking_code,
                                     :facebook_pixel_code,
                                     :phone,
                                     :email,
                                     :address,
                                     *@site.class.additional_params,
                                     locales: [],
                                     social_links: Site.social_link_sites)
      end
  end
end
