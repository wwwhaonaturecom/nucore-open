class MigrateAndDropAccountTransactions < ActiveRecord::Migration
  def self.up
    OrderDetail.reset_column_information

    at_rows=OrderDetail.find_by_sql("SELECT * FROM account_transactions WHERE type = 'PurchaseAccountTransaction'")

    at_rows.each do |at_row|
      od=OrderDetail.find(at_row.order_detail_id)
      next if od.account_id != at_row.account_id

      j_rows=JournalRow.find(:all, :conditions => {:account_transaction_id => at_row.id})

      j_rows.each do |j_row|
        journal=j_row.journal

        if journal.open? || journal.is_successful? == true
          od.journal=journal

          if journal.is_successful? == true
            od.state='reconciled'
            od.order_status=OrderStatus.reconciled.first
          end
        end
      end

      od.reviewed_at=at_row.finalized_at
      od.fulfilled_at=at_row.created_at
      od.reconciled_note=at_row.reference

      if od.state == 'inprocess' || od.state == 'new'
        od.estimated_cost=od.actual_cost
        od.estimated_subsidy=od.actual_subsidy
        od.actual_cost=nil
        od.actual_subsidy=nil
        od.price_policy=nil
      end

      od.save!
    end

    Statement.all.each do |stmt|
      aid_rows=Statement.find_by_sql(%Q<
        SELECT
          DISTINCT at.account_id
        FROM
          account_transactions at, statements s
        WHERE
          at.statement_id=s.id AND s.id=#{stmt.id} AND at.type = 'PurchaseAccountTransaction'
      >)

      aid_rows.each do |aid_row|
        acct=Account.find(aid_row.account_id)

        statement=Statement.new(stmt.attributes)
        statement.account=acct
        statement.save!

        at_rows=Statement.find_by_sql(%Q<
          SELECT * FROM
            account_transactions
          WHERE
            statement_id=#{stmt.id} AND account_id=#{acct.id} AND type = 'PurchaseAccountTransaction'
        >)

        at_rows.each do |at_row|
          od=OrderDetail.find(at_row.order_detail_id)
          StatementRow.create!(:order_detail => od, :statement => statement, :amount => at_row.transaction_amount)                  
          od.statement=statement
          od.save!
        end

        stmt.destroy
      end
    end

    Statement.reset_column_information
    change_column(:statements, :account_id, :integer, :null => false)

    change_table :journal_rows do |t|
      t.remove :account_transaction_id
    end

    drop_table :account_transactions
  end

  
  def self.down
    change_table :journal_rows do |t|
      t.column :account_transaction_id, :integer
    end

    JournalRow.reset_column_information

    create_table :account_transactions do |t|
      t.integer  "account_id", :null => false
      t.integer  "facility_id", :null => false
      t.string   "description", :limit => 200
      t.decimal  "transaction_amount", :precision => 10, :scale => 2, :null => false
      t.integer  "created_by", :null => false
      t.datetime "created_at", :null => false
      t.string   "type", :limit => 50, :null => false
      t.datetime "finalized_at"
      t.integer  "order_detail_id"
      t.boolean  "is_in_dispute", :precision => 1,  :scale => 0, :null => false
      t.integer  "statement_id"
      t.string   "reference", :limit => 50
    end

    puts <<-OUT
      ****************************************************************************
      The migration of previous account_transactions data cannot be reconstructed.
      Old tables were created, but you need to roll back the data yourself!
      ****************************************************************************
    OUT
  end
end
