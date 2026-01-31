# UTCA Exam Timing and Performance Analysis
# Analyzes exam completion times and per-item timing statistics for a learning
# module. Calculates median and average completion times at both the exam level
# and individual item level.
#
# Provides insight into:
#   - Overall exam completion time distribution (median and average)
#   - Per-item time spent (median and average per item version)
#   - Per-student median item completion time
#
# Output:
#   Line 1 per student: EID, Grade, Total Time (min), Median Item Time (min)
#   Summary: Median/Average exam completion times, per-item timing stats

begin
  lm = Learningmodule.find(5978187)
  total_points = 250.0

  exam_completion_times = []
  item_stats = {}

  # Initialize per-item tracking arrays
  lm.learningmoduleitems.each do |lmi|
    next unless lmi.itemversion_id
    item_stats[lmi.itemversion_id.to_s] = []
  end

  # --- Collect per-student timing data ---
  lm.modulesessions.each do |ms|
    next unless ms.courseuser
    next unless ms.courseuser.user
    next unless ms.start_timer

    eid = ms.courseuser.user.utpreferred
    grade = ((ms.calculated_points_earned / total_points) * 100).round(2)

    unless ms.completed_date
      puts "#{eid}, #{grade}, hasn't completed"
      next
    end

    student_item_times = []

    ms.modulesessionitems.each do |msi|
      next unless msi.learningmoduleitem.itemversion_id

      # Calculate time spent on each item in minutes
      time_on_item = ((msi.completed - msi.viewed) / 60.0).round(2)
      item_stats[msi.learningmoduleitem.itemversion_id.to_s] << time_on_item
      student_item_times << time_on_item
    end

    # Total exam time in minutes
    time_to_complete = ((ms.completed_date - ms.start_timer) / 60.0).round(2)
    exam_completion_times << time_to_complete

    # Calculate median item time for this student
    sorted = student_item_times.sort
    mid = sorted.length / 2
    median_item_time = sorted.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1])

    puts "#{eid}, #{grade}, #{time_to_complete}, #{median_item_time.round(2)}"
  end

  puts

  # --- Exam-level summary statistics ---
  total_time = exam_completion_times.sum
  sorted_times = exam_completion_times.sort
  mid = sorted_times.length / 2

  average_completion_time = (total_time / sorted_times.count).round(2)
  median_completion_time = sorted_times.length.odd? ? sorted_times[mid] : 0.5 * (sorted_times[mid] + sorted_times[mid - 1])

  puts "Median Exam Completion Time, #{median_completion_time}"
  puts "Average Exam Completion Time, #{average_completion_time}"

  # --- Per-item timing statistics ---
  puts
  puts "Itemversion, Median time on item, Average time on item"

  item_stats.each do |itemversion_id, times|
    total_item_time = times.sum
    sorted = times.sort
    mid = sorted.length / 2

    median_item_time = sorted.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1])
    average_item_time = (total_item_time / times.count).round(2)

    puts "#{itemversion_id}, #{median_item_time}, #{average_item_time}"
  end
end
