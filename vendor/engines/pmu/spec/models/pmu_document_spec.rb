require 'spec_helper'

RSpec.describe PmuDocument do
  let(:parser) { Nokogiri::XML::SAX::Parser.new(PmuDocument.new) }
  let(:document) do
    <<-XML
    <dataset  xmlns="http://developer.cognos.com/schemas/xmldata/1/"  xmlns:xs="http://www.w3.org/2001/XMLSchema-instance">
    <metadata>
          <item name="Primary Management Unit ID" type="xs:string" length="16"/>
          <item name="PMU" type="xs:string" length="182"/>
          <item name="Area" type="xs:string" length="182"/>
          <item name="Division" type="xs:string" length="182"/>
          <item name="Organization" type="xs:string" length="182"/>
          <item name="FASIS Department ID" type="xs:string" length="22"/>
          <item name="FASIS Department Description" type="xs:string" length="62"/>
          <item name="NUFIN Department ID" type="xs:string" length="26"/>
          <item name="NUFIN Department Description" type="xs:string" length="62"/>
          <item name="Academic Org ID" type="xs:string" length="22"/>
          <item name="Academic Org Description" type="xs:string" length="102"/>
    </metadata>
    <data>
        <row>
            <value> 000180</value>
            <value>Alumni Relations &amp; Development</value>
            <value>Alumni Relations and Development</value>
            <value>Alumni Relations &amp; Development</value>
            <value>Alumni Relations &amp; Development</value>
            <value>080000</value>
            <value>Off of Alumni Relations&amp;Develo</value>
            <value xs:nil="true" />
            <value xs:nil="true" />
            <value xs:nil="true" />
            <value xs:nil="true" />
        </row>
        <row>
            <value> 000180</value>
            <value>Alumni Relations &amp; Development</value>
            <value>Alumni Relations and Development</value>
            <value>Alumni Relations &amp; Development</value>
            <value>Alumni Relations &amp; Development</value>
            <value xs:nil="true" />
            <value xs:nil="true" />
            <value>1610100</value>
            <value>Fundraising Salaries</value>
            <value xs:nil="true" />
            <value xs:nil="true" />
        </row>
        <row>
            <value> 000180</value>
            <value>Alumni Relations &amp; Development</value>
            <value>Alumni Relations and Development</value>
            <value>Alumni Relations &amp; Development</value>
            <value>Alumni Relations &amp; Development</value>
            <value xs:nil="true" />
            <value xs:nil="true" />
            <value>1610200</value>
            <value>Principal Gifts</value>
            <value xs:nil="true" />
            <value xs:nil="true" />
        </row>
    </data>
</dataset>
XML
  end


  it 'creates new departments' do
    expect { parser.parse document }.to change { PmuDepartment.count }.by(2)
  end

  it 'updates an existing department' do
    department = PmuDepartment.create(nufin_id: 1610200)
    expect(department.nufin_description).to be_blank
    expect { parser.parse document }.to change { PmuDepartment.count }.by(1)
    expect(department.reload.nufin_description).to eq('Principal Gifts')
  end

  it 'sets the fields properly' do
    parser.parse document
    department = PmuDepartment.first

    expect(department.unit_id).to eq(" 000180")
    expect(department.pmu).to eq("Alumni Relations & Development")
    expect(department.area).to eq("Alumni Relations and Development")
    expect(department.division).to eq("Alumni Relations & Development")
    expect(department.organization).to eq("Alumni Relations & Development")
    expect(department.fasis_id).to be_blank
    expect(department.fasis_description).to be_blank
    expect(department.nufin_id).to eq("1610100")
    expect(department.nufin_description).to eq("Fundraising Salaries")
  end
end
