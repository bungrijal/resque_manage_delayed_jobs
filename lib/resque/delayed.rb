module Resque
  class Delayed

    attr_accessor :timestamp, :klass, :args, :queue

    def initialize(attrs = {})
      %w(timestamp klass args queue).each do |key|
        send("#{key}=", attrs[key])
      end
    end

    def destroy
      Resque.remove_delayed_job_from_timestamp timestamp, klass.constantize, *args
    end

    def delay(seconds)
      Resque.enqueue_at (Time.at(timestamp) + seconds), klass.constantize, *args
      Resque.remove_delayed_job_from_timestamp timestamp, klass.constantize, *args
      self.timestamp = (Time.at(timestamp) + seconds).to_i
    end

    def self.jobs_with_conditions(conditions = {})
      delayed_timestamps = Resque.delayed_queue_peek(0, 0)

      jobs = []

      delayed_timestamps.each do |timestamp|
        Resque.delayed_timestamp_peek(timestamp, 0, 0).each do |job|
          match = true
          conditions.keys.each { |key| match = (job[key] == conditions[key]) }
          jobs << new(job.merge("timestamp" => timestamp, "klass" => job["class"])) if match
        end
      end

      jobs
    end

    def self.remove_jobs_with_conditions(conditions = {})
      jobs_with_conditions(conditions).each do |job|
        job.destroy
      end
    end

    def self.delay_jobs_with_conditions(seconds, conditions = {})
      jobs_with_conditions(conditions).each do |job|
        job.delay(seconds)
      end
    end

    # List
    def self.find_jobs_with_class(klass)
      jobs_with_conditions("class" => klass.to_s)
    end

    def self.find_jobs_with_args(*args)
      jobs_with_conditions("args" => args)
    end

    def self.find_jobs_with_class_and_args(klass, *args)
      jobs_with_conditions("class" => klass.to_s, "args" => args)
    end    
    
    # Remove
    def self.remove_jobs_with_class(klass)
      remove_jobs_with_conditions("class" => klass.to_s)
    end

    def self.remove_jobs_with_args(*args)
      remove_jobs_with_conditions("args" => args)
    end

    def self.remove_jobs_with_class_and_args(klass, *args)
      remove_jobs_with_conditions("class" => klass.to_s, "args" => args)
    end

    # Delay
    def self.delay_jobs_with_class(seconds, klass)
      delay_jobs_with_conditions(seconds, { "class" => klass.to_s })
    end

    def self.delay_jobs_with_args(seconds, *args)
      delay_jobs_with_conditions(seconds, { "args" => args })
    end

    def self.delay_jobs_with_class_and_args(seconds, klass, *args)
      delay_jobs_with_conditions(seconds, { "class" => klass.to_s, "args" => args })
    end

  end
end