# OnRamps Exam Data Exporter
# Exports detailed exam response data for OnRamps courses to a file.
# For a specific instructor's courses in a given semester, collects each
# student's responses, scores, and correct answers for Exam 1.
#
# Output: Written to "onramps.txt" with student scores and per-item response details.

coursectr = 0
ctr = 0
f = File.new("onramps.txt", 'w')

# Find all courses for the target instructor
instructor = User.find_by_encrypted_utpreferred("elz75").first

Courseinstructor.where("user_id = ?", instructor.id).each do |ci|
  c = ci.course
  next unless c.timeframe.abbreviation == "20169"
  next if c.name.include?("PHY")
  next if c.name.include?("Physics")
  coursectr += 1

  next unless c.active_elements.count > 0

  c.active_elements.each do |a|
    next if a.is_a?(Learningmodule)
    next unless a.name.include?("Exam 1")

    puts "#{a.id} #{c.name} #{c.timeframe.abbreviation} #{a.name}"
    ctr += 1

    # Export each student's submission details
    a.courseuserassignments.each do |cua|
      next unless cua.courseuser
      next if cua.calculated_points_earned.to_i == 0

      # Write summary to file and console
      f << "#{c.timeframe.institution.name} #{a.name}\n"
      f << "#{cua.courseuser.user.lastname_comma_firstname} #{cua.courseuser.user.utpreferred}\n"
      f << "Total points: #{cua.calculated_points_earned}\n"
      f << "Possible points: #{a.point_value}\n"
      f << "Score: #{cua.points_earned_percent(true)}\n"

      puts "#{c.timeframe.institution.name} #{a.name}"
      puts "#{cua.courseuser.user.lastname_comma_firstname} #{cua.courseuser.user.utpreferred}"
      puts "Total points: #{cua.calculated_points_earned}"
      puts "Possible points: #{a.point_value}"
      puts "Score: #{cua.points_earned_percent(true)}"

      # Write per-item response details
      cua.instanceparts.each do |iip|
        next if iip.responses.count == 0

        name = iip.iteminstancepart.itempart.itemversion_id
        resp = iip.responses.first.unscrambled_value ? iip.responses.first.unscrambled_value.to_s : iip.responses.first.raw_response.to_s

        f << "#{cua.courseuser.user.utpreferred} #{name} #{resp} #{iip.correct_answer_mapped_back_to_unscrambled_value.value} #{iip.calculated_points_earned}\n"
        puts "#{cua.courseuser.user.utpreferred} #{name} #{resp} #{iip.correct_answer_mapped_back_to_unscrambled_value.value} #{iip.calculated_points_earned}"
      end
    end
  end
end

f.close
puts ctr
puts coursectr
