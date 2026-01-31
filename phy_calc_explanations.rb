# Physics Calculus Explanation Keyword Search
# Reads a list of physics item IDs from a file and searches their explanation
# sections for a specific LaTeX keyword (e.g., \times).
#
# Filters for single-part TeX items with exactly one explanation section,
# then checks if the explanation contains the target keyword.
#
# Output: Item version IDs of matches, plus total counts.

ctr = 0
hit_ctr = 0
keyword = '\\times'

File.foreach("/tmp/phy_item_list.txt") do |line|
  item = Item.find(line)
  next unless item.itemtype_id == 1 # TeX items only

  iv = item.current_active_itemversion
  next unless iv.itemparts.count == 1                      # Single-part items only
  next unless iv.draft_body.split('% expl 1').count == 2   # Must have exactly one explanation

  ctr += 1

  # Extract the explanation section (everything after '% expl 1')
  explanation = iv.draft_body.split('% expl 1').second

  next unless explanation.include?(keyword)
  hit_ctr += 1
  puts iv.id
end

puts hit_ctr
puts ctr
