module MostlyStreak
  class Thread < Base
    def self.all(box_key)
      Rails.cache.fetch("streak_thread/#{box_key}/all", expires_in: 5.seconds) do
        Streak.api_key = Settings.streak.api_key
        Streak::Thread.all(box_key).map { |b| new b }
      end
    end
  end
end
