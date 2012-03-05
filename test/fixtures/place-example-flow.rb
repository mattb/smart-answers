multiple_choice :question_example do
  option :one
  option :two

  next_node :done
end

outcome :done do
  places :'example'
end