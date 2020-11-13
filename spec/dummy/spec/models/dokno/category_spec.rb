describe Dokno::Category do
  context 'validation' do
    it 'requires a name' do
      category = Dokno::Category.new

      expect(category.validate).to be false
      expect(category.errors[:name]).to include 'can\'t be blank'
      expect(Dokno::Category.new(name: 'dummy').valid?).to be true
    end
  end
end