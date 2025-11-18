// Source: Adapted from https://github.com/asciidoctor/asciidoctor-docs-ui/blob/main/src/js/06-copy-to-clipboard.js
// License: MPL-2.0 (https://github.com/asciidoctor/asciidoctor-docs-ui/blob/main/LICENSE)
// Modifications: Added 'nocopy' role support for conditional disable

; (function () {
  'use strict'

  var CMD_RX = /^\$ (\S[^\\\n]*(\\\n(?!\$ )[^\\\n]*)*)(?=\n|$)/gm
  var LINE_CONTINUATION_RX = /( ) *\\\n *|\\\n( ?) */g
  var TRAILING_SPACE_RX = / +$/gm

  var supportsCopy = window.navigator.clipboard

    ;[].slice.call(document.querySelectorAll('.listingblock pre.highlight, .literalblock pre')).forEach(function (pre) {
      // MODIFICATION: Skip blocks with 'nocopy' role
      var listingBlock = pre.closest('.listingblock, .literalblock')
      if (listingBlock && listingBlock.classList.contains('nocopy')) {
        return
      }

      var code, language, lang, copy, toast, toolbox
      // Hugo uses .rouge.highlight, check for .highlight class
      if (pre.classList.contains('highlight')) {
        code = pre.querySelector('code')
        if (code && (language = code.dataset.lang) && language !== 'console') {
          ; (lang = document.createElement('span')).className = 'source-lang'
          lang.appendChild(document.createTextNode(language))
        }
      } else if (pre.innerText.startsWith('$ ')) {
        var block = pre.parentNode.parentNode
        block.classList.remove('literalblock')
        block.classList.add('listingblock')
        pre.classList.add('highlightjs', 'highlight')
          ; (code = document.createElement('code')).className = 'language-console hljs'
        code.dataset.lang = 'console'
        while (pre.hasChildNodes()) code.appendChild(pre.firstChild)
        pre.appendChild(code)
      } else {
        return
      }
      ; (toolbox = document.createElement('div')).className = 'source-toolbox'
      if (lang) toolbox.appendChild(lang)
      if (supportsCopy) {
        ; (copy = document.createElement('button')).className = 'copy-button'
        copy.setAttribute('title', 'Copy to clipboard')
        copy.setAttribute('aria-label', 'Copy to clipboard')
        // Use simple text content for copy icon (mobile-friendly, no external SVG dependency)
        var copyIcon = document.createElement('span')
        copyIcon.className = 'copy-icon'
        copyIcon.setAttribute('aria-hidden', 'true')
        copyIcon.appendChild(document.createTextNode('📋'))
        copy.appendChild(copyIcon)
          ; (toast = document.createElement('span')).className = 'copy-toast'
        toast.appendChild(document.createTextNode('Copied!'))
        copy.appendChild(toast)
        toolbox.appendChild(copy)
      }
      pre.parentNode.appendChild(toolbox)
      if (copy) copy.addEventListener('click', writeToClipboard.bind(copy, code))
    })

  function extractCommands(text) {
    var cmds = []
    var m
    while ((m = CMD_RX.exec(text))) cmds.push(m[1].replace(LINE_CONTINUATION_RX, '$1$2'))
    return cmds.join(' && ')
  }

  function writeToClipboard(code) {
    var text = code.innerText.replace(TRAILING_SPACE_RX, '')
    if (code.dataset.lang === 'console' && text.startsWith('$ ')) text = extractCommands(text)
    window.navigator.clipboard.writeText(text).then(
      function () {
        this.classList.add('clicked')
        this.offsetHeight // eslint-disable-line no-unused-expressions
        this.classList.remove('clicked')
      }.bind(this),
      function () { }
    )
  }
})()
