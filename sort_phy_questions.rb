# Physics Question Classifier
# Reads physics item version IDs from a file and classifies each multiple choice
# question into categories based on mathematical complexity and content type.
#
# Classification criteria:
#   - PSTricks questions: contain \ps figure markup
#   - Concept questions: fewer than 2 equals signs (minimal math)
#   - Math questions: 5+ equals signs (heavy computation)
#   - Two/Three/Four-equation questions: sorted by exact equals sign count
#
# Each category is further subdivided by answer choice word count (low/mid/high)
# to estimate answer complexity. Results are output as item version IDs per bucket.

ActiveRecord::Base.logger.level = 1
ctr = 0

# --- Stage 1: Primary classification by equation count ---
ps_questions = []
concept_questions = []
math_questions = []
two_questions = []
three_questions = []
four_questions = []

File.open("/tmp/physicsitems.txt").each do |line|
  iv = Itemversion.where("id like ?", line.to_i)
  next if iv.count < 1

  iv = iv.first
  puts iv.id
  next unless iv.body.include?("choice")

  e_count = iv.body.count('=')

  if iv.draft_body.include?("\\ps")
    ps_questions << line
  elsif e_count < 2
    concept_questions << line
  elsif e_count == 2
    two_questions << line
  elsif e_count == 3
    three_questions << line
  elsif e_count == 4
    four_questions << line
  else
    math_questions << line
  end

  ctr += 1
end

concept_questions.uniq!
math_questions.uniq!
two_questions.uniq!
three_questions.uniq!
four_questions.uniq!
ps_questions.uniq!


# --- Stage 2: Subdivide by answer choice word count ---
# Word count thresholds: low (<6), middle (6-10), high (11+)

# Math questions
m_low_space = []
m_middle_space = []
m_high_space = []

math_questions.each do |x|
  iv = Itemversion.find(x)
  next if iv.draft_body.split("choice{}").count < 2

  word_count = iv.draft_body.split("choice{}")[1].split(" ").count

  if word_count < 6
    m_low_space << iv
  elsif word_count < 11
    m_middle_space << iv
  else
    m_high_space << iv
  end
end

# Concept questions
c_low_space = []
c_middle_space = []
c_high_space = []

concept_questions.each do |x|
  iv = Itemversion.find(x)
  next if iv.draft_body.split("choice{}").count < 2

  word_count = iv.draft_body.split("choice{}")[1].split(" ").count

  if word_count < 6
    c_low_space << iv
  elsif word_count < 11
    c_middle_space << iv
  else
    c_high_space << iv
  end
end

# Two-equation questions
tw_low_space = []
tw_middle_space = []
tw_high_space = []

two_questions.each do |x|
  iv = Itemversion.find(x)
  next if iv.draft_body.split("choice{}").count < 2

  word_count = iv.draft_body.split("choice{}")[1].split(" ").count

  if word_count < 6
    tw_low_space << iv
  elsif word_count < 11
    tw_middle_space << iv
  else
    tw_high_space << iv
  end
end

# Three-equation questions
th_low_space = []
th_middle_space = []
th_high_space = []

three_questions.each do |x|
  iv = Itemversion.find(x)
  next if iv.draft_body.split("choice{}").count < 2

  word_count = iv.draft_body.split("choice{}")[1].split(" ").count

  if word_count < 6
    th_low_space << iv
  elsif word_count < 11
    th_middle_space << iv
  else
    th_high_space << iv
  end
end

# Four-equation questions
f_low_space = []
f_middle_space = []
f_high_space = []

four_questions.each do |x|
  iv = Itemversion.find(x)
  next if iv.draft_body.split("choice{}").count < 2

  word_count = iv.draft_body.split("choice{}")[1].split(" ").count

  if word_count < 6
    f_low_space << iv
  elsif word_count < 11
    f_middle_space << iv
  else
    f_high_space << iv
  end
end


# --- Stage 3: Output item IDs per bucket ---
[m_low_space, m_middle_space, m_high_space,
 c_low_space, c_middle_space, c_high_space,
 tw_low_space, tw_middle_space, tw_high_space,
 th_low_space, th_middle_space, th_high_space,
 f_low_space, f_middle_space, f_high_space].each do |bucket|
  bucket.each do |iv|
    puts iv.id
  end
end
