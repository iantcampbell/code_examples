# Algebraic Free-Response Item Finder
# Identifies all algebraic free-response (algfr) items in a course, categorized
# by response type: list, free, and interval. Outputs item details in CSV format
# for analysis of incorrect answer patterns.
#
# Algfr types are identified by their JavaScript header comments in draft_code.

course = Course.find(83454)

# Collect all active element items (from both assignments and learning modules)
elementitems = course.active_elements(false).collect { |elem| elem.active_elementitems }.flatten

list = []
elementitems.each do |item|
  list << item
  list << item.lmitemivassocs
end

elements = list.flatten.select { |x| x.itemversion }

# Categorize algfr items by response type
algfr_list_items = elements.select { |ei| ei.itemversion.draft_code.include?("/* global list") }
algfr_free_items = elements.select { |ei| ei.itemversion.draft_code.include?("/* global free") }
algfr_interval_items = elements.select { |ei| ei.itemversion.draft_code.include?("/* global interval") }

all_algfr = algfr_list_items + algfr_free_items + algfr_interval_items

# Output all algfr items as CSV: Name, Itemversion ID, Element Item ID, Element Name
all_algfr.each do |ai|
  puts "#{ai.itemversion.item.name},#{ai.itemversion_id}, #{ai.id}, #{ai.element.name}"
end

# Output only free-response items
algfr_free_items.each do |ai|
  puts "#{ai.itemversion.item.name},#{ai.itemversion_id}, #{ai.id}, #{ai.element.name}"
end

puts all_algfr.count
