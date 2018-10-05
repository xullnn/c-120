class Person
  attr_accessor :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def >(other_person)
    age > other_person.age
  end

  def not_yet_18?
    age < 18
  end
end

class Team
  attr_accessor :name, :members

  def initialize(name)
    @name = name
    @members = []
  end

  def <<(person)
    return if person.not_yet_18?
    members.push person
  end
end

cowboys = Team.new("Dallas cowboys")
emmitt = Person.new("Emmitt Smith", 46)
teem = Person.new("Youngboy", 17)
