require "rails_helper"

RSpec.describe JxmlRenderer do
  let(:weekday) { Date.parse("2013-02-14") }
  let(:weekend) { Date.parse("2013-02-16") }

  describe "rendering with respect to today's date", :time_travel do
    let(:renderer) { described_class.new("/tmp") }

    describe "on weekends" do
      let(:now) { weekend }

      it "does not render" do
        expect(renderer).not_to receive(:render!)
        renderer.render
      end
    end

    describe "on a holiday" do
      let(:now) { weekday }

      before { JxmlHoliday.create! date: weekday }

      it "does not render" do
        expect(renderer).not_to receive(:render!)
        renderer.render
      end
    end

    describe "on a regular weekday" do
      let(:now) { weekday }
      it "renders" do
        expect(renderer).to receive(:render!)
        renderer.render
      end
    end
  end

  describe "rendering", :time_travel do
    let(:now) { weekday }

    let(:journal) { double("Journal", journal_rows: []) }
    let(:relation) { double("ActiveRecord::Relation", all: [journal]) }
    let(:action_view) { double("ActionView::Base", render: nil, assign: nil, view_paths: []) }

    before :each do
      allow(Journal).to receive(:where).and_return relation
      allow(ActionView::Base).to receive(:new).and_return action_view

      allow(FileUtils).to receive(:mv)
      allow(File).to receive(:open).and_yield []
    end

    describe "argument effects" do
      it "does not move a file when to_dir param is nil" do
        expect(FileUtils).not_to receive :mv
        JxmlRenderer.render "/tmp"
      end

      it "moves a file when to_dir param is present" do
        expect(FileUtils).to receive :mv
        JxmlRenderer.render "/tmp", "/tmp"
      end
    end

    describe "query window" do
      it "makes Friday the start day when running after the weekend" do
        JxmlHoliday.create! date: weekend
        JxmlHoliday.create! date: weekend + 1.day
        friday = weekend - 1.day
        monday = weekend + 2.days
        it_should_create_the_window friday, monday
      end

      it "makes 2 days ago the start day when running day after a holiday" do
        JxmlHoliday.create! date: weekday
        before_holiday = weekday - 1.day
        after_holiday = weekday + 1.day
        it_should_create_the_window before_holiday, after_holiday
      end

      def it_should_create_the_window(window_start, window_end)
        allow(Date).to receive(:today).and_return window_end
        start_date = Time.zone.parse("#{window_start} 17:00:00")
        end_date = Time.zone.parse("#{window_end} 17:00:00")
        expect(Journal).to receive(:where).with "created_at >= ? AND created_at < ? AND is_successful IS NULL", start_date, end_date
        JxmlRenderer.render "/tmp"
      end
    end

    it "raises an error if no from_dir is specified" do
      expect { JxmlRenderer.render }.to raise_error(ArgumentError)
    end

    it "creates an ActionView with this engine's template" do
      templates_path = File.expand_path "../../app/views", File.dirname(__FILE__)
      expect(ActionView::Base).to receive(:new)
      JxmlRenderer.render "/tmp"
    end

    it "opens the correct file" do
      from_dir = "/tmp"
      today = Date.today.to_s
      xml_name = "#{today.delete('-')}_CCC_UPLOAD.XML"
      xml_src = File.join(from_dir, xml_name)
      expect(File).to receive(:open).with(xml_src, "w")
      JxmlRenderer.render "/tmp"
    end

    it "renders this engine's templates" do
      expect(action_view).to receive(:assign).with(
        journal: journal, journal_rows: journal.journal_rows,
      )
      expect(action_view).to receive(:render).with(
        template: "facility_journals/show.xml.haml",
      )

      expect(action_view).to receive(:render).with(
        template: "facility_journals/jxml.text.haml",
      )

      JxmlRenderer.render "/tmp"
    end
  end
end
