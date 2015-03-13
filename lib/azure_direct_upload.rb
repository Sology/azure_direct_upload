require "azure_direct_upload/engine"
require "azure_direct_upload/railtie"

require "azure_direct_upload/config"
require "azure_direct_upload/form_helper"

module AzureDirectUpload
end

ActiveSupport.on_load(:action_view) do
  include AzureDirectUpload::UploadHelper
end
