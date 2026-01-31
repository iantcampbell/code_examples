# Duplicate Exam Version Detector
# Identifies exams where students have multiple committed bubble-sheet versions,
# which may indicate a scanning or processing error.
#
# Usage: Iterates over a list of exam assignment IDs and reports any bubble
# identifiers that appear more than once per assignment.

begin
  # Checks a single assignment for students with duplicate bubble-sheet versions.
  def check_assignment_for_duplicate_versions(assignment_id)
    assignment = Assignment.find(assignment_id)

    # Filter to only committed exam submissions (type 2 = user committed)
    committed_exams = assignment.courseuserassignments.select { |cua| cua.courseuserassignmenttype_id == 2 }

    # Group submissions by bubble sheet identifier to detect duplicates
    grouped_by_bubble = committed_exams.group_by { |cua| cua.bubble_identifier }

    duplicates = {}

    grouped_by_bubble.each do |bubble_id, submissions|
      next if submissions.count == 1

      duplicates[bubble_id] = submissions.count
      puts "#{bubble_id}, #{submissions.count}"
    end

    return nil #replace nil with dupes to return info on duplicate bubble versions
  end

  # Exam assignment IDs to audit for duplicate bubble versions
  exam_ids = [6883307, 6883287, 6884147, 6878247, 6892407, 6892487, 6892547]

  exam_ids.each do |id|
    puts "-- Assignment #{id}: Version, Version Count --"
    check_assignment_for_duplicate_versions(id)
    puts
  end
end
