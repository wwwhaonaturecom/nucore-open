require 'spec_helper'
require 'controller_spec_helper'

describe InstrumentReportsController do
  before(:all) { create_users }

  before :each do
    @authable = Factory.create :facility
  end


  it 'should render a PMU report' do
    maybe_grant_always_sign_in :director
    @controller.expects(:render_report).with(8, 'Name')

    begin
      get :department, :facility_id => @authable.url_name
    rescue ActionView::MissingTemplate
      # I don't care about what template is rendered.
      # The main application's general_reports_controller_spec
      # tests the innards of the controller well. All I care
      # about is whether or not the correct method is called
      # with the right parameters. I'd love to test the block
      # param but I don't see a way to do it w/ Mocha
    end

  end

end
