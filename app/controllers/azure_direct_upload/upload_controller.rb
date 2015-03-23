module AzureDirectUpload
  class UploadController < ApplicationController
    def commit
      bs = Azure::Blob::BlobService.new
      block_list = (0..blockno).collect{|i| [sprintf("%05d", i)]}
      bs.commit_blob_blocks(container_name, blob_name, block_list)

      render response_hash
    end

    private

    def container_name
      params[:container]
    end

    def blob_name
      params[:file_name]
    end

    def blockno
      params[:blockno].to_i
    end

    def response_hash
      {text: "commited"}
    end
  end
end
