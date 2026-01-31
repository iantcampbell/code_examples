# UTCA Exam Grade Export
# Exports student exam grades for a specific learning module, including
# student name, EID, session status, calculated grade percentage, and
# orientation session information.
#
# Output format: Name, EID, Status, Grade, Orientation

begin
  course = Course.find(3261594)
  lm = Learningmodule.find(5978187)
  total_points = 250.0

  puts "Name, EID, Status, Grade, Orientation"

  lm.modulesessions.each do |ms|
    next unless ms.courseuser
    cu = ms.courseuser
    next unless cu.user
    user = cu.user

    # Calculate grade as a percentage of total points
    grade = if ms.calculated_points_earned
              ((ms.calculated_points_earned / total_points) * 100).round(2)
            else
              0
            end

    puts "#{user.firstname} #{user.lastname}, #{user.utpreferred}, #{ms.modulesessionstatus.name}, #{grade}, #{user.orientation_session}"
  end
end
