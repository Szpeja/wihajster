require './markup'
include Markup

html
  body
    blockquote
    div
      5.times{|x| strong x.to_v }
    p
