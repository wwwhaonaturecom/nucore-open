module Acgt

  module SubmissionFormHelper

    def acgt_fill_clear_links(field)
      content_tag :div, class: "clearfix" do
        acgt_action_button("Fill", "js--sangerFillColumnFromFirst", field).safe_concat(
          acgt_clear_column_button(field))
      end
    end

    def acgt_checkbox_links(field)
      content_tag :div, class: "clearfix" do
        acgt_action_button("Select", "js--sangerCheckAll", field).safe_concat(
        acgt_action_button("Clear", "js--sangerUncheckAll", field))
      end
    end

    def acgt_clear_column_button(field)
      acgt_action_button("Clear", "js--sangerClearColumn", field)
    end

    def acgt_action_button(text, fill_class, field)
      link_to(text, "#", class: "#{fill_class} btn btn-mini", data: { selector: "[name*=#{field}]" })
    end

  end

end
