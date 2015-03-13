module AzureDirectUpload
  module UploadHelper
    def azure_upload_form(options = {}, &block)
      uploader = AzureUploader.new(self, options)

      form_tag(uploader.url, uploader.form_options) do
        capture(&block)
      end
    end

    class AzureUploader
      def initialize(view_context, options)
        @options = options.reverse_merge(
          max_file_size: 500.megabytes,
          sas_url: view_context.azure_direct_upload.sas_sign_url,
          sas_permissions: "w",
          sas_expiration: 30.minutes,
          callback_url: nil,
          callback_method: "POST",
          callback_param: "file",
          container: nil,
          max_file_size: nil,
          html: {
            class: "azure-direct-upload",
            id: nil,
          }
        )
      end

      def form_options
        {
          id: @options[:html][:id],
          class: @options[:html][:class],
          method: "PUT",
          authenticity_token: false,
          multipart: false,
          data: {
            sas_url: @options[:sas_url],
            sas_permissions: @options[:sas_permissions],
            sas_expiration: @options[:sas_expiration],
            callback_url: @options[:callback_url],
            callback_method: @options[:callback_method],
            callback_param: @options[:callback_param],
            max_file_size: @options[:max_file_size],
            container: @options[:container]
          }.reverse_merge(@options[:data] || {})
        }
      end

      def url
        "#"
      end
    end
  end
end