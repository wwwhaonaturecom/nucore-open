class PmuDocument < Nokogiri::XML::SAX::Document

  def initialize
    super
    @value = nil
    @attrs = nil
    @sequence_ndx = -1
    @value_sequence = [
      :unit_id,
      :pmu,
      :area,
      :division,
      :organization,
      :fasis_id,
      :fasis_description,
      :nufin_id,
      :nufin_description
    ]
  end


  def start_element(name, attributes = [])
    case name
      when 'value'
        @value = ''
        @sequence_ndx += 1
      when 'row'
        @attrs = {}
        @sequence_ndx = -1
    end
  end


  def characters(string)
    @value += string if @value && string.strip.present?
  end


  def end_element(name)
    case name
      when 'value'
        @attrs[ @value_sequence[@sequence_ndx] ] = @value
      when 'row'
        if @attrs[:nufin_id].present?
          dept = PmuDepartment.find_or_create_by_nufin_id @attrs[:nufin_id]
          dept.update_attributes! @attrs
        end
    end
  end

end
