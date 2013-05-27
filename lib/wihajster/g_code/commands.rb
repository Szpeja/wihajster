require 'erb'

module Wihajster::GCode::Commands
  # Generates raw YAML file based on reprap g-code wiki entry.
  #
  # Wiki file entry is used to bootstrap YAML file,
  # which is ment as a reference for RepRap printer commands.
  def self.generate_yaml
    raw_sections = File.read(__FILE__.gsub('.rb', '.wiki')).
      split(/^==/).
      map{|l| /=*(.+):(.+)====(.+)/m.match(l)}.compact

    sections = raw_sections.map do |r| 
      desc = r[3].strip.gsub(/{\|.+?\|}/m, '').gsub(/\n\s+/m, "\n").strip 
      name = r[2].strip
      method_name = name.gsub(/\(.+\)/, '').strip.gsub(/\W+/,'_').downcase
      code = r[1].strip

      potential_params = desc.scan(/\s([XYZEFSPR])\d*(?!\w)/).map{|m| m[0].to_sym}.uniq.sort

      example_matcher = /^(Example:) ([\w .<>-]+?)(#.+)?$/
      if match = example_matcher.match(desc)
        example = match[2]
        desc.sub!(example_matcher, '\3').sub('#', '')
      end

      {
        code: code, 
        name: name,
        example: example, 
        accepts: potential_params,
        supported: true,
        method_name: method_name, 
        description: desc, 
      }
    end

    File.open(__FILE__.gsub('.rb', '.yml'), "w"){|f| f.write sections.to_yaml }
  end

  # Generates help table based on reference YAML reference file.
  def self.generate_help
    help_template_path = File.join(Wihajster.root, "assets", "g_code.html.erb")
    help_template = File.read(help_template_path)

    commands

    help_table = ERB.new(help_template).result(binding)

    File.open(File.join(Wihajster.root, "doc", "gcode.html"), "w") do |f|
      f.write help_table
    end
  end
end
