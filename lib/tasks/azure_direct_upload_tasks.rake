# desc "Explaining what the task does"
# task :azure_direct_upload do
#   # Task goes here
# end
namespace :azure do
  namespace :direct_upload do
    desc "Setup CORS rules"
    task :setup_cors => :environment do
      blob_service = Azure::Blob::BlobService.new
      props = Azure::Service::StorageServiceProperties.new

      # Hack so serializer won't output tags like below
      # which trigger syntax error on server.
      #
      # <Logging>
      #  <RetentionPolicy/>
      # </Logging>
      props.logging = nil
      props.hour_metrics = nil
      props.minute_metrics = nil

      # Create a rule
      rule = Azure::Service::CorsRule.new
      rule.allowed_headers = ["*"]
      rule.allowed_methods = ["PUT", "GET", "HEAD", "POST"]
      rule.allowed_origins = ["*"]
      rule.exposed_headers = ["*"]
      rule.max_age_in_seconds = 1800

      props.cors.cors_rules = [rule]

      blob_service.set_service_properties(props)
    end

    desc "Read CORS rules"
    task :read_cors => :environment do
      blob_service = Azure::Blob::BlobService.new
      puts blob_service.get_service_properties.to_yaml
    end
  end
end
