# Physics Item Content Processor
# Multi-stage content processing pipeline for physics question items:
#
#   1. PSTricks Stripping: Removes PSTricks figure markup from item bodies,
#      handling single, double, and multi-figure items. Tracks counts per category.
#
#   2. TeX Stripping: Removes inline ($...$) and display ($$...$$) math markup
#      to extract plain-text content for analysis.
#
#   3. Answer Extraction: Parses multiple choice items to find correct answer text,
#      handling both single-part and multi-part questions with variable resolution.


# --- Stage 1: Strip PSTricks figures from item bodies ---
onefig_ctr = 0
twofig_ctr = 0
multifig_ctr = 0
multifig_questions = {}

fig_ctr = 0
stripped_ctr = 0

ps_questions.each do |i|
  iv = i.current_active_itemversion
  db = iv.draft_body
  stripped_db = db

  loop do
    # Replace PSTricks delimiters with split tags
    subdb = stripped_db.sub('\\pspicture', 'STARTPS')
    subdb = subdb.sub('\\endpspicture', 'ENDPS')

    split1 = subdb.split('STARTPS')

    # If string before figure includes \psset, strip it too
    if split1.first.include?('\\psset')
      qstart = split1.first.split('\\psset').first
    else
      qstart = split1.first
    end

    # Reconstruct string without the figure content
    rstring = split1.second
    split2 = rstring.split('ENDPS')

    if split2.second.nil?
      stripped_db = qstart
    else
      stripped_db = qstart + split2.second
    end

    # Break when no more PSTricks figures remain
    break unless stripped_db.include?('\\pspicture')
  end

  # Count figures per item for reporting
  c_pspicture = iv.draft_body.scan(/\\pspicture/).count
  fig_ctr += c_pspicture

  if c_pspicture == 1
    onefig_ctr += 1
    stripped_ctr += 1
  elsif c_pspicture == 2
    twofig_ctr += 1
    stripped_ctr += 2
  else
    multifig_ctr += 1
    multifig_questions[i.id] = stripped_db
    stripped_ctr += c_pspicture
    puts "Original #{i.id}: #{c_pspicture}"
    puts
    puts db
    puts
    puts "Fixed"
    puts
    puts stripped_db
    puts
    puts "--------------------------------------------------"
  end
end


# --- Stage 2: Strip TeX math markup ---
if db.include?('$')
  # Strip display math ($$...$$) first
  if db.include?('$$')
    merged_db = ""
    split_db = stripped_db.split('$$')
    s_ctr = 0

    split_db.each do |x|
      s_ctr += 1
      merged_db += x unless s_ctr.even? # Keep non-math segments
    end

    stripped_db = merged_db
  end

  # Strip inline math ($...$)
  merged_db = ""
  split_db = stripped_db.split('$')
  s_ctr = 0

  split_db.each do |x|
    s_ctr += 1
    merged_db += x unless s_ctr.even? # Keep non-math segments
  end

  stripped_db = merged_db
end

# Normalize whitespace
stripped_db.gsub!(/[\n]+/, "\n")
stripped_db.gsub(/[ ]+/, ' ')


# --- Stage 3: Extract correct answers from multiple choice items ---
items.each do |i|
  iv = i.current_active_itemversion
  db = iv.draft_body
  dc = iv.draft_code
  ii = iv.iteminstances.first
  iip = ii.iteminstanceparameters

  # Determine number of answer parts
  question_parts = 0

  (10).downto(0) do |ans_ctr|
    if dc.include?("ans#{ans_ctr}")
      question_parts = ans_ctr
      break
    end
  end

  if question_parts > 1 # Multi-part question
    (1).upto(question_parts) do |part|
      correct_choice = iv.correct_answer(part).number

      # Extract answer text between choice delimiters
      ans = db.split("\\choice\{\}\{#{correct_choice}\}\{").second
      ans = ans.split('}').first

      # Resolve variable references (prefixed with @)
      if ans.starts_with?('@')
        ans = ans.gsub('@', '')
        ans = iip.where("name = ?", ans)
      end

      puts ans
    end
  else # Single-part question
    correct_choice = iv.correct_answer(1).number

    ans = db.split("\\choice\{\}\{1\}\{").second
    ans = ans.split('}').first

    # Resolve variable references (prefixed with @)
    if ans.starts_with?('@')
      ans = ans.gsub('@', '')
      ans = iip.where("name = ?", ans)
      puts ans
    end
  end
end
