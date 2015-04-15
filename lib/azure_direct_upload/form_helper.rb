module AzureDirectUpload
  module UploadHelper
    def azure_upload_box(options = {}, &block)
      uploader = AzureUploader.new(self, options)

      content_tag(:div, uploader.form_options) do
        capture(&block)
      end
    end

    class AzureUploader
      def initialize(view_context, options)
        @options = options.reverse_merge(
          max_file_size: 200.gigabytes,
          sas_url: view_context.azure_direct_upload.sas_sign_url,
          commit_url: view_context.azure_direct_upload.upload_commit_url,
          sas_permissions: "rw",
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
          data: {
            sas_url: @options[:sas_url],
            commit_url: @options[:commit_url],
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
