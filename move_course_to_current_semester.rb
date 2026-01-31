# Course Semester Migration Tool
# Moves a list of courses from their current timeframe to the institution's
# current semester. Useful when courses need to be carried over to a new term.
#
# For each course, looks up the institution and finds the current timeframe,
# then reassigns the course to that timeframe.

ActiveRecord::Base.logger.level = 1
ctr = 0

course_ids = [77115, 75854, 75845, 77116, 77117, 75855, 77118, 75857, 75847, 75849,
              75851, 77119, 77244, 75848, 75852, 75850, 75853, 75859, 77122, 77123,
              75856, 79047]

course_ids.each do |course_id|
  c = Course.find(course_id)
  puts c.name

  # Find the current timeframe for this course's institution
  institution = c.timeframe.institution
  puts institution.name

  current_tf = Timeframe.where("institution_id = ? and is_current = ?", institution.id, true).first
  puts current_tf.abbreviation

  # Reassign the course to the current timeframe
  c.timeframe_id = current_tf.id
  ctr += 1
  puts c.timeframe_id
  c.save
end

puts ctr
