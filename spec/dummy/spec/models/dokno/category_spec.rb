describe Dokno::Category do
  context 'validation' do
    it 'requires a name' do
      category = Dokno::Category.new

      expect(category.validate).to be false
      expect(category.errors[:name]).to include 'can\'t be blank'
      expect(Dokno::Category.new(name: 'dummy').valid?).to be true
    end

    it 'must have a unique name' do
      categories = [Dokno::Category.create(name: 'dummy'), Dokno::Category.create(name: 'dummy 2')]
      categories.first.name = categories.last.name

      expect(categories.first.validate).to be false
      expect(categories.first.errors[:name]).to include 'has already been taken'

      categories.first.name = 'dummy 3'
      expect(categories.first.validate).to be true
    end

    it 'can not have its parent set to self' do
      categories = [Dokno::Category.create(name: 'dummy'), Dokno::Category.create(name: 'dummy 2')]
      categories.first.category_id = categories.first.id

      expect(categories.first.validate).to be false
      expect(categories.first.errors[:category_id]).to include 'can\'t set parent category to self'

      categories.first.category_id = categories.last.id
      expect(categories.first.validate).to be true
    end
  end
end