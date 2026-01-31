# UTMA Participation Report
# Exports student participation data for a specific learning module, showing
# each student's score as a percentage of total possible points.
#
# Filters out students without a course user record, score, or start time.
#
# Output format: EID, Percent Score

lm = Learningmodule.find(4256607)
total_points = 200.0

lm.modulesessions.each do |ms|
  next unless ms.courseuser
  next unless ms.calculated_points_earned
  next unless ms.start_timer

  percent = (ms.calculated_points_earned / total_points) * 100
  puts "#{ms.courseuser.user.utpreferred}, #{percent}"
end
