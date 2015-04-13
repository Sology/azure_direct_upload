module AzureDirectUpload
  class SasController < ApplicationController
    def sign
      bs = Azure::Blob::BlobService.new
      @uri = bs.generate_uri Addressable::URI.escape("#{container_name}/#{blob_name}"), {comp: "block", blockid: "BLOCK_ID"}

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
      Time.now - 10.seconds
    end

    def expiration_time
      Time.now + params[:settings][:sas_expiration].to_i
    end

    def response_hash
      {text: @uri}
    end
  end
end
