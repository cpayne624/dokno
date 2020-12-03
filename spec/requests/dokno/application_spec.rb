# Specs shared across controllers
module Dokno
  describe ApplicationController, type: :controller do
    describe '#user' do
      context 'proper host app user configuration' do
        it 'returns the evaluated user object from the host app' do
          expect(subject.user).to be_kind_of User
          expect(subject.user).to respond_to Dokno.config.app_user_name_method.to_sym
          expect(subject.user).to respond_to Dokno.config.app_user_auth_method.to_sym
        end
      end

      context 'improper host app user configuration' do
        it 'returns nil' do
          allow(Dokno.config).to receive(:app_user_object).and_return('bogus')
          expect(subject.user).to be_nil
        end
      end
    end

    describe '#username' do
      context 'proper host app user configuration' do
        it 'returns the identifying string for the authenticated user in the host app' do
          app_user_name_method = :name
          expected_user_name   = 'Dummy User'

          allow(Dokno.config).to receive(:app_user_name_method).and_return(app_user_name_method)
          allow(subject.user).to receive(Dokno.config.app_user_name_method.to_sym).and_return(expected_user_name)

          expect(subject.username).to eq expected_user_name
        end
      end

      context 'improper host app user configuration' do
        it 'returns an empty string' do
          allow(Dokno.config).to receive(:app_user_object).and_return('bogus')
          expect(subject.username).to eq ''
        end
      end
    end

    describe '#can_edit?' do
      context 'proper host app user configuration' do
        it 'indicates whether the authenticated host app user has edit permissions' do
          app_user_auth_method = :admin?

          allow(Dokno.config).to receive(:app_user_auth_method).and_return(app_user_auth_method)
          allow(subject.user).to receive(Dokno.config.app_user_auth_method.to_sym).and_return(true)
          expect(subject.can_edit?).to be true

          allow(subject.user).to receive(Dokno.config.app_user_auth_method.to_sym).and_return(false)
          expect(subject.can_edit?).to be false
        end
      end

      context 'improper host app user configuration' do
        it 'indicates that the authenticated host app user has edit permissions by default' do
          allow(Dokno.config).to receive(:app_user_object).and_return('bogus')
          expect(subject.can_edit?).to be true
        end
      end
    end
  end
end
