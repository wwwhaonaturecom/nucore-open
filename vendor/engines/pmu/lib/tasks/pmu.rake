namespace :pmu do

  desc "fetches NU's PMU file, parses it, and loads it in the DB"
  task :import => :environment do
    pmu_path = fetch_xml

    # read as binary so we can get the whole doc as a string
    pmu_file = File.open pmu_path, 'rb'
    pmu_xml = pmu_file.read
    pmu_file.close

    p "Parsing XML in #{pmu_path}..."
    parse_xml pmu_xml
    p "Done!"
  end


  def fetch_xml
    #uri = URI('https://reportingtest.northwestern.edu:443/sso/cgi-bin/cognosisapi.dll?b_action=cognosViewer&ui.action=run&ui.object=%2fcontent%2ffolder%5b%40name%3d%27PMU%27%5d%2freport%5b%40name%3d%27PMU%20Organizational%20Data%27%5d&ui.name=PMU%20Organizational%20Data&run.outputFormat=XML&run.prompt=false')
    #
    #http = Net::HTTP.new uri.host, uri.port
    #http.use_ssl = true
    #http.set_debug_output $stderr
    #
    #req = Net::HTTP::Get.new uri.request_uri
    #req.basic_auth 'baz492', 'nc;1501071st'
    #
    #response = http.request req
    File.expand_path('../../pmu.xml', File.dirname(__FILE__))
  end


  def parse_xml(xml_as_string)
    # A lot of department names have an ampersand, and the PMU isn't escaping
    # them properly in their XML. Convert here, but this will fail if they format
    # their XML properly in the future.
    xml_as_string.gsub! '&', '&amp;'

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
