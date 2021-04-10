class Friend < ApplicationRecord
  belongs_to :user

  before_save :set_status, if: :new_record?

  private
  def set_status
    self.status = "pending" # possible values pending, suspend, validate
  end
end
