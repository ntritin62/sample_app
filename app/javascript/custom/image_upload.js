document.addEventListener('turbo:load', () => {
  document.addEventListener('change', (e) => {
    let image_upload = document.querySelector('#micropost_image')
    let size_in_megabytes = image_upload
      ? image_upload?.files[0].size / 1024 / 1024
      : 0
    if (size_in_megabytes > 5) {
      alert(I18n.t('alert.too_large_img_size'))
      image_upload.value = ''
    }
  })
})
