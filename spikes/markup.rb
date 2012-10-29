module Markup
  Tags = [
    "a", "abbr", "acronym", "address", "applet", "area", "b", "base", "basefont", "bdo", "big", 
    "blockquote", "body", "br", "button", "caption", "center", "cite", "code", "col", "colgroup", 
    "dd", "del", "dfn", "dir", "div", "dl", "dt", "em", "fieldset", "font", "form", "frame", 
    "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "hr", "html", "i", "iframe", "img", 
    "input", "ins", "isindex", "kbd", "label", "legend", "li", "link", "map", "menu", "meta", 
    "noframes", "noscript", "object", "ol", "optgroup", "option", "p", "param", "pre", "q", "s", 
    "samp", "script", "select", "small", "span", "strike", "strong", "style", "sub", "sup", 
    "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "title", "tr", "tt", "u", "ul", "var"
  ]

  def page_cache
    @page_cache ||= {}
  end

  def open_tags
    @open_tags ||= []
  end

  def open_tag
    open_tags.last
  end

  def open_tag(name, attributes={})
    file, line, parent = caller[1].split(":", 3)

    mtime = File.mtime(file)
    lines = page_cache[[file, mtime]] ||= File.read(file).split("\n")

    tag = lines[line.to_i - 1]
    _, indent = /^(\s*)/.match(tag).to_a

    open_tags.pop until open_tags.length < indent.length || open_tags.length == 0
    open_tags[indent.length] = name
  end

  def method_missing(name, *attributes)
    if Tags.include?(name.to_s)
      open_tag(name, *attributes)
    else
      super
    end
  end

  def p(attributes={})
    open_tag(:p, attributes)
  end
end
