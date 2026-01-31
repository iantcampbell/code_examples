# Readiness Assignment Type Score Exporter
# Reads student EIDs from a file and exports their average scores for
# readiness-related assignment types (Log, Trig, and Functions categories).
#
# For each student, calculates the average score across all attempted instances
# of each matching assignment type within a specific course.
#
# Output format: EID, Average1, Average2, Average3 (one per matching atype)

found = false
infile = File.open("/tmp/math2017")

infile.each do |line|
  line = line.chomp.to_s

  # Start processing from a specific student onward
  if line.include?("bdn437")
    found = true
  end
  next unless found

  user = User.find_by_encrypted_utpreferred(line)

  if !user.first
    puts "#{line},0,0,0"
    next
  end

  # Find the student's enrollment in the target course
  cu = user.first.courseusers.select { |x| x.courseunique_id == 96602 }.first

  if !cu
    puts "#{user.first.utpreferred},0,0,0"
    next
  end

  response_string = user.first.utpreferred

  # Calculate average scores for readiness assignment types (Log, Trig, Functions)
  cu.assignmenttypecourseusers.order(assignmenttype_id: :desc).each do |a|
    atcu = Assignmenttypecourseuser.find(a.id)

    # Only process readiness-related assignment types
    next unless atcu.assignmenttype.name.include?("Log") ||
                atcu.assignmenttype.name.include?("Trig") ||
                atcu.assignmenttype.name.starts_with?("Functions")

    instances = atcu.assignmenttype.instances_for_courseuser(cu)
    next if instances.count == 0

    average = 0
    average_tally = 0
    good_count = 0

    instances.each do |instance|
      next if instance.number_of_attempted_instanceparts == 0
      average_tally += instance.points_earned_percent(true).to_f
      good_count += 1.0
    end

    if good_count > 0
      average = (average_tally / good_count)
    end

    response_string << ",#{average.round(0)}"
  end

  puts response_string
end
