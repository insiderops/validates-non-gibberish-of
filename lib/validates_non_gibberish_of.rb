# Adds Gibberish checking functionality to strings, then uses it in ActiveRecord

class String
  LONGEST_WORD = 29 # Floccinaucinihilipilification (29 chars) (non technical)

  # Tests if string contains no spaces, too much consecutive punctuation
  # URLs are excepted
  def gibberish?
    # Fail if it has no spaces at all
    return true if self !~ /\s/

    # Gibberish if it contains more than 5 consecutive pieces of punctuation
    return true if self =~ /[!-._:;+=]{5}/

    # Check beginning, middle, and end
    samples = [
      self[0,LONGEST_WORD], # start
      self[-LONGEST_WORD..-1], # end
      self[((self.length / 2) - (LONGEST_WORD / 2))..((self.length / 2)+(LONGEST_WORD / 2))] # middle
    ]

    samples.each do |sample|
      # URLs are OK
      next if sample =~ /(http\:|https\:|www\.|\/|-|_)/

      # Gibberish if it doesn't contain whitespace
      return true if sample !~ /\s/
    end
    false
  end
end


# Bind into ActiveRecord
module ActiveRecord
  module Validations
    module ClassMethods
      # Prevent gibberish (nonsensical text) from being saved
      def validates_non_gibberish_of(*attr_names)
        validates_each(attr_names) do |record, attr_name, value|
          record.errors.add(attr_name, "contains too much gibberish") if value.to_s.gibberish?
        end      
      end
    end   
  end
end
