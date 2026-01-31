# UT Item Usage Tracker
# Collects and counts item version usage across all active UT courses,
# separated by department (math vs. physics). Provides helper methods for
# extracting items from assignments and learning modules.
#
# Excludes test/admin instructor accounts and chemistry courses.
# Outputs unique item counts per department and a master list of unique item IDs.

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

# Returns all item IDs from a course's active assignments and learning modules.
def loop_course_assignments(course_id)
  course_items = []
  c = Course.find(course_id)

  c.active_elements.each do |ae|
    if ae.is_a?(Assignment)
      course_items.push(*get_assignment_items(ae.id)).flatten
    else
      course_items.push(*get_lm_items(ae.id)).flatten
    end
  end

  return course_items.flatten
end

# IDs to exclude (test/admin instructors)
EXCLUDED_INSTRUCTOR_IDS = [84073, 3, 4994346]

# --- Collect item usage by department across recent semesters ---
begin
  math_items = {}
  phy_items = {}

  i = Institution.find(1)

  i.timeframes.last(9).each do |tf|
    # Math department (department_id = 2)
    tf.courses.where("has_student_subscriptions = ? AND department_id = ?", true, 2).each do |c|
      next if c.active_elements.count == 0
      next if EXCLUDED_INSTRUCTOR_IDS.include?(c.primary_instructor.user_id)

      c.active_elements.each do |ae|
        next unless ae.published?

        items = ae.is_a?(Assignment) ? get_assignment_items(ae.id) : get_lm_items(ae.id)

        items.each do |x|
          math_items[x] = (math_items[x] || 0) + 1
        end
      end

      puts "#{c.id} Done"
    end

    puts
    puts "end of math"
    puts

    # Physics department (department_id = 3)
    tf.courses.where("has_student_subscriptions = ? AND department_id = ?", true, 3).each do |c|
      next if c.active_elements.count == 0
      next if EXCLUDED_INSTRUCTOR_IDS.include?(c.primary_instructor.user_id)

      c.active_elements.each do |ae|
        next unless ae.published?

        items = ae.is_a?(Assignment) ? get_assignment_items(ae.id) : get_lm_items(ae.id)

        items.each do |x|
          phy_items[x] = (phy_items[x] || 0) + 1
        end
      end

      puts "#{c.id} Done"
    end
  end

  puts
  puts math_items.count
  puts phy_items.count
end


# --- Collect all unique item IDs across all departments ---
begin
  itemversions = []

  i = Institution.find(1)

  i.timeframes.last(9).each do |tf|
    tf.courses.where("has_student_subscriptions = ?", true).each do |c|
      next if c.active_elements.count == 0
      next if EXCLUDED_INSTRUCTOR_IDS.include?(c.primary_instructor.user_id)
      next if c.name.downcase.include?("chemistry")

      puts "#{c.name} #{c.active_elements.count}"

      c.active_elements.each do |ae|
        if ae.is_a?(Assignment)
          next if ae.assignmentitems.count == 0
          ae.assignmentitems.each do |ai|
            itemversions << ai.itemversion_id
          end
        else
          ae.learningmoduleitems.each do |lmi|
            next unless lmi.itemversion_id
            itemversions << lmi.itemversion_id
          end
        end
      end
    end
  end

  puts
  puts itemversions.count

  itemversions = itemversions.uniq
  puts
  puts itemversions.count

  # Resolve item version IDs to unique item IDs
  items = []
  itemversions.each do |iv|
    itemversion = Itemversion.find(iv)
    items << itemversion.item_id
  end

  items = items.uniq
  items.each do |x|
    puts x
  end
end
