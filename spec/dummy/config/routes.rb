Rails.application.routes.draw do

  mount AzureDirectUpload::Engine => "/azure_direct_upload"
end
