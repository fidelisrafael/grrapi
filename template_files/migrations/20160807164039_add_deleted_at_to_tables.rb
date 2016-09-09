class AddDeletedAtToTables < ActiveRecord::Migration
  def change
    tables = [
      :notifications,
      :users
    ]

    tables.each do |table_name|
      next if column_exists?(table_name, :deleted_at)

      add_column table_name, :deleted_at, :datetime
      add_index table_name, :deleted_at
    end
  end
end
