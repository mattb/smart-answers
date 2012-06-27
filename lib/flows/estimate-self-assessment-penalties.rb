status :draft

satisfies_need "B692"

CALCULATOR_DATES = {
  :online_filing_deadline => Date.new(2012, 1, 31),
  :offline_filing_deadline => Date.new(2011, 10, 31),
  :payment_deadline => Date.new(2012, 1, 31),
  :penalty1date => Date.new(2012, 3, 2),
  :penalty2date => Date.new(2012, 8, 2),
  :penalty3date => Date.new(2013, 2, 2)
}

multiple_choice :how_submitted? do
  option :online => :when_submitted?
  option :paper => :when_submitted?

  save_input_as :submission_method
end

date_question :when_submitted? do
  save_input_as :filing_date

  next_node :when_paid?
end

date_question :when_paid? do
  save_input_as :payment_date

  next_node do |response|
    calculator = Calculators::SelfAssessmentPenalties.new(
      :submission_method => submission_method,
      :filing_date => filing_date,
      :payment_date => response,
      :dates => CALCULATOR_DATES
    )
    if calculator.paid_on_time?
      :filed_and_paid_on_time
    else
      :how_much_tax?
    end
  end
end

money_question :how_much_tax? do
  save_input_as :estimated_bill

  calculate :calculator do
    Calculators::SelfAssessmentPenalties.new(
      :submission_method => submission_method,
      :filing_date => filing_date,
      :payment_date => payment_date,
      :estimated_bill => responses.last,
      :dates => CALCULATOR_DATES
    )
  end

  calculate :late_filing_penalty do
    money_format(calculator.late_filing_penalty)
  end

  calculate :total_owed do
    money_format(calculator.total_owed)
  end

  calculate :interest do
    money_format(calculator.interest)
  end

  calculate :late_payment_penalty do
    money_format(calculator.late_payment_penalty)
  end

  next_node :late
end


outcome :late
outcome :filed_and_paid_on_time