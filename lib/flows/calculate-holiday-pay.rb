group :what_period_for? do
  
  multiple_choice :period do
    option :full_year => :is_the_employee_paid_hourly_or_daily?
    option :part_of_year
  end                   
  
  multiple_choice :starting_or_leaving? do
    option :starting
    option :leaving
  end              
  
  date_question :start_date
  
end

outcome :done