class AddCriticalFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Adicionar campos críticos
    add_column :users, :name, :string
    add_column :users, :disabled_at, :datetime
    
    # Remover índice antigo de email (case-sensitive)
    remove_index :users, :email
    
    # Adicionar índice único case-insensitive para email
    add_index :users, 'LOWER(email)', unique: true, name: 'index_users_on_lower_email'
    
    # Adicionar índice para performance de soft delete
    add_index :users, :disabled_at
  end
  
  def down
    # Reverter mudanças na ordem correta
    remove_index :users, :disabled_at
    remove_index :users, name: 'index_users_on_lower_email'
    
    # Restaurar índice original de email
    add_index :users, :email, unique: true
    
    remove_column :users, :disabled_at
    remove_column :users, :name
  end
end
