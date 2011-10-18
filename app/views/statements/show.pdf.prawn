pdf_config={
  :left_margin   => 50,
  :right_margin  => 50,
  :top_margin    => 50,
  :bottom_margin => 75
}

prawn_document pdf_config do |pdf|

  pdf.font_size = 9
 
  # NU Logo
  pdf.image "#{Rails.root}/public/images/logo-nu.jpg"
  
  # INVOICE DETAILS
  invoice_details = [["Invoice:", "#{@account.id}-#{@statement.id}"],
            ["Date:", @statement.created_at.strftime("%m/%d/%Y")]];
  invoice_details << ["Purchase Order:", @account.account_number] if @account.is_a?(PurchaseOrderAccount)
  invoice_details << ["Billing Period", "#{@statement.first_order_detail_date.strftime("%m/%d/%Y")} - #{@statement.created_at.strftime("%m/%d/%Y")}"];
  
  invoice_details_inner_table = pdf.make_table(invoice_details) do |t|
    t.cells.style(:borders => [], :padding => 2)
    t.columns(0..1).style(:max_width => 80)
  end
  invoice_details_table = pdf.make_table([[@facility.to_s], [invoice_details_inner_table]]) do
    row(0).style(:style => :bold, :background_color => 'cccccc')
    column(0).style(:width => 160)
  end
  
  
  # BILL TO TABLE
  bill_to_table = pdf.make_table [["Bill To:"],
                     [@account.remittance_information]] do |t|
    t.row(0).style(:style => :bold, :background_color => 'cccccc')
  end
  
  # bill_to_details << [@facility.address] if @facility.address
  # bill_to_details << ["<b>Phone Number:</b> #{@facility.phone_number}"] if @facility.phone_number
  # bill_to_details << ["<b>Fax Number:</b> #{@facility.fax_number}"] if @facility.fax_number
  # billto_details << ["<b>Email:</b> #{@facility.email}"] if @facility.email
#   

  # REMITTANCE INFO TABLE
  remit_table = pdf.make_table([["Remit To:"],
             [@facility.address]]) do |t|
    t.row(0).style(:style => :bold, :background_color => 'cccccc')
  end

  # INFO LAYOUT
  pdf.table([["", invoice_details_table],
            ["NET 30", ""],
            ["bill_to_table", "remit_table"]]) do |t|
    t.column(0).style(:width => 255)
    t.column(1).style(:width => 255)
    #t.cells.style(:borders => [])            
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
  pdf.move_down(30)
  pdf.table([headers] + rows + [footer], :header => true, :width => 510) do
    cells.style(:borders => [])
    row(0).style(:style => :bold, :background_color => 'cccccc', :borders => [:top, :left, :bottom, :right])
    column(0).width = 80
    column(1).width = 200
    column(2..4).style(:align => :right)
    row(rows.size + 1).style(:style => :bold)
  end

  pdf.number_pages "Page <page> of <total>", [0, -15]

end