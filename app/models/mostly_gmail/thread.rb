# frozen_string_literal: true

module MostlyGmail
  class Thread < Base
    def self.find(id, *params)
      new service.get_user_thread(ME_ID, id, *params)
    end

    def self.modify(id, label_to_add = [], labels_to_remove = [])
      new service.modify_thread(ME_ID, id,
                                Google::Apis::GmailV1::ModifyThreadRequest.new(
                                  add_label_ids: label_to_add,
                                  remove_label_ids: labels_to_remove
                                ))
    end
  end
end
