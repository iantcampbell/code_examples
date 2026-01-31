# Student Instance Validator
# Validates that each active student in a course has exactly one valid instance
# (submission record) per assignment or learning module. Detects cases where
# students have zero or multiple instances, which indicates a data integrity issue.
#
# Provides four levels of validation:
#   - Single assignment
#   - Single learning module
#   - All elements in a course
#   - All courses in a timeframe
#
# Invalid status and type IDs are filtered out to avoid false positives.

# Validates assignment instance counts for each student.
# Returns the number of students with incorrect instance counts.
def confirm_assignment_instances(assignment_id, print_output)
  assignment = Assignment.find(assignment_id)
  instance_errors = {}

  return 0 unless assignment.assignmentstatus_id == 2 # Must be published

  # Status/type IDs to exclude from the count
  excluded_user_statuses      = [2, 3, 31]
  excluded_submission_statuses = [6, 3, 25, 41, 31, 32, 33]
  excluded_submission_types    = [1, 3, 4, 5, 6, 7, 8, 30, 40, 41]

  assignment.course.courseusers.each do |cu|
    next if excluded_user_statuses.include?(cu.courseuserstatus_id)

    submissions = cu.courseuserassignments.where("assignment_id = ?", assignment.id)
    valid_count = 0

    submissions.each do |cua|
      next if excluded_submission_statuses.include?(cua.courseuserassignmentstatus_id)
      next if excluded_submission_types.include?(cua.courseuserassignmenttype_id)
      valid_count += 1
    end

    # Exactly 1 is correct; anything else is an error
    instance_errors[cu.user.utpreferred] = valid_count unless valid_count == 1
  end

  error_count = instance_errors.count
  puts "#{error_count}, #{assignment.id}, #{assignment.name}" if print_output
  return error_count
end

# Validates learning module session counts for each student.
# Returns the number of students with incorrect session counts.
def confirm_learningmodule_instances(learningmodule_id, print_output)
  lm = Learningmodule.find(learningmodule_id)
  instance_errors = {}

  return 0 unless lm.learningmodulestatus_id == 2 # Must be published

  excluded_user_statuses    = [2, 3, 31]
  excluded_session_statuses = [1, 3, 7, 6, 25, 41, 31, 32, 33]
  excluded_session_types    = [1, 3, 4, 30, 40, 41, 5, 6, 8]

  lm.course.courseusers.each do |cu|
    next if excluded_user_statuses.include?(cu.courseuserstatus_id)

    sessions = cu.modulesessions.where("learningmodule_id = ?", lm.id)
    valid_count = 0

    sessions.each do |ms|
      next if excluded_session_statuses.include?(ms.modulesessionstatus_id)
      next if excluded_session_types.include?(ms.modulesessiontype_id)
      valid_count += 1
    end

    instance_errors[cu.user.utpreferred] = valid_count unless valid_count == 1
  end

  error_count = instance_errors.count
  puts "#{error_count}, #{lm.id}, #{lm.name}" if print_output
  return error_count
end

# Validates all active elements in a course.
# Returns total number of instance errors across all assignments and learning modules.
def course_confirm_instance_count(course_id, print_course, print_elements)
  course = Course.find(course_id)
  total_errors = 0

  course.active_elements.each do |element|
    if element.is_a?(Assignment)
      total_errors += confirm_assignment_instances(element.id, print_elements)
    elsif element.is_a?(Learningmodule)
      total_errors += confirm_learningmodule_instances(element.id, print_elements)
    end
  end

  puts "#{total_errors}, #{course.id}, #{course.name}" if print_course
  return total_errors
end

# Validates all courses in a timeframe.
# Returns total number of instance errors across all courses.
def timeframe_confirm_instance_count(timeframe_id, print_course, print_elements)
  tf = Timeframe.find(timeframe_id)
  total_errors = 0

  tf.courses.each do |c|
    next if c.active_elements.count == 0
    total_errors += course_confirm_instance_count(c.id, print_course, print_elements)
  end

  return total_errors
end

# --- Example usage ---
begin
  confirm_assignment_instances(6682327, false)
  confirm_learningmodule_instances(3928347, false)
  course_confirm_instance_count(3115974, true, false)
  timeframe_confirm_instance_count(2730993, false, false)
end
