module Nu
  class StatementPdf < ::StatementPdf

    def generate(pdf)
      initialize_document(pdf)
      generate_document_header(pdf)
      generate_transaction_listing(pdf)
      generate_contact_info(pdf)
    end

    private

    def initialize_document(pdf)
      @total_due = 0
      @logo_height = 76
      @vertical_gutter = 10
      pdf.font_size = 8
      pdf.define_grid(columns: 2, rows: 7)
    end

    def generate_bill_to_details(pdf)
      pdf.bounding_box [pdf.bounds.left, @second_row_box_top], width: @second_row_box_width do
        generate_bill_to_bounding_box_content(pdf)
      end
    end

    def generate_bill_to_bounding_box_content(pdf)
      pdf.text 'NET 30', style: :bold
      generate_bill_to_table(pdf)
      pdf.move_down 5
      generate_bill_to_user_table(pdf)
    end

    def generate_bill_to_table(pdf)
      pdf.table [ ['Bill To:'], [@account.remittance_information] ] do
        row(0).style(LABEL_ROW_STYLE)
        cells.style(width: @second_row_box_width)
      end
    end

    def generate_bill_to_user_table(pdf)
      pdf.table [ ['User:', "#{@account.owner.user}\n#{@account.owner.user.email}"] ] do
        column(0).style(font_style: :bold)
        cells.style(borders: [])
      end
    end

    def generate_contact_info(pdf)
      pdf.text "PLEASE MAKE ALL CHECKS PAYABLE TO: NORTHWESTERN UNIVERSITY", style: :bold
      pdf.text @facility.name
      pdf.text "Phone: #{@facility.phone_number}" if @facility.phone_number
      pdf.text "Fax: #{@facility.fax_number}" if @facility.fax_number
      pdf.text "Email: #{@facility.email}" if @facility.email
    end

    def generate_document_header(pdf)
      generate_logo(pdf)
      generate_invoice_details(pdf)
      bill_to_box = generate_bill_to_details(pdf)
      remit_to_box = generate_remittance_information(pdf)

      bottom_of_second_row = [bill_to_box.absolute_bottom, remit_to_box.absolute_bottom].min - pdf.bounds.absolute_bottom
      pdf.move_cursor_to(bottom_of_second_row - @vertical_gutter)
    end

    def generate_invoice_bounding_box(pdf)
      box_width = pdf.bounds.width / 2

      pdf.bounding_box [pdf.bounds.width / 2, pdf.bounds.top], width: box_width do
        generate_invoice_bounding_box_content(pdf, box_width)
      end
    end

    def generate_invoice_bounding_box_content(pdf, box_width)
      invoice_details_inner_table = pdf.make_table(invoice_bounding_box_content) do
        cells.style(borders: [], padding: 2, width: box_width / 2)
      end

      pdf.table([ [@facility.to_s], [invoice_details_inner_table] ]) do
        row(0).style(LABEL_ROW_STYLE.merge(size: 12, width: box_width))
      end
    end

    def invoice_bounding_box_content
      content = [['Invoice:', "#{@statement.invoice_number}"],
                 ['Date:', @statement.created_at.strftime('%m/%d/%Y')]] # TK I18n

      content << ['Purchase Order:', @account.account_number] if @account.is_a?(PurchaseOrderAccount)
      content
    end

    def generate_invoice_details(pdf)
      invoice_bounding_box = generate_invoice_bounding_box(pdf)

      @second_row_box_width = pdf.bounds.width / 2 - 20
      # start below the taller of the top box and the image
      @second_row_box_top =
        pdf.bounds.top - [invoice_bounding_box.height, @logo_height].max - @vertical_gutter
    end

    def generate_logo(pdf)
      pdf.image(
        "#{Rails.root}/public/images/logo-nu-black.jpg",
        width: 124,
        height: @logo_height,
        at: pdf.bounds.top_left,
      )
    end

    def generate_remittance_information(pdf)
      pdf.bounding_box [pdf.bounds.width / 2, @second_row_box_top], width: @second_row_box_width do
        pdf.text "\n" # extra line to balance the "NET 30" above the bill to table
        pdf.table([['Remit To:'], [@facility.address]]) do
          row(0).style(LABEL_ROW_STYLE)
          cells.style(width: 200)
        end
      end
    end

    def generate_transaction_listing(pdf)
      order_detail_rows = generate_order_detail_rows
      pdf.table(
        [order_detail_headers] + order_detail_rows + [order_detail_footer],
        header: true,
        width: pdf.bounds.width
      ) do
        cells.style(borders: [], inline_format: true)
        row(0).style(LABEL_ROW_STYLE.merge(borders: [:top, :left, :bottom, :right]))
        column(0).width = 70
        column(1).width = 65
        column(2).width = 168
        column(3).width = 43
        column(4).width = 45
        column(3..6).style(align: :right)
        row(order_detail_rows.size + 1).style(font_style: :bold)
      end
    end

    def generate_order_detail_rows
      @statement.order_details.includes(:product).order('fulfilled_at DESC').map do |order_detail|
        @total_due += order_detail.actual_total
        [
          format_usa_date(order_detail.fulfilled_at),
          order_detail.to_s,
          { content: item_description(order_detail), inline_format: true },
          order_detail.quantity.to_s,
          number_to_currency(order_detail.actual_cost / order_detail.quantity),
          subsidy_display(order_detail),
          number_to_currency(order_detail.actual_total)
        ]
      end
    end

    def item_description(order_detail)
      description = "#{order_detail.product}"
      description += "\n<i>#{order_detail.note}</i>" if order_detail.note.present?
      description
    end

    def subsidy_display(order_detail)
      subsidy = number_to_currency(order_detail.actual_subsidy)
      subsidy += "\n#{order_detail.price_policy.price_group.name}" if order_detail.actual_subsidy > 0
      subsidy
    end

    def order_detail_footer
      ['', '', '', '', '', 'TOTAL DUE', number_to_currency(@total_due)]
    end

    def order_detail_headers
      ['Fulfillment Date', 'Order Number', 'Item Name', 'Quantity', 'Unit Cost', 'Subsidy Amount', 'Total Cost']
    end
  end
end
