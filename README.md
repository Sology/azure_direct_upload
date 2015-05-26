# AzureDirectUpload

Upload multiple files directly from client browser to Azure Blob Storage.

## Installation and setup

Add to your Gemfile:

```ruby
gem "azure_direct_upload"
```

Then run:

```sh
$ bundle install
```

### Asset pipeline

You need to add AzureDirectUpload to your asset pipeline (typically in application.js):

```
//= require azure_direct_upload
```

### Azure environment

AzureDirectUpload depends on 'azure' gem (https://github.com/Azure/azure-sdk-for-ruby/) and uses 
its configuration settings. So it is required to configure Azure environment properly. 

The minimal initializer file would include:

```ruby
Azure.configure do |config|
  config.storage_account_name = 'your_account_name'
  config.storage_access_key   = 'your_access_key'
  config.storage_blob_host    = "https://your_blob.blob.core.windows.net"
end
```

### CORS rules

Your Blob Service CORS rules need to be set properly to make upload work:

```xml
<CORSConfiguration>
    <CORSRule>
        <AllowedOrigin>http://0.0.0.0:3000</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```
In production the AllowedOrigin key should be your domain.

AzureDirectUpload provides rake task that sets CORS for you:

```ruby
rake azure:direct_upload:setup_cors
```

You can also dump your CORS settings using `rake azure:direct_upload:setup_cors`.

## How it works

AzureDirectUpload uploads block blobs to Azure storage host. It works on top of jquery-fileupload
and supports multiple-file, resumable uploads.

Uploading file triggers AJAX request to local backend (`SasController#sign`) where Shared-Access-Signature 
URL is generated for target blob. Then the client splits the file into several blocks and each chunk is 
uploaded to blob host directly using obtained SAS URL.

Once all blocks are uploaded, client triggers another AJAX request (to `UploadController#commit`) which commits 
the blob by sending ordered list of all blobs to storage service.

## Usage

In your view use `azure_upload_box` helper that will output uploader:

```erb
<%= azure_upload_box do %>
  <%= button_tag "Select files" %>
<% end %>
```

In your JS, add following:

```javascript
$(".azure-direct-upload").azure_direct_upload();
```

## Customizing

### Helper options

Passed to `azure_upload_box(options = {})` method:

* `max_file_size` (default `200.gigabytes`): allowed upload size.
* `sas_url` (default `sas_sign_url`): path for local AJAX request generating SAS url for blob.
* `commit_url` (default `upload_commit_url`): path for local AJAX request committing block blob.
* `sas_permissions` (default `"rw"`): SAS URL permissions.
* `sas_expiration` (default `30.minutes`): SAS URL validity time.
* `html`:

  * `class` (default `"azure-direct-upload"`): html container class.
  * `id` (default `nil`): html container id.

### Javascript options

Passed to `azure_direct_upload()` jQuery plugin:

* `drop_zone`: element that will handle drag&drop file uploads.
* `callbacks`: set of callbacks called upon specific actions:

  * `add(file_data, sas_response_data)` - file added
  * `progress(file_data)` - upload progress info
  * `done(file_data, commit_response_data)` - upload done
  * `fail(file_data)` - upload failed
  * `chunksend(file_data)` - blob block sending started
  * `chunkdone(file_data)` - blob block sending done

### Controller decorators

AzureDirectUpload supports decorators for even more customization. You can create decorators for
`SasController` and `UploadController` and add your custom code there.

In order to do that, just place your file under `app/decorators/controllers/azure_direct_upload/`. 
For i.e. `SasController` it wold be `app/decorators/controllers/azure_direct_upload/sas_decorator.rb`. 
The decorator can look like this:

```ruby
AzureDirectUpload::SasController.class_eval do
  before_filter :create_medium

  def create_asset
    @asset = Asset.create(file_name: params[:file_name])
  end
end
```

## Credits

AzureDirectUpload uses 'azure' gem (https://github.com/Azure/azure-sdk-for-ruby/) for api requests to 
Azure storage service and 'jquery-fileupload' (https://github.com/blueimp/jQuery-File-Upload) to handle 
direct uploads on client side.

Created by Sology http://www.sology.eu
