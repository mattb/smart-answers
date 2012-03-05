module SmartAnswer
  class Outcome < Node
    def is_outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end

    def places(slug)

    end
  end
end