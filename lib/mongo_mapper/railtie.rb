require "mongo_mapper"
require "rails"
require "active_model/railtie"

# Need the action_dispatch railtie to have action_dispatch.rescu_responses initialized correctly
require "action_dispatch/railtie"

module MongoMapper
  # = MongoMapper Railtie
  class Railtie < Rails::Railtie

    config.mongo_mapper = ActiveSupport::OrderedOptions.new

    # Rescue responses similar to ActiveRecord.
    config.action_dispatch.rescue_responses.merge!(
        'MongoMapper::DocumentNotFound'  => :not_found,
        'MongoMapper::InvalidKey'        => :unprocessable_entity,
        'MongoMapper::InvalidScheme'     => :unprocessable_entity,
        'MongoMapper::NotSupported'      => :unprocessable_entity
      )

    rake_tasks do
      load "mongo_mapper/railtie/database.rake"
    end

    initializer "mongo_mapper.set_configs" do |app|
      ActiveSupport.on_load(:mongo_mapper) do
        app.config.mongo_mapper.each do |k,v|
          send "#{k}=", v
        end
      end
    end

    # This sets the database configuration and establishes the connection.
    initializer "mongo_mapper.initialize_database" do |app|
      config_file = Rails.root.join('config/mongo.yml')
      if config_file.file?
        config = YAML.load(ERB.new(config_file.read).result)
        MongoMapper.setup(config, Rails.env, :logger => Rails.logger)
      end
    end
  end
end
