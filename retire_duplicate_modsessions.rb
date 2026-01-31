# Duplicate Module Session Retirement Tool
# Finds students with duplicate module sessions for the same learning module
# and retires all but the highest-scoring session.
#
# Process:
#   1. Find all duplicate module sessions (excluding already retired ones)
#   2. For each duplicate set, build a grade hash to identify the best session
#   3. Retire all sessions except the one with the highest score
#   4. Verify the correct number of sessions were retired

ActiveRecord::Base.logger.level = 1

dupe_ms = Modulesession.find_duplicates.select { |x| x.modulesessionstatus_id != 3 }
saved_ms = []

total_retired_ctr = 0
error_ctr = 0

dupe_ms.each do |ms|
  next if ms.modulesessionstatus_id == 3  # Skip already retired
  next if saved_ms.include?(ms.id)        # Skip if already processed

  cu = ms.courseuser

  # Find all non-retired sessions for this student and learning module
  ms_dupes = cu.modulesessions.where("learningmodule_id = ? and modulesessionstatus_id != ?", ms.learningmodule_id, 3)

  # Build a hash of session_id => grade to find the best one
  ms_grades = {}

  ms_dupes.each do |mod|
    ms_grades[mod.id] = mod.calculated_points_earned.to_i
  end

  # Keep the session with the highest grade
  save_ms = ms_grades.key(ms_grades.values.max)
  saved_ms << save_ms

  # Retire all other duplicate sessions
  retired_ctr = 0

  ms_dupes.each do |mod|
    next if mod.id == save_ms

    mod.modulesessionstatus_id = 3 # Retired status
    retired_ctr += 1
    mod.save
  end

  puts "#{cu.user.utpreferred}: saved modsession #{save_ms}."

  # Verify the expected number of sessions were retired
  if retired_ctr != ms_dupes.count - 1
    puts "ERROR: MODSESSION #{save_ms} RETIRED COUNT."
    error_ctr += 1
  end

  total_retired_ctr += retired_ctr
end

puts "Retired #{total_retired_ctr} modsessions out of #{dupe_ms.count}."
