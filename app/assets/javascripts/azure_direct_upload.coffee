#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

$ = jQuery

$.fn.azure_direct_upload = (options) ->

  if @length > 1
    @each ->
      $(this).azure_direct_upload options

    return this

  form = this

  settings =
    path: ''
    drop_zone: null,
    callbacks:
      sas: null
      add: null
      progress: null
      done: null
      fail: null
      submit: null

  $.extend settings, options

  setup = ->
    form.fileupload
      type: "PUT",
      multipart: false,
      maxChunkSize: 10000000,
      maxFileSize: form.data("max-file-size"),
      dropZone: settings.drop_zone,
      add: (e, data) ->
        file = data.files[0]
        success = false

        $.ajax
          type: "POST",
          url: form.data("sas-url"),
          async: false,
          data:
            file_name: file.name,
            container: form.data("container"),
            settings:
              sas_permissions: form.data("sas-permissions"),
              sas_expiration: form.data("sas-expiration"),

          beforeSend: ( xhr, settings )       -> form.trigger( 'ajax:beforeSend', [xhr, settings] )
          complete:   ( xhr, status )         -> form.trigger( 'ajax:complete', [xhr, status] )
          success:    ( response_data, status, xhr )   ->
            settings.callbacks.sas(data, response_data) if settings.callbacks.sas
            form.trigger( 'ajax:success', [data, status, xhr] )
            success = true
          error:      ( xhr, status, error )  -> form.trigger( 'ajax:error', [xhr, status, error] )

        if success
          settings.callbacks.add(data) if settings.callbacks.add

          data.submit()


      progress: (e, data) ->
        settings.callbacks.progress(data) if settings.callbacks.progress
        #console.log("progress")
        #console.log(data)

      done: (e, data) ->
        settings.callbacks.done(data) if settings.callbacks.done
        #console.log("done")
        #console.log(data)

      fail: (e, data) ->
        settings.callbacks.fail(data) if settings.callbacks.fail

      #formData: (form) ->
      
      submit: (e, data) ->
        settings.callbacks.submit(data) if settings.callbacks.submit

  #public methods
  @initialize = ->
    setup()
    this

  @initialize()
