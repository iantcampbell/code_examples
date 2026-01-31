# OnRamps Course Provisioning System
# Automates the creation and configuration of OnRamps dual-enrollment physics
# courses for high school instructors. Reads instructor data from a file,
# creates courses from templates, assigns instructors, and publishes content.
#
# Workflow:
#   1. Read instructor list from file (format: "PHY1,EID" or "PHY2,EID")
#   2. Create course from appropriate physics template
#   3. Add primary and secondary instructors
#   4. Publish all assignments
#   5. Enable async and link enrollment
#   6. Output enrollment URL for each course

# Creates a PHY1 (Mechanics, Heat, and Sound) course for a high school instructor.
def create_phy1_course(tf, inst_of_record, hs_instructor, template_course)
  # Generate course info from high school instructor name
  primary_unique_name = "#{hs_instructor.lastname.capitalize}#{hs_instructor.firstname[0, 1].upcase}PHY1"
  course_name = "Mechanics, Heat, and Sound - #{hs_instructor.lastname.titleize} #{hs_instructor.firstname[0, 1].upcase}"
  course_abbreviation = "#{hs_instructor.lastname.capitalize} #{hs_instructor.firstname[0, 1].upcase}. PHY1"

  # Ensure unique name doesn't already exist
  unless Courseunique.check_uniqueness(tf, primary_unique_name)
    puts "#{hs_instructor.utpreferred} duplicate course unique"
    return
  end

  # Create the course from template
  c = Course.init(inst_of_record, tf, nil)
  primary_unique = Courseunique.new
  primary_unique.name = primary_unique_name

  c.name = course_name
  c.abbreviation = course_abbreviation
  c.department_id = 30010  # OnRamps Physics
  c.subject_id = 33745     # OnRamps Physics

  c.create(primary_unique, [], inst_of_record, Coursestatus::VISIBLE_TO_PR_SEC_ST_ID, inst_of_record, template_course)
  c.add_instructor(hs_instructor, 7, 8, inst_of_record, true) # Add HS instructor as LA

  return c
end

# Creates a PHY2 (EM, Optics, and Nuclear Physics) course for a high school instructor.
def create_phy2_course(tf, inst_of_record, hs_instructor, template_course)
  # Generate course info from high school instructor name
  primary_unique_name = "#{hs_instructor.lastname.capitalize}#{hs_instructor.firstname[0, 1].upcase}PHY2"
  course_name = "EM, Optics, and Nuclear Physics - #{hs_instructor.lastname.titleize} #{hs_instructor.firstname[0, 1].upcase}"
  course_abbreviation = "#{hs_instructor.lastname.capitalize} #{hs_instructor.firstname[0, 1].upcase}. PHY2"

  # Ensure unique name doesn't already exist
  unless Courseunique.check_uniqueness(tf, primary_unique_name)
    puts "#{hs_instructor.utpreferred} duplicate course unique"
    return
  end

  # Create the course from template
  c = Course.init(inst_of_record, tf, nil)
  primary_unique = Courseunique.new
  primary_unique.name = primary_unique_name

  c.name = course_name
  c.abbreviation = course_abbreviation
  c.department_id = 30010  # OnRamps Physics
  c.subject_id = 33745     # OnRamps Physics

  c.create(primary_unique, [], inst_of_record, Coursestatus::VISIBLE_TO_PR_SEC_ST_ID, inst_of_record, template_course)
  c.add_instructor(hs_instructor, 7, 8, inst_of_record, true) # Add HS instructor as LA

  return c
end

# Adds primary and secondary OnRamps instructors to a course.
def add_onramps_instructors(primary_eids, secondary_eids, course, inst_of_record)
  count = 0

  primary_eids.each do |eid|
    instructor = User.find_by_encrypted_utpreferred(eid)
    course.add_instructor(instructor, 2, 4, inst_of_record, true)
    count += 1
  end

  secondary_eids.each do |eid|
    instructor = User.find_by_encrypted_utpreferred(eid)
    course.add_instructor(instructor, 2, 2, inst_of_record, true)
    count += 1
  end

  return count
end

# Publishes all active elements in a course.
def publish_assignments(course)
  publisher = User.find_by_encrypted_utpreferred('itc78')
  course.active_elements.each do |ae|
    ae.request_publish(publisher, 0)
  end
end

# --- Main: Create courses from instructor file ---
begin
  tf = Timeframe.find(3339293)
  phy1_template = Course.find(3255234)
  phy2_template = Course.find(3255254)

  primary_instructor = User.find_by_encrypted_utpreferred('ht7437')
  primary_instructors_to_add = []
  secondary_instructors_to_add = ['rc46338']

  File.readlines("/tmp/onramps_july29").each do |line|  # Format: "PHY1,EID" or "PHY2,EID"
    phy_number = line.split(',').first
    hs_eid = line.split(',').second
    hs_instructor = User.find_by_encrypted_utpreferred(hs_eid)

    # Create course from the appropriate physics template
    if phy_number.downcase == 'phy1'
      c = create_phy1_course(tf, primary_instructor, hs_instructor, phy1_template)
    elsif phy_number.downcase == 'phy2'
      c = create_phy2_course(tf, primary_instructor, hs_instructor, phy2_template)
    else
      puts "Bad phy abbreviation in file"
      next
    end

    add_onramps_instructors(primary_instructors_to_add, secondary_instructors_to_add, c, primary_instructor)

    sleep(15) # Wait for background jobs to complete
    publish_assignments(c)

    # Enable enrollment options
    c.can_async_enroll = true
    c.can_link_enroll = true
    c.sort_pdf_by_last_name = true
    c.save

    puts "https://quest.cns.utexas.edu/external/async/enroll_student?courseunique=#{c.courseuniques.first.id}&uin=abcdefghij&mvs_token=7755030100CA477B&"
  end
end
