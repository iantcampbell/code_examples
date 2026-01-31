# C-to-JavaScript Answer Function Migrator
# Finds active item versions that use the legacy C-style answer function signature
# (void answer(void)) and replaces it with the JavaScript equivalent
# (function js_answer()).
#
# Three approaches:
#   1. Manual search to identify and count C-style items
#   2. Direct gsub replacement for CRLF-formatted items
#   3. Loop-based replacement iterating through answer values 1-10

ActiveRecord::Base.logger.level = 1

# --- Approach 1: Identify C-style items by signature and global count ---
c_ctr = 0

iv = Itemversion.where("type = ? and is_active = ?", "Texopenitemversion", true).first(200)

iv.each do |item|
  next unless item.draft_code.include?("void answer(void)")
  next unless item.draft_code.count("global") == 14

  c_ctr += 1
  puts item.draft_code
  puts item.draft_code.count("global")
end

puts c_ctr


# --- Approach 2: Direct replacement for CRLF-formatted items ---
iv1 = Itemversion.where("draft_code like ? and current_active = ?", "%\r\nvoid answer(void) {\r\n  /* global double ans1 u={} */\r\n  ans1 = 1.0;\r\n}\r\n%", true)

iv1.each do |x|
  code = x.draft_code
  code.gsub!("\r\nvoid answer(void) {\r\n  /* global double ans1 u={} */\r\n  ans1 = 1.0;\r\n}\r\n",
             "\r\nfunction js_answer() {\r\n  /* global double ans1 u={} */\r\n  ans1 = 1.0;\r\n}\r\n")
  x.save
end


# --- Approach 3: Loop through answer values 1-10 and replace each ---
ansctr = 1

loop do
  break if ansctr == 11

  iv = Itemversion.where("draft_code like ? and current_active = ?",
    "%void answer(void) {\n  /* global double ans1 u={} */\n  ans1 = #{ansctr};\n}%", true)

  puts iv.count

  iv.each do |x|
    code = x.draft_code
    code = code.gsub("void answer\(void\)", "function js_answer\(\)")
    x.draft_code = code
    x.save
    puts x.id
    break
  end

  ansctr += 1
end
