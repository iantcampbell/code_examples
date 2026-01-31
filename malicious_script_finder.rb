# Malicious Script Finder for Essay Responses
# Scans recent learning module essay responses for embedded script tags
# and CDATA sections, which may indicate XSS injection attempts.
#
# Checks all essay-type items (itemtype 6) in learning modules with
# due dates within the last 2 months, skipping known safe items.
#
# Output: Student EID and learning module details for each flagged response.

ActiveRecord::Base.logger.level = 1
ctr = 0
flagged_ids = []

Learningmodule.where("due_date > ? and name <> ?", Time.now - 2.months, "My Custom Review").each do |lm|
  items = lm.learningmoduleitems.where("learningmoduleitemtype_id = 2")

  items.each do |item|
    next if item.id == 5074168
    next if item.id == 5074169
    next if item.id == 5074170
    next unless item.itemversion&.item
    next unless item.itemversion
    next unless item.itemversion.item.itemtype_id == 6 # Essay items only

    item.modulesessionitems.each do |msi|
      msi.modulesessionitemparts.first.msipresponses.each do |response|
        next unless response.raw_response.include?("script")
        next unless response.raw_response.include?("CDATA")

        puts "**********************************************************************************"
        puts msi.modulesessionsection.modulesession.courseuser.user.utpreferred
        puts "#{lm.name} #{lm.id} #{lm.course.id}"
        flagged_ids << lm.id

        ctr += 1
      end
    end
  end
end

puts ctr
