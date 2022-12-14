# frozen_string_literal: true

require "mostly_streak/base"

module MostlyStreak
  class Box < Base
    def salesperson
      return @assigned_to_salesperson if @assigned_to_salesperson

      emails = assigned_to_emails
      return nil unless emails.count == 1

      @assigned_to_salesperson = Salesperson.where(email: emails).first
    end

    def assigned_to_emails
      assigned_to_sharing_entries.map(&:email).reject { |e| e == Settings.emails.system }
    end

    def assign_to_salesperson(salesperson)
      user_key = salesperson&.user_key
      user_key ||= MostlyStreak::User.find_by_email(salesperson.email)

      if user_key
        add_follower(user_key, salesperson.streak_api_key)
      else
        Rails.logger.error ">>> Cannot get streak follower key for `#{salesperson.email}`"
      end
    end

    def created_between?(range)
      created_at = Time.strptime(creation_timestamp.to_s, "%Q")
      created_at >= range.first && created_at <= range.last
    end

    def self.create(email)
      Streak.api_key = Settings.streak.api_key
      new Streak::Box.create(Settings.streak.pipeline_key, { name: email })
    end

    def delete
      Streak::Box.delete(box_key)
    end

    def self.all
      Rails.cache.fetch("streak_box/all",
                        expires_in: (Rails.env.test? ? 5.seconds : 2.minutes)) do
        Streak.api_key = Settings.streak.api_key
        Streak::Box.all(Settings.streak.pipeline_key).map { |b| new b }
      end
    end

    def self.all_with_limits(params = { limit: "10", page: "1" })
      Rails.cache.fetch("streak_box/all/#{params[:limit]}/#{params[:page]}",
                        expires_in: (Rails.env.test? ? 5.seconds : 2.minutes)) do
        Streak.api_key = Settings.streak.api_key
        Streak::Box.all(Settings.streak.pipeline_key, params).map { |b| new b }
      end
    end

    def self.query(query)
      Rails.cache.fetch("streak_box/query/" + query, expires_in: 5.seconds) do
        Streak.api_key = Settings.streak.api_key
        results = Streak::Search.query(query).results
        results&.boxes&.map { |b| find(b.box_key) } || [{}]
      end
    end

    def self.find(box_key)
      Streak.api_key = Settings.streak.api_key

      new Streak::Box.find(box_key)
    rescue Streak::InvalidRequestError => e
      return nil if e.http_status == 404

      raise
    end

    def self.find_by_name(email)
      return unless email =~ /\A[^@]+@[^@]+\Z/

      Streak.api_key = Settings.streak.api_key

      box = MostlyStreak::Box.query(email).find do |box|
        box&.name&.casecmp?(email)
      end
      box ||= MostlyStreak::Box.query(email).select do |box|
        difference = box.name.casecmp(email)
        !difference.nil? && difference.to_i < 2
      end.last

      box.nil? ? nil : find(box.box_key)
    end

    # def self.find_by_name(email)
    #   byebug
    #   return unless email =~ /\A[^@]+@[^@]+\Z/
    #   email.downcase!

    #   Streak.api_key = Settings.streak.api_key

    #   # TODO: improve streak library search
    #   # https://github.com/jsboulanger/streak-ruby/blob/master/lib/streak/search.rb

    #   # Finds Streak Box with newest timestamp
    #   box = MostlyStreak::Box.query(email).sort_by { |e| -e.creation_timestamp }.first

    #   # box = MostlyStreak::Box.query(email).find do |box|s
    #   #   box&.name&.casecmp?(email)
    #   # end
    #   # box ||= MostlyStreak::Box.query(email).select do |box|
    #   #   difference = box.name.casecmp(email)
    #   #   !difference.nil? && difference.to_i < 2
    #   # end.last

    #   # box.nil? ? nil : find(box.box_key)
    # end

    def current_stage
      MostlyStreak::Stage.find(key: @source.stage_key)
    end

    def set_stage_by_name(stage_name)
      new_stage = MostlyStreak::Stage.find(name: stage_name)
      raise "cannot find stage key for `#{stage_name}`" unless new_stage

      update(stageKey: new_stage.key)
    end

    def set_stage(stage_key)
      update(stageKey: stage_key)
    end

    def add_follower(follower_key, user_api_key)
      raise if user_api_key.nil?
      Streak.api_key = user_api_key
      box = Streak::Box.find(key)
      follower_keys = box.follower_keys | [follower_key]
      update(followerKeys: follower_keys)
    rescue StandardError
      Rails.logger.warn "Could not add follower with key `#{follower_key}` to box `#{box_key}`"
    end

    def add_thread(box_key, thread_gmail_id)
      Streak.api_key = Settings.streak.api_key
      Streak::Thread.put_into_box(thread_gmail_id, box_key)
      @source = Streak::Box.find(box_key)
    end

    def update(*params)
      Streak.api_key = Settings.streak.api_key
      @source = Streak::Box.update(key, *params)
    end

    def self.new_with_name(name)
      box = MostlyStreak::Box.create(name)
      box.set_stage_by_name "Fresh"
      box
    end

    def key
      @source&.box_key || @source&.key
    end
  end
end
