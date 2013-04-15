class PmuFetcher
  # Returns the pathname of the file it downloaded to
  def download
    write_to_file(fetch_from_cognos)
  end

private

  def fetch_from_cognos
    puts "Fetching data from Cognos..."
    uri = URI("https://reporting.northwestern.edu/sso/app/cgi-bin/cognosisapi.dll?b_action=cognosViewer&&CAMUsername=#{Settings.pmu.username}&CAMPassword=#{Settings.pmu.password}&CAMNamespace=ADS&ui.action=run&ui.object=%2fcontent%2ffolder[%40name%3d'PMU']%2freport[%40name%3d'PMU%20Organizational%20Data']&ui.name=PMU%20Organizational%20Data&run.outputFormat=XML&run.prompt=false&cv.header=false&cv.toolbar=false")

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true
    # http.set_debug_output $stderr

    req = Net::HTTP::Get.new uri.request_uri

    response = http.request req
    puts "Got response. Cleaning..."
    strip_html(response.body)
  end

  # The URL they've given us returns the XML we want wrapped in HTML. This strips it out
  # and gives us just the data we want.
  def strip_html(body)
    body.partition(/<textarea (.*?)>/)[2].partition(/<\/textarea>/)[0]
  end

  # Returns the path name
  def write_to_file(string)
    path = File.expand_path("#{Rails.root}/tmp/pmu-#{now_string}.xml", File.dirname(__FILE__))
    puts "Saving to file: #{path}"
    File.open path, 'w' do |f|
      f.write(string)
    end
    path
  end

  def now_string
    Time.zone.now.strftime("%Y-%m-%d.%H-%M")
  end


end