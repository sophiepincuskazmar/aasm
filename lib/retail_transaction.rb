require "aasm"

class RetailTransaction
  include AASM

  def initialize
    @items = []
  end

  attr_reader :payment_info, :payment_token

  def items
    @items.dup  # prevent caller from modifying our items
  end

  def add_item(item)
    unless ringing_up?
      raise "Cannot add items while transaction state is #{aasm.current_state}"
    end
    @items << item
  end

  def payment_info=(payment_info)
    unless collecting_payment? || payment_declined?
      raise "Cannot change payment info while transaction state is #{aasm.current_state}"
    end
    @payment_info = payment_info
  end

  def empty?
    @items.empty?
  end

  def paid?
    !payment_token.nil?
  end

  aasm do
    state :ringing_up, initial: true
    state :collecting_payment
    state :processing_payment
    state :payment_declined
    state :settled

    event :check_out do
      transitions from: :ringing_up, to: :collecting_payment,
        unless: :empty?
    end

    event :reopen do
      transitions from: [:collecting_payment, :payment_declined], to: :ringing_up
    end

    event :process_payment do
      transitions from: [:collecting_payment, :payment_declined], to: :processing_payment,
        if: lambda { !payment_info.nil? }
    end

    event :payment_authorized do
      transitions from: :processing_payment, to: :settled
    end

    event :payment_declined do
      transitions from: :processing_payment, to: :payment_declined
    end
  end
end
