module Seeder::Models
  class Assignment
    TYPES_OF_ASSIGNMENTS = %i(online_text_entry online_upload discussion_topic)
    attr_accessor :id, :discussion_topic_id, :name, :description, :grading_type, :submission_type, :points_possible, :submissions

    def initialize(submission_type, points_possible)
      self.submission_type = submission_type
      self.points_possible = points_possible
      self.grading_type = %w(pass_fail percent letter_grade points).sample
      self.submissions = []
    end

    def populate
      self.name = self.description = Forgery::Education.sentence_from_literature[0, 255]
    end

    def time_rand
     Time.at(Time.now.to_f + rand * (15.day.from_now.to_f - Time.now.to_f ))
    end

    def save!(client, course_id)
      resp = client.create_assignment(course_id, { assignment: { name: name, submission_types: [submission_type], points_possible: points_possible,
        grading_type: grading_type, description: description, published: true, due_at: Time.at(Time.now.to_f + rand * (15.day.from_now.to_f - Time.now.to_f )).iso8601.to_s} })
      self.id = resp['id']
      self.discussion_topic_id = resp['discussion_topic'].try(:[], 'id') if submission_type.to_sym == :discussion_topic
      Rails.logger.info("Created assignment #{name} in course #{course_id}")
    end
  end
end
