# Dot Notation Finder for Physics Courses
# Searches active physics course items for LaTeX dot-product notation (\cdot),
# used to identify items that may need notation updates or review.
#
# Scans PHY 302L and PHY 302K courses from the last 3 years.

begin
  target_abbreviations = ["PHY 302L", "PHY 302K"]
  courses = Course.where("created_at > ? AND has_student_subscriptions = ?", Time.now - 3.years, true)

  matching_course_ids = []
  item_list = []

  # Build list of matching physics courses
  puts "Building course list."
  puts

  courses.each do |c|
    next unless target_abbreviations.include?(c.abbreviation)
    puts "Course: #{c.abbreviation}"
    matching_course_ids << c.id
  end

  # Collect all unique item IDs from assignments and learning modules
  puts
  puts "Building item list."
  puts

  matching_course_ids.each do |course_id|
    c = Course.find(course_id)

    c.active_elements.each do |element|
      if element.is_a?(Assignment)
        element.assignmentitems.each do |ai|
          item_list << ai.itemversion.item_id
        end
      else # Learning Module
        element.learningmoduleitems.each do |lmi|
          next unless lmi.itemversion_id
          item_list << lmi.itemversion.item_id
        end
      end
    end

    item_list = item_list.uniq
    puts "Item count: #{item_list.count}"
  end

  # Search each item's latest version for dot notation
  puts
  puts "Searching for dot notation."
  puts

  dot_notation_items = []
  ctr = 0

  item_list.each do |item_id|
    item = Item.find(item_id)
    next unless item.itemversions

    iv = item.itemversions.last
    next unless iv.draft_body

    if iv.draft_body.include?('cdot')
      dot_notation_items << iv
      ctr += 1
    end

    puts "Total: #{ctr}"
  end

  puts "Dot item count: #{dot_notation_items.count}"
end
