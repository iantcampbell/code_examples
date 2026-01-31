# OnRamps Course Item Extractor
# Extracts item IDs from OnRamps course assignments and learning modules.
# Provides helper methods for retrieving items from either element type,
# then outputs all item version IDs per assignment.

# Returns an array of item IDs from a learning module's items.
def get_lm_items(learningmodule_id)
  learningmodule_items = []
  lm = Learningmodule.find(learningmodule_id)

  lm.learningmoduleitems.each do |lmi|
    next unless lmi.itemversion_id
    learningmodule_items << lmi.itemversion.item_id
  end

  return learningmodule_items
end

# Returns an array of item IDs from an assignment's items.
def get_assignment_items(assignment_id)
  assignment_items = []
  a = Assignment.find(assignment_id)

  a.assignmentitems.each do |ai|
    assignment_items << ai.itemversion.item_id
  end

  return assignment_items.flatten
end

# Output item version IDs for each assignment in the specified courses
onramps_courses = [3255254]

onramps_courses.each do |course_id|
  c = Course.find(course_id)

  c.active_elements.each do |ae|
    next if ae.id == 5388507 # Skip specific excluded element

    puts ae.name
    ae.assignmentitems.each do |item|
      puts item.itemversion.id
    end
    puts
  end
end
