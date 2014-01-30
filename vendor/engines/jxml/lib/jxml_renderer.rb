class JxmlRenderer
  def self.render(from_dir, to_dir = nil)
    return if JxmlHoliday.today?
    raise 'Must specify a directory to render in' unless from_dir

    today = Date.today.to_s
    window_start = window_end = Time.zone.parse("#{today} 17:00:00")

    begin
      window_start = window_start - 1.day
    end while JxmlHoliday.is? window_start.to_date

    journals=Journal.where('created_at >= ? AND created_at < ? AND is_successful IS NULL', window_start, window_end).all

    return if journals.empty?

    xml_name="#{today.gsub(/-/,'')}_CCC_UPLOAD.XML"
    xml_src=File.join(from_dir, xml_name)

    av = build_view

    File.open(xml_src, 'w') do |xml|
      journals.each do |journal|
        av.assign( journal: journal, journal_rows: journal.journal_rows )
        # props to http://www.omninerd.com/articles/render_to_string_in_Rails_Models_or_Rake_Tasks
        xml << av.render(:template => 'facility_journals/show.xml.haml')
        puts av.render(:template => 'facility_journals/jxml.text.haml')
        puts
      end
    end

    FileUtils.mv xml_src, File.join(to_dir, xml_name) if to_dir
  end

  def self.build_view
    av = ActionView::Base.new

    # Engine path should take precedence
    av.view_paths << File.expand_path('../app/views', File.dirname(__FILE__))
    av.view_paths << File.expand_path("#{Rails.root}/app/views")

    av
  end

end
