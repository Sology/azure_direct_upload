AzureDirectUpload::Engine.routes.draw do
  post "sign", to: "sas#sign", as: :sas_sign
  post "commit", to: "upload#commit", as: :upload_commit
end
