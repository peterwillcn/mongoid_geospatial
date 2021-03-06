class Person
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Timestamps
  include Mongoid::Versioning

  attr_accessor :mode

  class_attribute :somebody_elses_important_class_options
  self.somebody_elses_important_class_options = { :keep_me_around => true }

  field :title
  field :terms, :type => Boolean
  field :pets, :type => Boolean, :default => false
  field :age, :type => Integer, :default => 100
  field :dob, :type => Date
  field :employer_id
  field :lunch_time, :type => Time
  field :aliases, :type => Array
  field :map, :type => Hash
  field :score, :type => Integer
  field :blood_alcohol_content, :type => Float, :default => lambda{ 0.0 }
  field :last_drink_taken_at, :type => Date, :default => lambda { 1.day.ago.in_time_zone("Alaska") }
  field :ssn
  field :owner_id, :type => Integer
  field :security_code
  field :reading, :type => Object
  field :bson_id, :type => bson_object_id_class

  if Mongoid::VERSION > '3'
    index age: 1
    index addresses: 1
    index dob: 1
    index name: 1
    index title: 1
    index({ssn: 1}, :unique => true)
    
  else
    index :age
    index :addresses
    index :dob
    index :name
    index :title
    index :ssn, :unique => true
  end

  validates_format_of :ssn, :without => /\$\$\$/

  attr_reader :rescored

  attr_protected :security_code, :owner_id

  embeds_many :favorites, :order => :title.desc, :inverse_of => :perp
  embeds_many :videos, :order => [[ :title, :asc ]]
  embeds_many :phone_numbers, :class_name => "Phone"
  embeds_many :addresses, :as => :addressable do
    def extension
      "Testing"
    end
    def find_by_street(street)
      @target.select { |doc| doc.street == street }
    end
  end
  embeds_many :address_components
  embeds_many :services

  embeds_one :pet, :class_name => "Animal"
  embeds_one :name, :as => :namable do
    def extension
      "Testing"
    end
    def dawkins?
      first_name == "Richard" && last_name == "Dawkins"
    end
  end
  embeds_one :quiz

  has_one :game, :dependent => :destroy do
    def extension
      "Testing"
    end
  end

  has_many \
    :posts,
    :dependent => :delete,
    :order => :rating.desc do
    def extension
      "Testing"
    end
  end
  has_many :paranoid_posts
  has_and_belongs_to_many \
    :preferences,
    :index => true,
    :dependent => :nullify,
    :autosave => true,
    :order => :value.desc
  has_and_belongs_to_many :user_accounts
  has_and_belongs_to_many :houses

  has_many :drugs, :autosave => true
  has_one :account, :autosave => true

  has_and_belongs_to_many \
    :administrated_events,
    :class_name => 'Event',
    :inverse_of => :administrators,
    :dependent  => :nullify
    
  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :name, :update_only => true
  accepts_nested_attributes_for :pet, :allow_destroy => true
  accepts_nested_attributes_for :game, :allow_destroy => true
  accepts_nested_attributes_for :favorites, :allow_destroy => true, :limit => 5
  accepts_nested_attributes_for :posts
  accepts_nested_attributes_for :preferences
  accepts_nested_attributes_for :quiz
    

  scope :minor, where(:age.lt => 18)
  scope :without_ssn, without(:ssn)

  def score_with_rescoring=(score)
    @rescored = score.to_i + 20
    self.score_without_rescoring = score
  end

  alias_method_chain :score=, :rescoring

  def update_addresses
    addresses.each do |address|
      address.street = "Updated Address"
    end
  end

  def employer=(emp)
    self.employer_id = emp.id
  end

  class << self
    def accepted
      criteria.where(:terms => true)
    end
    def knight
      criteria.where(:title => "Sir")
    end
    def old
      criteria.where(:age => { "$gt" => 50 })
    end
  end

end

class Doctor < Person
  field :specialty
end
