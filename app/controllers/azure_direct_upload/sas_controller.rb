module AzureDirectUpload
  class SasController < ApplicationController
    protect_from_forgery with: :exception

    def sign
      bs = Azure::Blob::BlobService.new
      @uri = bs.generate_uri "#{container_name}/#{blob_name}"

      signer = Azure::Contrib::Auth::SharedAccessSignature.new(@uri, {
        resource:    "b",
        permissions: permissions,
        start:       start_time.utc.iso8601,
        expiry:      expiration_time.utc.iso8601
      }, Azure.config.storage_account_name)

      @uri = signer.sign

      render response_hash
    end

    private

    def container_name
      params[:container]
    end

    def blob_name
      params[:file_name]
    end

    def permissions
      params[:settings][:sas_permissions]
    end

    def start_time
      Time.now
    end

    def expiration_time
      Time.now + params[:settings][:sas_expiration].to_i
    end

    def response_hash
      {text: @uri}
    end
  end
end
