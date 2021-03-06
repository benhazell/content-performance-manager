RSpec.describe Question do
  it "is abstract" do
    expect { Question.new }.to raise_error(/abstract class/i)
  end

  describe "validations" do
    subject { FactoryGirl.build(:boolean_question) }

    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires text" do
      subject.text = " "
      expect(subject).to be_invalid
    end
  end
end
