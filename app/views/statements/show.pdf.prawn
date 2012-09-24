pdf_config={
  :left_margin   => 50,
  :right_margin  => 50,
  :top_margin    => 50,
  :bottom_margin => 75,
  :filename => "Statement-#{@statement.created_at.strftime("%m-%d-%Y")}.pdf",
  :force_download => true
}

unless (params[:show])
  pdf_config[:filename] = "Statement-#{@statement.created_at.strftime("%m-%d-%Y")}.pdf"
  pdf_config[:force_download] = true
end

prawn_document pdf_config do |pdf|
  vertical_gutter = 10
  pdf.font_size = 8
  
  pdf.define_grid(:columns => 2, :rows => 7)
  #b = pdf.grid(0,0)
  
  # NU LOGO
  logo_width = 124
  logo_height = 76
  pdf.image "#{Rails.root}/public/images/logo-nu-black.jpg", :width => logo_width, :height => logo_height, :at => pdf.bounds.top_left
  
  # INVOICE DETAILS BOX (TOP RIGHT)
  invoice_details_box_width = pdf.bounds.width / 2
  
  invoice_bounding_box = pdf.bounding_box [pdf.bounds.width / 2, pdf.bounds.top], :width => invoice_details_box_width do
    invoice_details = [["Invoice:", "#{@account.id}-#{@statement.id}"],
                       ["Date:", @statement.created_at.strftime("%m/%d/%Y")]]
    
    invoice_details << ["Purchase Order:", @account.account_number] if @account.is_a?(PurchaseOrderAccount)
    # Might bring this back if we find a good method for calculating billing period
    # invoice_details << ["Billing Period", "#{@statement.first_order_detail_date.strftime("%m/%d/%Y")} - #{@statement.created_at.strftime("%m/%d/%Y")}"];

    invoice_details_inner_table = pdf.make_table(invoice_details) do
      cells.style(:borders => [], :padding => 2, :width => invoice_details_box_width / 2)
    end
    
    pdf.table([[@facility.to_s], [invoice_details_inner_table]]) do
      row(0).style(:font_style => :bold, :background_color => 'cccccc', :size => 12, :width => invoice_details_box_width)
    end
  end
  
  second_row_box_width = pdf.bounds.width / 2 - 20
  # start below the taller of the top box and the image
  second_row_box_top = pdf.bounds.top - [invoice_bounding_box.height, logo_height].max - vertical_gutter

  # BILL TO TABLE  
  bill_to_box = pdf.bounding_box [pdf.bounds.left, second_row_box_top], :width => second_row_box_width do
    pdf.text "NET 30", :style => :bold
    pdf.table [["Bill To:"],
               [@account.remittance_information]] do
      row(0).style(:font_style => :bold, :background_color => 'cccccc')
      cells.style(:width => second_row_box_width)
    end
    pdf.move_down 5
    pdf.table [["User:", "#{@account.owner.user}\n#{@account.owner.user.email}"]] do
      column(0).style(:font_style => :bold)
      cells.style(:borders => [])
    end
  end

  # REMITTANCE INFO TABLE
  remit_to_box = pdf.bounding_box [pdf.bounds.width / 2, second_row_box_top], :width => second_row_box_width do
    pdf.text "\n" # extra line to balance the "NET 30" above the bill to table
    remit_table = pdf.table([["Remit To:"],
             [@facility.address]]) do
      row(0).style(:font_style => :bold, :background_color => 'cccccc')
      cells.style(:width => 200)
    end
  end
  
  
  # TRANSACTION LISTING
  bottom_of_second_row = [bill_to_box.absolute_bottom, remit_to_box.absolute_bottom].min - pdf.bounds.absolute_bottom 
  
  pdf.move_cursor_to(bottom_of_second_row - vertical_gutter)

  total_due = 0;
  rows = []
  @statement.order_details.includes(:order, :product).order('orders.ordered_at DESC').each do |od|
    total_due += od.actual_total
    item_description = "#{od.product}"
    item_description += "\n<i>#{od.note}</i>" if od.note
    rows << [
      od.order.ordered_at.strftime("%m/%d/%Y"),
      {:content => item_description, :inline_format => true},
      "#{od.quantity}",
      number_to_currency(od.actual_total/od.quantity),
      number_to_currency(od.actual_subsidy),
      number_to_currency(od.actual_total)
    ]
  end
  
  headers = ["Transaction Date", "Item Name", "Quantity", "Unit Cost", "Subsidy Amount", "Total Cost"]  
  footer = ["", "", "", "", "TOTAL DUE", number_to_currency(total_due)]
  
  pdf.table [headers] + rows + [footer], :header => true, 
            :width => pdf.bounds.width do
    cells.style(:borders => [], :inline_format => true)
    row(0).style(:font_style => :bold, :background_color => 'cccccc', :borders => [:top, :left, :bottom, :right])
    column(0).width = 80
    column(1).width = 200
    column(2..5).style(:align => :right)
    row(rows.size + 1).style(:font_style => :bold)
  end

  pdf.text "PLEASE MAKE ALL CHECKS PAYABLE TO: NORTHWESTERN UNIVERSITY", :style => :bold
  pdf.text @facility.name
  pdf.text "Phone: #{@facility.phone_number}" if @facility.phone_number
  pdf.text "Fax: #{@facility.fax_number}" if @facility.fax_number
  pdf.text "Email: #{@facility.email}" if @facility.email
  
  #pdf.number_pages "Page <page> of <total>", [0, -15]

end
