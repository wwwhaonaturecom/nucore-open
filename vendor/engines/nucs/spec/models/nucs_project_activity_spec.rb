require "rails_helper"
require "nucs_spec_helper"

RSpec.describe NucsProjectActivity do
  { project: [8, 15], activity: [2, 15] }.each do |k, v|
    min = v[0]
    max = v[1]
    it { is_expected.not_to allow_value(mkstr(min, "a")).for(k) }
    it { is_expected.not_to allow_value(mkstr(min, "A")).for(k) }
    it { is_expected.not_to allow_value(mkstr(min - 1)).for(k) }
    it { is_expected.not_to allow_value(mkstr(max + 1)).for(k) }
    it { is_expected.to allow_value(mkstr(min)).for(k) }
  end

  it "tokenizes. Should return an Array of size 3 on a valid, full line" do
    source_line = "40000137|01|Sundry Persons for CAS & Sch o|31-DEC-23|31-AUG-49|"
    tokens = NucsProjectActivity.tokenize_source_line(source_line)
    expect(tokens).to be_a_kind_of(Array)
    expect(tokens.size).to eq(3)
    sep_ndx = source_line.index(NucsSourcedFromFile::NUCS_TOKEN_SEPARATOR)
    expect(tokens[0]).to eq(source_line[0...sep_ndx])
    nxt_sep_ndx = source_line.index(NucsSourcedFromFile::NUCS_TOKEN_SEPARATOR, sep_ndx + 1)
    expect(tokens[1]).to eq(source_line[sep_ndx + 1...nxt_sep_ndx])
    expect(tokens[2]).to eq(source_line[nxt_sep_ndx + 1..-1])
  end

  it "tokenizes. Should return an Array of size 2 if no auxiliary data is present" do
    source_line = "40000137|01|"
    tokens = NucsProjectActivity.tokenize_source_line(source_line)
    expect(tokens).to be_a_kind_of(Array)
    expect(tokens.size).to eq(2)
    sep_ndx = source_line.index(NucsSourcedFromFile::NUCS_TOKEN_SEPARATOR)
    expect(tokens[0]).to eq(source_line[0...sep_ndx])
    nxt_sep_ndx = source_line.index(NucsSourcedFromFile::NUCS_TOKEN_SEPARATOR, sep_ndx + 1)
    expect(tokens[1]).to eq(source_line[sep_ndx + 1...nxt_sep_ndx])
  end

  ["4000013701Sundry Persons for CAS & Sch o31-DEC-2331-AUG-49",
   "4000013701Sundry Persons for CAS & Sch o31-DEC-2331-AUG-49|",
   "40000137|01Sundry Persons for CAS & Sch o31-DEC-2331-AUG-49"].each do |line|
    it "tokenizes. Should raise an error on #{line}" do
      assert_raises NucsErrors::ImportError do
        NucsProjectActivity.tokenize_source_line(line)
      end
    end
  end

  it "creates. Should make a new record on line with no auxiliary data" do
    source_line = "40000137|01|"
    tokens = NucsProjectActivity.tokenize_source_line(source_line)
    pa = NucsProjectActivity.create_from_source(tokens)
    expect(pa).to be_a_kind_of(NucsProjectActivity)
    expect(pa).not_to be_new_record
    expect(pa.project).to eq(tokens[0])
    expect(pa.activity).to eq(tokens[1])
  end

  it "creates. Should make a new record on line with auxiliary data" do
    source_line = "40000137|01|Sundry Persons for CAS & Sch o|31-DEC-23|31-AUG-49|"
    tokens = NucsProjectActivity.tokenize_source_line(source_line)
    pa = NucsProjectActivity.create_from_source(tokens)
    expect(pa).to be_a_kind_of(NucsProjectActivity)
    expect(pa).not_to be_new_record
    expect(pa.project).to eq(tokens[0])
    expect(pa.activity).to eq(tokens[1])
    expect(pa.auxiliary).to eq(tokens[2])
  end

  it "fails to creates. Should return an invalid object on a valid line with invalid data" do
    source_line = "XXXXXXX|01|"
    tokens = NucsProjectActivity.tokenize_source_line(source_line)
    pa = NucsProjectActivity.create_from_source(tokens)
    expect(pa).to be_a_kind_of(NucsProjectActivity)
    expect(pa).to be_new_record
  end
end
