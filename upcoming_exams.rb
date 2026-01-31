# Upcoming Exam Calendar Export
# Generates a CSV-formatted list of upcoming exams for import into Google Calendar
# or similar tools. Scans all active courses in a timeframe for exams starting
# within a 2-week window.
#
# Output format: Subject, Start Date, End Date, All Day Event, Description

tf = Timeframe.find(3282153)

puts "Subject, Start Date, End Date, All Day Event, Description"

tf.courses.each do |c|
  next unless c.has_student_subscriptions

  exam_types = c.assignmenttypes.where("assignmenttypemode_id = ?", 2)

  exam_types.each do |at|
    at.assignments.each do |exam|
      # Only include exams within the 2-week lookahead window
      next unless exam.start_date > Time.now - 2.days && exam.start_date < Time.now + 14.days

      subject = "#{c.primary_instructor.user.lastname} #{exam.name}"
      exam_date = "#{exam.start_date.month}/#{exam.start_date.day}/#{exam.start_date.year}"

      puts "#{subject}, #{exam_date}, #{exam_date}, True, #{c.primary_instructor.user.utpreferred} exam ID #{exam.id}"
    end
  end
end
