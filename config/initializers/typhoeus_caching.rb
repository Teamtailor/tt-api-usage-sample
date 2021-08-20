require "typhoeus/cache/redis"

redis = Redis.new
Typhoeus::Config.cache = Typhoeus::Cache::Redis.new(redis, default_ttl: 600)
