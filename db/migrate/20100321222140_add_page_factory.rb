class AddPageFactory < ActiveRecord::Migration
  def self.up
    add_column :pages, :page_factory, :string
  end

  def self.down
    remove_column :pages, :page_factory
  end
end
