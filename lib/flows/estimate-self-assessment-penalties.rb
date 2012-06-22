status :draft

satisfies_need "B692"

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
      :payment_date => response
    )
    if calculator.paid_on_time?
      :result2
    else
      :how_much_tax?
    end
  end
end

money_question :how_much_tax? do
  save_input_as :estimated_bill

  next_node :result1
end


outcome :result1
outcome :result2