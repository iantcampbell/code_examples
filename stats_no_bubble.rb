# Platform-Wide Statistics Dashboard
# Generates a comprehensive snapshot of system usage metrics including:
#   - Active course counts (billable UT, billable external, high school, non-billable)
#   - Unique user and courseuser counts
#   - High school institution count
#   - Courses with upcoming assignments
#   - Weekly and lifetime response counts (assignment + learning module)
#
# Categorizes courses by institution type and billing status to provide
# a full overview of platform activity.

ActiveRecord::Base.logger.level = 1

future_assignment_ctr = 0
active_courseuser_ctr = 0
user_array = []
hs_institution_array = []
nonbillable_ut_course_ctr = 0
nonbillable_ut_courseuser_ctr = 0
billable_ut_course_ctr = 0
hs_course_ctr = 0
billable_external_course_ctr = 0

c = Course.where("access_end > ?", Time.now)

c.each do |course|
  # Count billable UT courses
  if course.timeframe.institution.id == Institution::UTEXAS_ID &&
     course.has_student_subscriptions &&
     course.timeframe.is_current &&
     course.coursestatus.id != Coursestatus::RETIRED
    billable_ut_course_ctr += 1
  end

  # Count billable external courses
  if course.timeframe.institution.id != Institution::UTEXAS_ID &&
     course.has_student_subscriptions &&
     course.timeframe.is_current &&
     course.coursestatus.id != Coursestatus::RETIRED
    billable_external_course_ctr += 1
  end

  # Track high school courses and institutions
  if course.timeframe.institution.institutiontype_id == Institutiontype::HIGH_SCHOOL
    hs_course_ctr += 1
    hs_institution_array.push(course.timeframe.institution_id)
  end

  # Count courses with future assignments
  a = course.assignments
  if a.where("due_date > ?", Time.now).count > 0
    future_assignment_ctr += 1
  end

  # Count active courseusers for billable courses
  if course.timeframe.institution.id != Institution::UTEXAS_ID || course.has_student_subscriptions
    cu = course.active_courseusers
    cu.each do |courseuser|
      user_array.push(courseuser.user_id)
    end

    active_courseuser_ctr += cu.count
  else
    # Track non-billable UT courses separately
    if course.timeframe.institution.id == Institution::UTEXAS_ID && !course.has_student_subscriptions
      nonbillable_ut_course_ctr += 1
      nonbillable_ut_courseuser_ctr += course.active_courseusers.count
    end
  end
end

# Weekly activity metrics
a = Assignment.where("publication_date > ?", Time.now - 7.days).count
cuaipr = Cuaipr.where("created_at > ?", Time.now - 7.days).count
msipr = Msipresponse.where("created_at > ?", Time.now - 7.days).count
weekly_responses = cuaipr + msipr

# Lifetime response totals
cuaipr_lifetime = Cuaipr.count
msipr_lifetime = Msipresponse.count
total_responses = cuaipr_lifetime + msipr_lifetime

# Output summary
puts "active course count: #{c.count}
unique active user count: #{user_array.uniq.count}
active courseuser count: #{active_courseuser_ctr}
billable UT courses: #{billable_ut_course_ctr}
billable external courses: #{billable_external_course_ctr}
active high school courses: #{hs_course_ctr}
active high schools: #{hs_institution_array.uniq.count}
nonbillable UT courses: #{nonbillable_ut_course_ctr}
nonbillable UT courseusers: #{nonbillable_ut_courseuser_ctr}
courses with assignment due in the future: #{future_assignment_ctr}
assignments published in past week: #{a}
cua responses in past week: #{cuaipr}
learning module responses in past week: #{msipr}
total responses in past week: #{weekly_responses}
total responses submitted over life of system: #{total_responses}
cua responses submitted over life of system: #{cuaipr_lifetime}
modsession responses submitted over life of system: #{msipr_lifetime}"
