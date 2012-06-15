status :draft
section_slug "work"

# https://www.pivotaltracker.com/story/show/31084569

multiple_choice :work_the_same_number_of_days_each_week? do
  option "same-number-of-days" => :how_many_days_per_week?
  option "different-number-of-days" => :how_many_total_days?
end

multiple_choice :how_many_days_per_week? do
  option "6-or-more-days"
  option "5-to-6-days"
  option "4-to-5-days"
  option "3-to-4-days"
  option "2-to-3-days"
  option "1-to-2-days"
  option "up-to-1-day"

  calculate :days_worked_per_week do
    # XXX: this is a bit nasty and takes advantage of the fact that
    # to_i only looks for the very first integer, hence allowing us to
    # bypass the "5-6" etc. issue
    responses.last.to_i + 1
  end

  next_node :worked_for_same_employer?
end

multiple_choice :worked_for_same_employer? do
  option "same-employer" => :done
  option "multiple-employers" => :how_many_total_days?

  calculate :holiday_entitlement_days do
    if responses.last == 'same-employer'
      if !days_worked_per_week.nil?
        if days_worked_per_week > 6
          38
        elsif days_worked_per_week <= 6 && days_worked_per_week > 5
          35
        elsif days_worked_per_week <= 5 && days_worked_per_week > 4
          31
        elsif days_worked_per_week <= 4 && days_worked_per_week > 3
          25
        elsif days_worked_per_week <= 3 && days_worked_per_week > 2
          20
        elsif days_worked_per_week <= 2 && days_worked_per_week > 1
          13
        else
          7.5
        end
      end
    else
      nil
    end
  end
end

value_question :how_many_total_days? do
  save_input_as :total_days_worked
  next_node :what_date_does_holiday_start?
end

date_question :what_date_does_holiday_start? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :holiday_start_date

  calculate :weeks_until_october_1 do
  end

  next_node :worked_for_same_employer?
end

outcome :done
