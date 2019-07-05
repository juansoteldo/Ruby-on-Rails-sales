class AddStateToRequests < ActiveRecord::Migration[4.2]
  def up
    add_column :requests, :state, :string, index: true, default: 'fresh'
    add_column :requests, :state_changed_at, :datetime, index: true

    execute 'UPDATE requests SET state_changed_at = created_at '\
        'WHERE quoted_by_id IS NULL AND deposit_order_id IS NULL AND final_order_id IS NULL'
    execute 'UPDATE requests SET state_changed_at = updated_at, state = \'quoted\' '\
        'WHERE quoted_by_id IS NOT NULL AND deposit_order_id IS NULL AND final_order_id IS NULL'

    Request.where('deposit_order_id IS NOT NULL OR final_order_id IS NOT NULL').find_in_batches(batch_size: 10) do |group|
      ids = group.map do |r|
        r.final_order_id && r.final_order_id || r.deposit_order_id
      end.uniq

      orders = MostlyShopify::Order.find( { ids: ids.join(','), status: 'any' } )
      order_ids = orders.map(&:id).map(&:inspect).join(',')

      group.each do |request|
        if request.final_order_id
          state = 'completed'
          relevant_order_id = request.final_order_id
        else
          state = 'deposited'
          relevant_order_id = request.deposit_order_id
        end

        order = orders.find{|o| o.id.to_s == relevant_order_id }

        puts "Cannot find order #{relevant_order_id.inspect} in #{order_ids}" unless order
        updated_at = order && order.updated_at || request.updated_at
        puts "Marking request #{request.id} as #{state} at #{updated_at}"
        request.update_attribute :state_changed_at, updated_at
        request.update_attribute :state, state
      end
      sleep 2
    end

  end



  def down
    remove_column :requests, :state
    remove_column :requests, :state_changed_at
  end
end
