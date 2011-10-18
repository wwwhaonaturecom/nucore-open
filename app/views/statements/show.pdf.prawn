pdf_config={
  :left_margin   => 50,
  :right_margin  => 50,
  :top_margin    => 50,
  :bottom_margin => 75
}

prawn_document pdf_config do |pdf|

  pdf.font_size = 8
 
 
  # INFO LAYOUT
  
  pdf.define_grid(:columns => 2, :rows => 7)
  b = pdf.grid(0,0)
  pdf.bounding_box b.top_left, :width => b.width, :height => b.height do
    pdf.image "#{Rails.root}/public/images/logo-nu.jpg" 
  end
  
  
  
  b = pdf.grid(0,1)
  top_bounding = pdf.bounding_box b.top_left, :width => b.width + 80, :height => 300 do

  # INVOICE DETAILS
  invoice_details_width = 252
  invoice_details = [["Invoice:", "#{@account.id}-#{@statement.id}"],
      ["Date:", @statement.created_at.strftime("%m/%d/%Y")]];
  invoice_details << ["Purchase Order:", @account.account_number] if @account.is_a?(PurchaseOrderAccount)
  invoice_details << ["Billing Period", "#{@statement.first_order_detail_date.strftime("%m/%d/%Y")} - #{@statement.created_at.strftime("%m/%d/%Y")}"];

  invoice_details_inner_table = pdf.make_table(invoice_details) do
    cells.style(:borders => [], :padding => 2, :width => invoice_details_width / 2)
  end
    
  pdf.table([[@facility.to_s], [invoice_details_inner_table]]) do
    row(0).style(:style => :bold, :background_color => 'cccccc', :size => 12, :width => invoice_details_width)
  end

  end
  
  # BILL TO TABLE
  b = pdf.grid(1,0)
  pdf.bounding_box b.top_left, :width => 200, :height => b.height + 10 do
    pdf.table [["Bill To:"],
      [@account.remittance_information]] do
      row(0).style(:style => :bold, :background_color => 'cccccc')
      cells.style(:width => 200)
    end
    pdf.move_down 5
    pdf.table [["User:", "#{@account.owner.user}\n#{@account.owner.user.email}"]] do
      column(0).style(:style => :bold)
      cells.style(:borders => [])
    end
    
  end

  b = pdf.grid(1,1)
  pdf.bounding_box b.top_left, :width => b.width, :height => b.height do
  # REMITTANCE INFO TABLE
    remit_table = pdf.table([["Remit To:"],
             [@facility.address]]) do
      row(0).style(:style => :bold, :background_color => 'cccccc')
      cells.style(:width => 200)
    end
  end
  
  total_due = 0;
  rows = @statement.order_details.sort{|d,o| d.order.ordered_at<=>o.order.ordered_at}.reverse.map do |od|
    total_due += od.actual_total
    [
      od.order.ordered_at.strftime("%m/%d/%Y"),
      "#{od.product}",
      "#{od.quantity}",
      number_to_currency(od.price_policy.unit_cost),
      number_to_currency(od.actual_total)
    ]
  end
  
  headers = ["Transaction Date", "Item Name", "Quantity", "Unit Cost", "Total Cost"]
  
  footer = ["", "", "", "TOTAL DUE", number_to_currency(total_due)]
  pdf.move_down(5)
  pdf.table([headers] + rows + [footer], :header => true, :width => 510) do
    cells.style(:borders => [])
    row(0).style(:style => :bold, :background_color => 'cccccc', :borders => [:top, :left, :bottom, :right])
    column(0).width = 80
    column(1).width = 200
    column(2..4).style(:align => :right)
    row(rows.size + 1).style(:style => :bold)
  end

  pdf.text "PLEASE MAKE ALL CHECKS PAYABLE TO: NORTHWESTERN UNIVERSITY", :style => :bold
  pdf.text @facility.name
  pdf.text "Phone: #{@facility.phone_number}" if @facility.phone_number
  pdf.text "Fax: #{@facility.fax_number}" if @facility.fax_number
  pdf.text "Email: #{@facility.email}" if @facility.email
  
  #pdf.number_pages "Page <page> of <total>", [0, -15]

end