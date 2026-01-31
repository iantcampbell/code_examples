# High School Institution Enrollment Report
# Generates a CSV report of course enrollment trends for high school partner
# institutions, broken down by year (2019-2024).
#
# Filters for specific partner institutions, then counts courses per semester
# that have active students and content.
#
# Output format: State, School ID, School Name, Total Courses, 2019, 2020, 2021, 2022, 2023, 2024

institution_ids = [
  643, 954, 17749, 1083, 1800, 63, 66, 683, 8602, 150, 178, 11105, 4002, 5008,
  12587, 17563, 219, 4893, 262, 811, 9542, 2803, 257, 912, 12742, 16225, 17703,
  379, 8824, 397, 475, 748, 863, 1396, 1400, 1918, 1982, 1990, 2140, 2605, 2691,
  2771, 6042, 8682, 5010, 6702, 8812, 5503, 12522, 14102, 13782, 17443, 17524,
  17704, 18104, 2414, 17884, 21064843, 560, 5004, 17663, 17143, 579
]

institution_ids.each do |inst_id|
  institution = Institution.find(inst_id)
  total_course_count = 0

  # Initialize per-year counters
  semester_course_counts = {
    "2019" => 0, "2020" => 0, "2021" => 0,
    "2022" => 0, "2023" => 0, "2024" => 0
  }

  # Count courses per semester that have enrolled students and active content
  institution.timeframes.where("created_at > ? AND is_active = ?", Time.now - 65.months, true).each do |tf|
    active_courses = tf.courses.select { |c| c.courseusers.count > 1 }
    next if active_courses.count == 0

    active_courses = active_courses.select { |c| c.active_elements.count > 1 }
    next if active_courses.count == 0

    semester = tf.abbreviation[0..3] # Extract year from abbreviation
    next unless semester_course_counts[semester]

    semester_course_counts[semester] += active_courses.count
    total_course_count += active_courses.count
  end

  next if total_course_count == 0

  puts "#{institution.city.state.name}, #{institution.id}, #{institution.name}, #{total_course_count}, " \
       "#{semester_course_counts["2019"]}, #{semester_course_counts["2020"]}, " \
       "#{semester_course_counts["2021"]}, #{semester_course_counts["2022"]}, " \
       "#{semester_course_counts["2023"]}, #{semester_course_counts["2024"]}"
end
