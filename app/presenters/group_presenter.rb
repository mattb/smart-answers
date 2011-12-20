class GroupPresenter < QuestionPresenter
  def response_label(value)
    value
  end              
  
  def nodes                        
    @node.questions.map do |n|
      presenter = case n
      when SmartAnswer::Question::Date
        DateQuestionPresenter
      when SmartAnswer::Question::MultipleChoice
        MultipleChoiceQuestionPresenter
      when SmartAnswer::Question::Value
        ValueQuestionPresenter
      when SmartAnswer::Question::Money
        MoneyQuestionPresenter
      when SmartAnswer::Question::Salary
        SalaryQuestionPresenter
      when SmartAnswer::Question::Base
        QuestionPresenter       
      end
      presenter.new(@i18n_prefix, n)
    end
  end
end
