namespace :pmu do

  desc "fetches NU's PMU file, parses it, and loads it in the DB"
  task :import => :environment do
    settings_path = File.expand_path('../../config/settings.yml', File.dirname(__FILE__))
    puts "loading #{settings_path}"
    Settings.add_source!(settings_path)
    Settings.reload!

    fetcher = PmuFetcher.new
    pmu_path = fetcher.download

    # read as binary so we can get the whole doc as a string
    pmu_xml = File.open pmu_path, 'rb' do |file|
      file.read
    end

    p "Parsing XML in #{pmu_path}..."
    parse_and_load_xml pmu_xml
    p "Done!"
  end

  def parse_and_load_xml(xml_as_string)
    # Use SAX to parse the PMU because:
    # A) It's faster than DOM
    # B) We only ever care about one row at a time
    # C) There are no attributes on value elements,
    # so we're forced to rely on their document order.
    # With SAX document order is more apparent.
    parser = Nokogiri::XML::SAX::Parser.new PmuDocument.new
    parser.parse xml_as_string
  end



end
