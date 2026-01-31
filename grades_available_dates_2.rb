# Grades Available Date Auditor
# Scans published exams across a timeframe to identify exams with missing or
# future grades-available dates. Excludes practice/sample exams.
#
# Two passes:
#   1. Finds exams where grades_available_date is nil (never set)
#   2. Finds exams where grades_available_date is in the future (not yet released)

ActiveRecord::Base.logger.level = 1
include Formats::Dateformats

EXCLUDED_KEYWORDS = ["test", "sample", "Sample", "Practice", "practice", "PRA"]

# --- Pass 1: Exams with no grades available date ---
ctr = 0

t = Timeframe.find(155614)
t.courses.each do |course|
  next if course.active_elements.count == 0

  published_exams = course.assignments.where("assignmentstatus_id = ?", Assignmentstatus::PUBLISHED_ID)

  published_exams.each do |exam|
    next unless exam.assignmenttype.assignmenttypemode_id == 2  # Exam type only
    next unless exam.grades_available_date.nil?
    next if EXCLUDED_KEYWORDS.any? { |kw| exam.name.include?(kw) }

    puts "Course: #{exam.course.courseuniques.first.name}, Instructor: #{exam.course.courseinstructors.first.user.lastname}, Assignment: #{exam.name} #{exam.grades_available_date}"
    ctr += 1
  end
end

puts ctr


# --- Pass 2: Exams with future grades available dates ---
ctr = 0

t = Timeframe.find(155614)
t.courses.each do |course|
  next if course.active_elements.count == 0

  published_exams = course.assignments.where("assignmentstatus_id = ?", Assignmentstatus::PUBLISHED_ID)

  published_exams.each do |exam|
    next unless exam.assignmenttype.assignmenttypemode_id == 2  # Exam type only
    next if exam.grades_available_date.nil?
    next if exam.grades_available_date < Time.now
    next if EXCLUDED_KEYWORDS.any? { |kw| exam.name.include?(kw) }

    puts "Course: #{exam.course.courseuniques.first.name}, Instructor: #{exam.course.courseinstructors.first.user.lastname}, Assignment: #{exam.name} #{exam.grades_available_date}"
    ctr += 1
  end
end

puts ctr
