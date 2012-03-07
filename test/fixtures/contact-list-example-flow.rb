country_select :question_example do
  calculate :list_questions do
    [{
      'address' => "IT Department, Reynholm Industries, London",
      'phone' => "0118 999 881 999 119 7253"
    },{
      'address' => "742 Evergreen Terrace, Springfield",
      'phone' => "(939) 123-4567"
    }]
  end

  next_node :done
end

outcome :done do
  contact_list :list_questions
end