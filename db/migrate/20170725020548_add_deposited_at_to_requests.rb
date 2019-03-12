class AddDepositedAtToRequests < ActiveRecord::Migration[4.2]
  def up
    add_column :requests, :deposited_at, :datetime, index: true
    add_index :requests, :deposit_order_id
    add_index :requests, :created_at
    add_index :requests, :client_id


    cutoff = Time.parse("2017-07-24T15:00:00.000-04:00")
    requests = Request.where.not(deposit_order_id: nil)
      .where( state_changed_at: [cutoff..Time.now])
      .order(state_changed_at: :desc)

    total = requests.count
    requests.each_with_index do |request, i|
      order = ShopifyAPI::Order.find request.deposit_order_id
      deposited_at = (order ? order.created_at : request.state_changed_at)
      puts "Updating request ##{request.id} (#{i}/#{total} deposited_at to #{deposited_at}"
      request.update_attribute :deposited_at, deposited_at
    end
  end

  def down
    remove_column :requests, :deposited_at
    remove_index :requests, :deposit_order_id
    remove_index :requests, :created_at
    remove_index :requests, :client_id
  end
end
