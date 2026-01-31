# One Free Try Scoring Type Auditor
# Finds assignment types using "One Free Try" scoring (scoring_type 2) in current
# timeframes and ensures all their active elements have the correct scoring type.
# Corrects any mismatches by updating the element's scoring type to match.
#
# Outputs the ID and assignment type mode of any elements that were corrected.

# Get all "One Free Try" assignment types in current semesters
assignment_types = Assignmenttype.where("scoringtype_id = ?", 2)
assignment_types = assignment_types.select { |at| at.course.timeframe.is_current == true }

element_count = 0
correct_count = 0
corrected_count = 0

assignment_types.each do |at|
  at.active_elements.each do |element|
    element_count += 1

    # Skip elements already set to the correct scoring type
    if element.scoringtype_id == 2
      correct_count += 1
      next
    end

    # Correct the scoring type mismatch
    element.scoringtype_id = 2
    element.save
    puts "#{element.id}: #{element.assignmenttype.assignmenttypemode_id}"
    corrected_count += 1
  end
end
