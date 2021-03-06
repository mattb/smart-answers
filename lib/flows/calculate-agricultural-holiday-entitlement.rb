status :draft
section_slug "work"

calculator = AgriculturalHolidayEntitlementCalculator.new()

# https://www.pivotaltracker.com/story/show/31084569

multiple_choice :work_the_same_number_of_days_each_week? do
  option "same-number-of-days" => :how_many_days_per_week?
  option "different-number-of-days" => :what_date_does_holiday_start?
end

multiple_choice :how_many_days_per_week? do
  option "7-days"
  option "6-days"
  option "5-days"
  option "4-days"
  option "3-days"
  option "2-days"
  option "1-day"

  calculate :days_worked_per_week do
    # XXX: this is a bit nasty and takes advantage of the fact that
    # to_i only looks for the very first integer
    responses.last.to_i
  end

  next_node :worked_for_same_employer?
end

date_question :what_date_does_holiday_start? do
  from { Date.civil(Date.today.year, 1, 1) }
  to { Date.civil(Date.today.year, 12, 31) }
  save_input_as :holiday_start_date

  calculate :weeks_from_october_1 do
    calculator.weeks_worked(responses.last)
  end

  next_node :how_many_total_days?
end

multiple_choice :worked_for_same_employer? do
  option "same-employer" => :done
  option "multiple-employers" => :how_many_weeks_at_current_employer?

  calculate :holiday_entitlement_days do
    if responses.last == 'same-employer'
      # This is calculated as a flat number based on the days you work
      # per week
      if !days_worked_per_week.nil?
        calculator.holiday_days(days_worked_per_week)
      elsif !weeks_from_october_1.nil?
        calculator.holiday_days total_days_worked.to_f / weeks_from_october_1.to_f
      end
    else
      nil
    end
  end
end

value_question :how_many_total_days? do
  calculate :total_days_worked do
    if responses.last.to_i > calculator.available_days
      raise SmartAnswer::InvalidResponse, "Please enter a valid number of days (max: #{calculator.available_days})"
    end
    responses.last
  end

  next_node :worked_for_same_employer?
end

value_question :how_many_weeks_at_current_employer? do
  next_node :done

  calculate :holiday_entitlement_days do
    if !days_worked_per_week.nil?
      days = calculator.holiday_days(days_worked_per_week)
    elsif !weeks_from_october_1.nil?
      days = calculator.holiday_days total_days_worked.to_f / weeks_from_october_1.to_f
    end
    sprintf("%.1f", days * (responses.last.to_i / 52.0))
  end
end

outcome :done
