status :draft

country_select :which_country_do_you_live_in? do
  save_input_as :country
  next_node :what_date_did_you_move_there?
end

date_question :what_date_did_you_move_there? do
  from Date.parse('1900-01-01')
  to Date.today

  save_input_as :date_moved
  calculate :years_there do
    ((Date.today - Date.parse(date_moved))/365.25).to_i
  end

  next_node :ok
end

outcome :ok
