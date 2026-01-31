# Partial Credit Override for Alternate Correct Answers
# Awards points to students who selected a specific answer choice that was
# initially marked incorrect but was later determined to be acceptable.
#
# Works by:
#   1. Finding the target item within an assignment
#   2. Iterating through each student's submission
#   3. Checking if the student's response matches the alternate correct position
#      (accounting for randomized choice ordering)
#   4. Overriding the score if the alternate answer was selected
#
# Note: Choice positions are randomized per student, so the script maps the
# original position to each student's shuffled position before comparing.

ActiveRecord::Base.logger.level = 1

admin_user = User.find(1)
TARGET_CHOICE_POSITION = 8  # Original position of the alternate correct answer
POINTS_TO_AWARD = 10

# --- Step 1: Identify the target assignment item ---
assignment = Assignment.find(1200883)
target_item_id = nil

assignment.assignmentitems.each do |ai|
  next unless ai.itemversion.id == 196576

  ai.assignmentitemparts.each do |aiparts|
    puts "#{assignment.name} #{ai.name} #{ai.itemversion_id} #{aiparts.id}"
    target_item_id = ai.id
  end
end

# --- Step 2: Review each student's submission and override scores ---
student_submissions = Courseuserassignment.where(assignment_id: assignment.id)
credit_count = 0

student_submissions.each do |cua|
  next if cua.calculated_points_earned.nil?
  next if cua.calculated_points_earned == 0

  cua.courseuserassignmentitems.each do |cuaitem|
    next unless cuaitem.assignmentitem_id == target_item_id

    cuaip = cuaitem.cuaips.last
    next if cuaip.cuaiprs.count < 1

    response = cuaip.cuaiprs.first.raw_response

    # Map the original correct position to this student's randomized position
    correct_position = cuaip.cuaipchoices
                            .where(old_position: TARGET_CHOICE_POSITION)
                            .first.new_position

    if response.to_i == correct_position.to_i
      credit_count += 1
      puts "#{cua.courseuser.user.utpreferred} correct"
      cuaip.override_score_raw(admin_user, POINTS_TO_AWARD)
    else
      puts "#{cua.courseuser.user.utpreferred} incorrect"
      cuaip.override_score_raw(admin_user, 0)
    end

    puts "#{assignment.name} #{cua.courseuser.user.utpreferred}  #{cuaitem.id} #{cuaitem.assignmentitem.itemversion_id} #{cuaip.id} #{cuaip.calculated_points_earned}"
    puts "response: #{response} semi-correct: #{correct_position}"
  end
end

puts credit_count
