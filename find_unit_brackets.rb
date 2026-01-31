# Nested Unit Bracket Detector
# Parses item version markup character-by-character to find unit expressions (u={...})
# that contain improperly nested curly braces, which break LaTeX rendering.
#
# Uses a state machine approach: when "u={" is found, scans forward for any
# opening brace before the closing brace, indicating illegal nesting.

# Returns true if the text contains a unit expression with nested braces.
def find_double_braces(text)
  i = 0

  while i < text.length
    str = ''

    if text[i] == '{'
      # Capture the two characters preceding the brace to identify "u={"
      str = text[i - 2] + text[i - 1] + text[i]
      puts str
      i += 1
    end

    # If this brace belongs to a unit expression, check for nesting
    if str == 'u={'
      while i < text.length && text[i] != '}'
        # Another opening brace before the closing one means nested brackets
        return true if text[i] == '{'
        i += 1
      end
    end

    i += 1
  end

  return false
end

begin
  itemversions = Itemversion.where("created_at > ?", Time.now - 1.year)
  nested_brackets = []

  itemversions.each do |iv|
    next unless iv.current_active
    next unless iv.draft_body

    puts iv.id

    if find_double_braces(iv.draft_code)
      nested_brackets << iv
      puts "FOUND"
    else
      puts "no nested brackets"
    end
  end
end
