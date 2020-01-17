module MostlyGmail
  class Label < Base
    def self.all(*params)
      service.list_user_labels(ME_ID, *params)&.labels&.map(&method(:new))
    end

    def self.find(id, *params)
      new service.get_user_label(ME_ID, id, *params)
    end
  end
end