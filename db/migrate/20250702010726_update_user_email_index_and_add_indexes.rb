class UpdateUserEmailIndexAndAddIndexes < ActiveRecord::Migration[7.1]
  def up
    # Verificar se o índice antigo existe antes de remover
    if index_exists?(:users, :email, unique: true)
      remove_index :users, :email
    end
    
    # Adicionar índice único case-insensitive para email (se não existir)
    unless index_name_exists?(:users, 'index_users_on_lower_email', false)
      add_index :users, 'LOWER(email)', unique: true, name: 'index_users_on_lower_email'
    end
    
    # Adicionar índice para disabled_at (se não existir)
    unless index_exists?(:users, :disabled_at)
      add_index :users, :disabled_at
    end
  end
  
  def down
    # Reverter mudanças de forma segura
    if index_exists?(:users, :disabled_at)
      remove_index :users, :disabled_at
    end
    
    if index_name_exists?(:users, 'index_users_on_lower_email', false)
      remove_index :users, name: 'index_users_on_lower_email'
    end
    
    # Restaurar índice original de email (se não existir)
    unless index_exists?(:users, :email, unique: true)
      add_index :users, :email, unique: true
    end
  end
end
