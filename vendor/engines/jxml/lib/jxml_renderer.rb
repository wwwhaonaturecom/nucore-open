class JxmlRenderer

  attr_reader :from_dir, :to_dir

  def initialize(from_dir, to_dir = nil)
    @from_dir = from_dir
    @to_dir = to_dir
  end

  def self.render(from_dir, to_dir = nil)
    new(from_dir, to_dir).render
  end

  def render
    raise ArgumentError.new("Must specify a directory to render in") unless from_dir
    return if JxmlHoliday.today?
    render!
  end

  def render!
    return if journals.empty?

    xml_name = "#{today.delete('-')}_CCC_UPLOAD.XML"
    xml_src = File.join(from_dir, xml_name)

    File.open(xml_src, "w") do |xml|
      journals.each do |journal|
        add_journal_to_file(xml, journal)
      end
    end

    FileUtils.mv xml_src, File.join(to_dir, xml_name) if to_dir
  end

  private

  def journals
    return @journals if @journals

    window_start = window_end = Time.zone.parse("#{today} 17:00:00")

    begin
      window_start -= 1.day
    end while JxmlHoliday.is? window_start.to_date

    @journals = Journal.where("created_at >= ? AND created_at < ? AND is_successful IS NULL", window_start, window_end).all
  end

  def add_journal_to_file(file, journal)
    action_view.assign(journal: journal, journal_rows: journal.journal_rows)
    # props to http://www.omninerd.com/articles/render_to_string_in_Rails_Models_or_Rake_Tasks
    file << action_view.render(template: "facility_journals/show.xml.haml")
    Rails.logger.info action_view.render(template: "facility_journals/jxml.text.haml")
  end

  def today
    Date.today.to_s
  end

  def action_view
    @action_view ||= ActionView::Base.new.tap do |av|
      # Engine path should take precedence
      av.view_paths << File.expand_path("../app/views", File.dirname(__FILE__))
      av.view_paths << File.expand_path("#{Rails.root}/app/views")
    end
  end

end
