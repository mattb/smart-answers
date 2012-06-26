require "ostruct"

module SmartAnswer::Calculators
  class SelfAssessmentPenalties < OpenStruct
    def filing_date
      parse_date(super)
    end

    def payment_date
      parse_date(super)
    end

    def paid_on_time?
      filing_date < filing_deadline && payment_date < payment_deadline
    end

    def overdue_filing_days
      (filing_date - filing_deadline).to_i
    end

    def overdue_payment_days
      (payment_date - payment_deadline).to_i
    end

    def late_filing_penalty
      if overdue_filing_days <= 0
        0
      elsif overdue_filing_days <= 90
        100
      elsif overdue_filing_days <= 179
        (overdue_filing_days - 90) * 10 + 100
      elsif overdue_filing_days <= 364
        1000 + [300, estimated_bill * 0.05].max
      else
        1000 + [600, estimated_bill * 0.05].max
      end
    end

    def interest
      if overdue_payment_days <= 0
        0
      else
        penalty_interest = penalty_interest1 + penalty_interest2 + penalty_interest3
        (calculate_interest(estimated_bill, overdue_payment_days) + penalty_interest).round(2)
      end
    end

    def late_payment_penalty
      if overdue_payment_days <= 30
        0
      elsif overdue_payment_days <= 179
        late_payment_penalty1.round(2)
      elsif overdue_payment_days <= 364
        (late_payment_penalty1 + late_payment_penalty2).round(2)
      else
        (late_payment_penalty1 + late_payment_penalty2 + late_payment_penalty3).round(2)
      end
    end

    def filing_deadline
      submission_method == "online" ? Date.new(2012, 1, 31) : Date.new(2011, 10, 31)
    end

    def payment_deadline
      Date.new(2012, 1, 31)
    end

    def penalty1date
      Date.new(2012, 3, 2)
    end

    def penalty_interest1
      if payment_date > (penalty1date + 30)
        calculate_interest(late_payment_penalty1, payment_date - (penalty1date + 30))
      else
        0
      end
    end

    def late_payment_penalty1
      0.05 * estimated_bill
    end

    def penalty2date
      Date.new(2012, 8, 2)
    end

    def penalty_interest2
      if payment_date > (penalty2date + 30)
        calculate_interest(late_payment_penalty2, payment_date - (penalty2date + 30))
      else
        0
      end
    end

    def late_payment_penalty2
      0.05 * estimated_bill
    end

    def penalty3date
      Date.new(2013, 2, 2)
    end

    def penalty_interest3
      if payment_date > (penalty3date + 30)
        calculate_interest(late_payment_penalty3, payment_date - (penalty2date + 30))
      else
        0
      end
    end

    def late_payment_penalty3
      0.05 * estimated_bill
    end

    def parse_date(value)
      Date.parse(value)
    end

    def calculate_interest(amount, number_of_days)
      amount * (0.03 / 365) * number_of_days
    end
  end
end