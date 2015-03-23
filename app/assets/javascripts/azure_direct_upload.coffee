#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

$ = jQuery

$.fn.azure_direct_upload = (options) ->

  pad = (n, width, z) ->
    z = z or '0'
    n = n + ''
    if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

  if @length > 1
    @each ->
      $(this).azure_direct_upload options

    return this

  form = this
  chunksent = false

  settings =
    path: ''
    drop_zone: null,
    callbacks:
      add: null
      progress: null
      done: null
      fail: null
      submit: null
      chunksend: null
      chunkdone: null

  $.extend settings, options

  setup = ->
    form.fileupload
      type: "PUT",
      headers:
        "x-ms-page-write": "update"
        "x-ms-version": "2013-08-15"
      multipart: false,
      maxChunkSize: 4000000,
      maxFileSize: form.data("max-file-size"),
      dropZone: settings.drop_zone,
      add: (e, data) ->
        file = data.files[0]
        file.commit_data = {}

        $.ajax
          type: "POST",
          url: form.data("sas-url"),
          data:
            file_name: file.name,
            container: form.data("container"),
            size: file.size,
            settings:
              sas_permissions: form.data("sas-permissions"),
              sas_expiration: form.data("sas-expiration"),

          beforeSend: ( xhr, settings )       -> form.trigger( 'ajax:beforeSend', [xhr, settings] )
          complete:   ( xhr, status )         -> form.trigger( 'ajax:complete', [xhr, status] )
          success:    ( response_data, status, xhr )   ->
            data.files[0].blockno = 0
            data.files[0].base_url = response_data.uri
            data.url = data.files[0].base_url.replace("BLOCK_ID", btoa(pad(data.files[0].blockno, 5)))
            form.trigger( 'ajax:success', [data, status, xhr] )

            settings.callbacks.add(data, response_data) if settings.callbacks.add

            data.submit()

          error:      ( xhr, status, error )  -> form.trigger( 'ajax:error', [xhr, status, error] )

      progress: (e, data) ->
        settings.callbacks.progress(data) if settings.callbacks.progress

      done: (e, data) ->
        file = data.files[0]

        $.ajax
          type: "POST",
          url: form.data("commit-url"),
          data:
            blockno: file.blockno,
            file_name: file.name,
            container: form.data("container"),
            size: file.size,
            commit_data: file.commit_data

          beforeSend: ( xhr, settings )       -> form.trigger( 'ajax:beforeSend', [xhr, settings] )
          complete:   ( xhr, status )         -> form.trigger( 'ajax:complete', [xhr, status] )
          success:    ( response_data, status, xhr )   ->
            form.trigger( 'ajax:success', [data, status, xhr] )

            settings.callbacks.done(data, response_data) if settings.callbacks.done
          error:      ( xhr, status, error )  -> form.trigger( 'ajax:error', [xhr, status, error] )

      fail: (e, data) ->
        settings.callbacks.fail(data) if settings.callbacks.fail

      #formData: (form) ->
      
      submit: (e, data) ->
        settings.callbacks.submit(data) if settings.callbacks.submit

      chunksend: (e, data) =>
        if chunksent
          data.files[0].blockno++
          data.url = data.files[0].base_url.replace("BLOCK_ID", btoa(pad(data.files[0].blockno, 5)))

        chunksent = true
        settings.callbacks.chunksend(data) if settings.callbacks.chunksend
      chunkdone: (e, data) =>
        settings.callbacks.chunkdone(data) if settings.callbacks.chunkdone

  #public methods
  @initialize = ->
    setup()
    this

  @initialize()
