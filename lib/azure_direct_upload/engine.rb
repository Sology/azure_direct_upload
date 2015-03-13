module AzureDirectUpload
  class Engine < ::Rails::Engine
    isolate_namespace AzureDirectUpload

    config.generators do |g|
      g.test_framework :rspec
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
