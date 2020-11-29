# Mocked User model for authorization testing
class User
  def name
    'Dummy User'
  end

  def admin?
    true
  end
end
