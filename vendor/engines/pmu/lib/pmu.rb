module Pmu

  class Engine < Rails::Engine

    config.autoload_paths << File.join(File.dirname(__FILE__), "../lib")
    config.i18n.load_path.unshift(*Dir[root.join("config", "locales", "**", "*.{rb,yml}").to_s])

    config.to_prepare do
      NufsAccount.send :include, Pmu::NufsAccountExtension

      ::Reports::GeneralReportsController.reports[:department] = Pmu::ReportsExtension.general_report
      ::Reports::InstrumentReportsController.reports[:department] = Pmu::ReportsExtension.instrument_report
      ::Reports::ExportRaw.transformers << "Pmu::Reports::ExportRawTransformer"
    end

  end

end
