# Physics Multiple Choice Answer Extractor
# Parses item version markup to extract the correct answer text from
# multiple choice questions. Handles both single-part and multi-part items.
#
# For each item:
#   1. Determines the number of answer parts by scanning draft_code for "ans1".."ans10"
#   2. Locates the correct choice position from the code
#   3. Extracts the answer text from the body markup using LaTeX \choice{} delimiters
#   4. Resolves variable references (prefixed with @) to their parameter values

items.each do |i|
  iv = i.current_active_itemversion
  db = iv.draft_body
  dc = iv.draft_code
  ii = iv.iteminstances.first
  iip = ii.iteminstanceparameters

  # Determine number of answer parts by finding highest "ansN" in code
  question_parts = 0

  (10).downto(0) do |ans_ctr|
    if dc.include?("ans#{ans_ctr}")
      question_parts = ans_ctr
      break
    end
  end

  body = db

  if question_parts == 1 # Single-part question
    if body.include?("\\choice\{\}")
      # Extract the correct choice number from code (strip whitespace first)
      correct_choice = dc.gsub(/[ ]+/, '')
      correct_choice = correct_choice.split("ans1=").last
      correct_choice = correct_choice.split(";").first.to_i
      next_choice = correct_choice + 1

      # Extract answer text between the correct choice and the next choice delimiter
      ans = body.split("\\choice\{\}\{#{correct_choice}\}\{").second
      ans = ans.split("\\choice\{\}\{#{next_choice}\}\{").first

      # Handle case where correct answer is the last choice
      if ans.include?("expl")
        ans = ans.gsub(/\n/, "")
        ans = ans.split("\}%").first
      end

      ans.chomp("\}")

      # Resolve variable references (e.g., @varname) to parameter values
      if ans.starts_with?("@")
        ans = ans.gsub('@', '')
        variable = dc.gsub(/[ ]+/, '')
        variable = ans.split("#{ans}").last
        variable = ans.split(";").first
      end

      puts "#{iv.id}: #{ans}"
    end
  end
end
