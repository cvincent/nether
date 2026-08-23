; extends

; String Sigils
(sigil
  "~" @string
  (sigil_name) @string @_sigil_name
  quoted_start: _ @string
  (quoted_content) @string
  quoted_end: _ @string
  ((sigil_modifiers) @string)?
  (#any-of? @_sigil_name "s" "S" "w" "W"))
