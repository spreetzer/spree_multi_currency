module Spree
  module Admin
    module GeneralSettingsControllerDecorator
      def self.prepended(base)
        before_action :update_currency_settings, only: :update
      end

      def render(*args)
        @preferences_currency |= [:allow_currency_change, :show_currency_selector, :supported_currencies]
        super
      end

      private

      def update_currency_settings
        params.each do |name, value|
          next unless Spree::Config.has_preference? name
          if name == 'supported_currencies'
            value = value.split(',').map { |curr| ::Money::Currency.find(curr.strip).try(:iso_code) }.concat([Spree::Config[:currency]]).uniq.compact.join(',')
          end
          Spree::Config[name] = value
        end
      end
    end
  end
end

(Spree::Admin::GeneralSettingsController.prepend Spree::Admin::GeneralSettingsControllerDecorator) if Spree.version.to_f >= 3.7
