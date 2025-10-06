class UpdateUserEmailIndexAndAddIndexes < ActiveRecord::Migration[7.1]
  def up
    # Remover o índice antigo (se existir)
    remove_index :users, :email if index_exists?(:users, :email, unique: true)

    # Adicionar índice único case-insensitive para email (verifica pelo NOME por segurança)
    unless index_name_exists?(:users, 'index_users_on_lower_email')
      add_index :users, 'LOWER(email)', unique: true, name: 'index_users_on_lower_email'
    end

    # Adicionar índice para disabled_at (se não existir)
    add_index :users, :disabled_at unless index_exists?(:users, :disabled_at)
  end
  
  def down
    # Remover índice em disabled_at (se existir)
    remove_index :users, :disabled_at if index_exists?(:users, :disabled_at)

    # Remover índice por nome (mais robusto para índices por expressão)
    remove_index :users, name: 'index_users_on_lower_email' if index_name_exists?(:users, 'index_users_on_lower_email')

    # Restaurar índice original de email (se não existir)
    add_index :users, :email, unique: true unless index_exists?(:users, :email, unique: true)
  end
end
