require 'spec_helper'
require 'fileutils'

describe Session do
  describe "saving" do 
    it "is possible" do
      session = FactoryGirl.create :session_with_presenter
      Session.first.should == session
    end
  end

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:first_presenter) }
  ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
    it { should_not allow_value(illegal_mail).for(:first_presenter_email) }
    it { should_not allow_value(illegal_mail).for(:second_presenter_email) }
  end

  shared_examples_for "a_lazy_presenter_creator" do
    it "is empty initially" do
      email_value.should be_empty
    end
    context "when presenter is not set" do

      context "and presenter does not exist" do
        before { set_email_value_to "some_new_presenter@example.com" }
        it "sets the email value" do
          email_value.should == "some_new_presenter@example.com" 
        end
        it "creates the presenter" do
          expect {session.save!}.to change(Presenter, :count).by(1)
        end
      end
      context "and presenter does not exist but presenter is archived" do
        it "creates the presenter from the archive" do
          archived_presenter = FactoryGirl.create :archived_presenter, :bio => "the bio"
          set_email_value_to archived_presenter.email
          session.save
          presenter = Presenter.includes(:account).where('accounts.email = ?', archived_presenter.email).first 
          presenter.should_not be_nil
          presenter.name.should == archived_presenter.name
          presenter.bio.should == archived_presenter.bio
        end
      end

      context "and presenter exists" do
        let!(:presenter) { FactoryGirl.create :presenter }
        before { set_email_value_to presenter.email }

        it "sets the email value" do
          email_value.should == presenter.email
        end

        it "does not create a presenter" do
          expect {session.save!}.not_to change(Presenter, :count)
        end

        context "and presenter exists with other casing" do
          before { set_email_value_to presenter.email.upcase }

          it "does not create a presenter" do
            expect { session.save!}.not_to change(Presenter, :count)
          end

          it "takse the original email value" do
            email_value.should == presenter.email
          end
        end

      end

      context "and value is empty" do
        it "does not create a presenter" do
          expect {set_email_value_to ''}.not_to change{ session.presenters.length }
        end
      end

      context "and value is nil" do
        it "does not create a presenter" do
          expect {set_email_value_to nil}.not_to change{ session.presenters.length }
        end
      end
    end
  end

  describe "first presenter_email" do
    let(:session) { FactoryGirl.build :session  }

    def session_presenter 
      session.presenters.first
    end
    def set_email_value_to(email)
      session.first_presenter_email = email
    end
    def email_value
      session.first_presenter_email
    end
    it_should_behave_like "a_lazy_presenter_creator"

    context "when presenter is set" do
      before { set_email_value_to "some_new_presenter@example.com" }
      it "is not allowed to set first presenter to nil" do
        set_email_value_to nil
        email_value.should == "some_new_presenter@example.com" 
      end
      it "is not allowed to set first presenter to empty" do
        set_email_value_to ""
        email_value.should == "some_new_presenter@example.com" 
      end
    end
  end

  describe "second presenter_email" do
    let(:session) { FactoryGirl.create :session_with_presenter }

    def session_presenter 
      session.second_presenter
    end
    def set_email_value_to(email)
      session.second_presenter_email = email
    end
    def email_value
      session.second_presenter_email
    end
    it_should_behave_like "a_lazy_presenter_creator"

    context "when presenter is set" do
      before { set_email_value_to "some_new_presenter@example.com" }
      it "is allowed to set second presenter to nil" do
        set_email_value_to nil
        email_value.should == ""
      end
      it "is allowed to set second presenter to empty" do
        set_email_value_to ""
        email_value.should == ""
      end
    end
  end

  describe "presenter_names" do
    let!(:session) { Session.new } 
    it "empty session returns emtpy names" do
      session.presenter_names.should be_empty
    end
    context "first presenter email set" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => '')}
      it "returns email" do
        session.first_presenter.email.should == "presenter_1@example.com"
        session.presenter_names.should == "presenter_1@example.com"
      end
    end
    context "first and second presenter email set" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => 'presenter_2@example.com')}
      it "returns 2 emails" do
        session.presenter_names.should == "presenter_1@example.com & presenter_2@example.com"
      end
    end
    # how can I add names to my presenters?
    context "first presenter email and name set, no second presenter" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => '')}
      it "returns name" do
        session.first_presenter.name = "Petra The Firstpresenter"
        session.presenter_names.should == "Petra The Firstpresenter"
      end
    end
    context "first presenter email and name set, second presenter only email" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => 'presenter_2@example.com')}
      it "returns name and email" do
        session.first_presenter.name = "Petra The Firstpresenter"
        session.presenter_names.should == "Petra The Firstpresenter & presenter_2@example.com"
      end
    end
    context "both presenters name set" do
      let!(:session) { FactoryGirl.build(:session, :first_presenter_email => "presenter_1@example.com", :second_presenter_email => 'presenter_2@example.com')}
      it "returns 2 names" do
        session.first_presenter.name = "Petra The Firstpresenter"
        session.second_presenter.name = "Peter The Secondpresenter"
        session.presenter_names.should == "Petra The Firstpresenter & Peter The Secondpresenter"
      end
    end
  end

  describe "presenter_has_voted_for?", :broken => true do
  end

  describe "self topic_name" do
    context "nil topic" do 
      it "returns blank" do 
        Session.topic_name(nil).should == "" 
      end 
    end
    context "emtpy topic" do 
      it "returns blank" do 
        Session.topic_name("").should == "" 
      end 
    end
    context "existent topic" do 
      it "returns name from hash" do 
        Session.topic_name("technology").should == "Technology and Technique" 
      end 
    end
  end

  describe "generate_pdf" do
    let(:session) { FactoryGirl.build(:session_with_presenter, 
                                      :sub_title => "the sub title", 
                                      :short_description => "the short description", 
                                      :session_type => "the session type") }
    it "returns a pdf file" do
      FileUtils.mkdir_p 'tmp'
      pdf = session.generate_pdf("tmp/session_test.pdf")
      pdf.should_not be_nil
      pdf.class.should equal File
    end
  end

  describe "generate_program_board_card_pdf" do
    let(:session) { FactoryGirl.build(:session_with_presenter, 
                                      :sub_title => "the sub title", 
                                      :short_description => "the short description", 
                                      :session_type => "the session type") }
    it "returns a pdf file" do
      FileUtils.mkdir_p 'tmp'
      pdf = session.generate_program_board_card_pdf("tmp/session_test.pdf")
      pdf.should_not be_nil
      pdf.class.should equal File
    end
  end


  describe "generate_program_committee_cards_pdf" do
    let(:session) { FactoryGirl.build(:session_with_presenter, 
                                      :sub_title => "the sub title", 
                                      :short_description => "the short description", 
                                      :session_type => "the session type") }
    it "returns a pdf file" do
      FileUtils.mkdir_p 'tmp'
      pdf = Session.generate_program_committee_cards_pdf("tmp/session_test.pdf")
      pdf.should_not be_nil
      pdf.class.should equal File
    end
  end

  describe "printable_max_participants" do
    let(:session) { FactoryGirl.build(:session_with_presenter) }
    it "if empty max_participants returns nothing" do 
      session.printable_max_participants.should == ""
    end
    it "if max_participants is unlimited returns nothing" do 
      session.max_participants = "unlimited"
      session.printable_max_participants.should == ""
    end
    it "if max_participants is a number returns that number" do 
      session.max_participants = "30"
      session.printable_max_participants.should == "Max: 30"
    end
    it "if max_participants is a number and some extra blabla returns only the number" do 
      session.max_participants = "30 (6 groups of 5)"
      session.printable_max_participants.should == "Max: 30"
    end
  end

  describe "printable_laptops_required" do
    let(:session) { FactoryGirl.build(:session_with_presenter) }
    it "if nil laptops_required returns nothing" do 
      session.printable_laptops_required.should == ""
    end
    it "if empty laptops_required returns nothing" do 
      session.laptops_required = ""
      session.printable_laptops_required.should == ""
    end
    it "if laptops_required is no returns nothing" do 
      session.laptops_required = "no"
      session.printable_laptops_required.should == ""
    end
    it "if laptops_required is yes returns non-empty string" do 
      session.laptops_required = "yes"
      session.printable_laptops_required.should == "bring laptop"
    end
  end

  describe "duration" do
    let(:session) { FactoryGirl.build(:session_with_presenter) }
    it "if nil duration is valid" do 
      session.duration.should == nil
      session.should be_valid
    end
    it "if empty duration is valid" do 
      session.duration == ""
      session.duration.should == nil
      session.should be_valid
    end
    it "if correct duration is valid" do 
      session.duration = "180 min"
      session.should be_valid
    end
    it "if incorrect duration is invalid" do 
      session.duration = "1 min"
      session.should be_invalid
    end
  end

  describe "max_participants" do
    let(:session) { FactoryGirl.build(:session_with_presenter) }
    it "if nil max_participants is valid" do 
      session.max_participants.should == nil
      session.should be_valid
    end
    it "if empty max_participants is valid" do 
      session.max_participants == ""
      session.max_participants.should == nil
      session.should be_valid
    end
    it "if correct max_participants is valid" do 
      session.max_participants = "120"
      session.should be_valid
    end
    it "if incorrect max_participants is invalid" do 
      session.max_participants = "bla"
      session.should be_invalid
    end
  end

  describe "session_type" do
    let(:session) { FactoryGirl.build(:session_with_presenter) }
    it "if nil session_type is valid" do 
      session.session_type.should == nil
      session.should be_valid
    end
    it "if empty session_type is valid" do 
      session.session_type == ""
      session.session_type.should == nil
      session.should be_valid
    end
    it "if correct session_type is valid" do 
      session.session_type = Session::AVAILABLE_SESSION_TYPE[0]
      session.should be_valid
    end
    it "if incorrect session_type is invalid" do 
      session.session_type = "bla"
      session.should be_invalid
    end
  end

  describe "status" do
    def a_session(created_at, updated_at)
      session = FactoryGirl.create(:session_with_presenter, :created_at => created_at, :updated_at => updated_at) 
    end
    def a_review_for(session, date)
      FactoryGirl.create(:review , :session => session, :created_at => date, :updated_at => date) 
    end
    def a_comment_for(review, date)
      FactoryGirl.create(:comment, :review => review, :created_at => date, :updated_at => date)
    end
    def check_statuses(session, check_since, expected_update_status, expected_review_status, expected_comment_status, expected_status)
      session.update_status(check_since).should == expected_update_status
      session.review_status(check_since).should == expected_review_status
      session.comment_status(check_since).should == expected_comment_status
      session.status(check_since).should == expected_status
    end
    it "session older than given date" do 
      session = a_session("23-06-2013", "23-06-2013")
      check_statuses(session, "26-06-2013", "", "", "", "")
    end
    it "session with update older than given date" do 
      session = a_session("23-06-2013", "26-06-2013")
      check_statuses(session, "26-06-2013", "", "", "", "")
    end
    it "session newer than given date" do 
      session = a_session("23-06-2013", "26-06-2013")
      check_statuses(session, "22-06-2013", "NEW", "", "", "NEW")
    end
    it "session updated since given date" do 
      session = a_session("23-06-2013", "26-06-2013")
      check_statuses(session, "24-06-2013", "UPDATED", "", "", "UPDATED")
    end
    it "session older than given date with older review" do 
      session = a_session("23-06-2013", "23-06-2013")
      a_review_for(session, "24-6-2013")
      check_statuses(session, "26-06-2013", "", "", "", "")
    end
    it "session older than given date with newer review" do 
      session = a_session("23-06-2013", "23-06-2013")
      a_review_for(session, "27-6-2013")
      check_statuses(session, "26-06-2013", "", "REVIEWED", "", "REVIEWED")
    end
    it "session newer than given date with newer review" do 
      session = a_session("23-06-2013", "26-06-2013")
      a_review_for(session, "27-6-2013")
      check_statuses(session, "22-06-2013", "NEW", "REVIEWED", "", "NEW REVIEWED")
    end
    it "session updated since given date with newer review" do 
      session = a_session("23-06-2013", "26-06-2013")
      a_review_for(session, "27-6-2013")
      check_statuses(session, "24-06-2013", "UPDATED", "REVIEWED", "", "UPDATED REVIEWED")
    end
    it "session older than given date with older review and older comment" do 
      session = a_session("23-06-2013", "23-06-2013")
      review = a_review_for(session, "24-6-2013")
      a_comment_for(review, "25-6-2013")
      check_statuses(session, "26-06-2013", "", "", "", "")
    end
    it "session older than given date with older review and newer comment" do
      session = a_session("23-06-2013", "23-06-2013")
      review = a_review_for(session, "25-6-2013")
      c = a_comment_for(review, "28-6-2013")
      check_statuses(session, "26-06-2013", "", "", "COMMENTED", "COMMENTED")
    end
  end

  describe "self.sessions_that_need_a_review" do
    def a_session(created_at)
      session = FactoryGirl.create(:session_with_presenter, :created_at => created_at, :updated_at => created_at) 
    end
    def a_review_for(session)
      FactoryGirl.create(:review , :session => session)
    end
    it "returns nothing if no sessions" do
      Session.sessions_that_need_a_review.should be_empty
    end
    it "if we have an old session with a review returns nothing " do
      a_review_for ( a_session(Date.today - 10) )
      Session.sessions_that_need_a_review.should be_empty
    end
    it "if we have an old session without a review returns that session" do
      session = a_session(Date.today - 10)
      Session.sessions_that_need_a_review.should == [session]
    end
    it "if we have a new session with a review returns that session" do
      session = a_session(Date.today - 3) 
      a_review_for ( session )
      Session.sessions_that_need_a_review.should == [session]
    end
    it "returns each session only once " do
      session = a_session(Date.today - 3) 
      Session.sessions_that_need_a_review.should == [session]
    end
  end

end
