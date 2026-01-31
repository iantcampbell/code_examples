# UTMA Learning Module Grade Export
# Exports student grades for multiple learning modules in a simple CSV format.
# Skips students with no score or a zero score.
#
# Output format: EID, Points Earned (per learning module, separated by blank lines)

lm_ids = [4256607, 4373587, 4433787, 4433727]

lm_ids.each do |lm_id|
  puts lm_id

  lm = Learningmodule.find(lm_id)

  lm.modulesessions.each do |ms|
    next unless ms.calculated_points_earned
    next if ms.calculated_points_earned == 0.0

    puts "#{ms.courseuser.user.utpreferred}, #{ms.calculated_points_earned}"
  end

  puts
end
