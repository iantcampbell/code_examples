# Broken Math Link Finder
# Scans learning modules in active courses for content containing references
# to "ma.utexas.edu", which indicates outdated or broken math resource links
# that need to be updated.
#
# Outputs the learning module item IDs that contain the broken links.

begin
  institution = Institution.first
  timeframes = institution.timeframes.where("is_active = ?", true)

  ctr = 0

  timeframes.each do |tf|
    tf.courses.each do |c|
      next if c.active_elements.count == 0

      c.active_elements.each do |ae|
        next if ae.is_a?(Assignment) # Only check learning module content

        ae.learningmoduleitems.each do |lmi|
          next unless lmi.content
          next unless lmi.content.include?("ma.utexas.edu")

          puts lmi.id
          ctr += 1
        end
      end
    end
  end

  puts ctr
end
