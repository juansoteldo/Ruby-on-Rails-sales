class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :authentication_token, :string, limit: 30
    add_index :users, :authentication_token, unique: true

    total = User.all.count
    progressbar = ProgressBar.create( total: total, :format => '%c/%C %B %p%% %t')
    puts "Updating #{total} user records"
    User.all.each_with_index do |user, index|
      user.save!
      if index % 100 == 0
        progressbar.progress += 100 unless ( progressbar.total - progressbar.progress < 100 )
      end

    end
    progressbar.finish
  end

  def down
    remove_index :users, :authentication_token
    remove_column :users, :authentication_token
  end
end
