require "test_helper"
require "retail_transaction" 

# Note: assert_invalid_transition is defined in test_helper.rb

describe RetailTransaction do

  let(:tx) { RetailTransaction.new }

  it "starts in the “ringing up” state" do
    assert_equal true,  tx.ringing_up?
    assert_equal false, tx.collecting_payment?
    assert_equal false, tx.processing_payment?
    assert_equal false, tx.settled?
    assert_equal false, tx.payment_declined?
  end

  it "starts out empty" do
    assert_equal true, tx.empty?
  end

  it "cannot check out if no items" do
    assert_invalid_transition { tx.check_out! }
  end

  describe "still ringing up, with items" do
    before(:each) { tx.add_item("broccoli") }

    it "can add more items" do
      tx.add_item("roller skates")
    end

    it "can check out" do
      tx.check_out!
      assert_equal false, tx.ringing_up?
      assert_equal true,  tx.collecting_payment?
    end

    it "cannot set payment info" do
      assert_raises do
        tx.payment_info = "15 cents and a nail"
      end
    end
  end

  describe "collecting payment" do
    before(:each) do
      tx.add_item("bobcat")
      tx.check_out!
    end

    it "cannot add more items" do
      assert_raises do
        tx.add_item("roller skates")
      end
    end

    it "cannot process payment without payment info" do
      assert_invalid_transition { tx.process_payment! }
    end

    it "can process payment with payment info" do
      tx.payment_info = "15 cents and a nail"
      tx.process_payment!
      assert_equal false, tx.collecting_payment?
      assert_equal true,  tx.processing_payment?
    end
  end

  describe "processing payment" do
    before(:each) do
      tx.add_item("bobcat")
      tx.check_out!
      tx.payment_info = "15 cents and a nail"
      tx.process_payment!
    end

    it "cannot add more items" do
      assert_raises do
        tx.add_item("roller skates")
      end
    end

    it "cannot change payment info" do
      assert_raises do
        tx.payment_info = "12 dollars and a hot dog"
      end
    end

    it "cannot re-process payment" do
      assert_invalid_transition { tx.process_payment! }
    end

    it "can handle payment accepted" do
      tx.payment_authorized!
      assert_equal false, tx.processing_payment?
      assert_equal true,  tx.settled?
      assert_equal false, tx.payment_declined?
    end

    it "can handle payment declined" do
      tx.payment_declined!
      assert_equal false, tx.processing_payment?
      assert_equal false, tx.settled?
      assert_equal true,  tx.payment_declined?
    end
  end

  describe "with declined payment" do
    before(:each) do
      tx.add_item("bobcat")
      tx.check_out!
      tx.payment_info = "15 cents and a nail"
      tx.process_payment!
      tx.payment_declined!
    end

    it "cannot add more items" do
      assert_raises do
        tx.add_item("half a slice of bologna")
      end
    end

    it "can reopen and add more items" do
      tx.reopen!
      assert_equal true, tx.ringing_up?
      tx.add_item("half a slice of bologna")
    end

    it "can retry payment" do
      tx.process_payment!
      assert_equal false, tx.payment_declined?
      assert_equal true,  tx.processing_payment?
    end

    it "can change payment info" do
      tx.payment_info = "15 cents and a nail and the shell of a great great great grandfather snail"
      tx.process_payment!
      assert_equal false, tx.payment_declined?
      assert_equal true,  tx.processing_payment?
    end
  end

  describe "that is settled" do
    before(:each) do
      tx.add_item("bobcat")
      tx.check_out!
      tx.payment_info = "15 cents and a nail"
      tx.process_payment!
      tx.payment_authorized!
    end

    it "cannot be reopened" do
      assert_invalid_transition { tx.reopen! }
    end
  end
end
