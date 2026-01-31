# Physics Algebra Course Item Collector
# Collects and outputs all unique active item version IDs from physics algebra
# courses (PHY 302L and PHY 302K) created in the last 3 years.
#
# Used to generate a master list of items for further analysis or processing.

# Returns an array of item IDs from a learning module.
def get_lm_items(learningmodule_id)
  learningmodule_items = []
  lm = Learningmodule.find(learningmodule_id)

  lm.learningmoduleitems.each do |lmi|
    next unless lmi.itemversion_id
    learningmodule_items << lmi.itemversion.item_id
  end

  return learningmodule_items
end

# Returns an array of item IDs from an assignment.
def get_assignment_items(assignment_id)
  assignment_items = []
  a = Assignment.find(assignment_id)

  a.assignmentitems.each do |ai|
    assignment_items << ai.itemversion.item_id
  end

  return assignment_items.flatten
end

begin
  target_abbreviations = ["PHY 302L", "PHY 302K"]
  courses = Course.where("created_at > ? AND has_student_subscriptions = ?", Time.now - 3.years, true)

  matching_course_ids = []
  item_list = []

  # Build list of matching physics courses
  courses.each do |c|
    next unless target_abbreviations.include?(c.abbreviation)
    puts c.abbreviation
    matching_course_ids << c.id
  end

  # Collect all item IDs from assignments and learning modules
  matching_course_ids.each do |course_id|
    c = Course.find(course_id)

    c.active_elements.each do |element|
      if element.is_a?(Assignment)
        item_list = item_list + get_assignment_items(element.id)
      else # Learning Module
        lm_items = get_lm_items(element.id)
        item_list + lm_items
      end
    end

    puts item_list.count
  end

  # Output the active item version ID for each unique item
  unique_items = item_list.uniq

  puts
  puts
  unique_items.each do |item_id|
    item = Item.find(item_id)
    puts item.current_active_itemversion.id
  end
end
