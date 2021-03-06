require 'spec_helper'

RSpec.describe Task, type: :model do
  using RSpec::Parameterized::TableSyntax

  describe `#valid?` do
    let(:user) { create(:user) }

    context 'when typical parameter received' do
      it 'passes' do
        travel_to(Time.zone.local(2018, 11, 12, 13, 14, 15)) do
          expect(
            Task.new(
              name: '靴を買う',
              description: '靴屋に靴を買いに行く',
              deadline: Time.zone.local(2018, 11, 15, 10, 15, 30),
              user: user
            )
          ).to be_valid
        end
      end
    end

    context 'name' do
      where(:name, :be_valid?) do
        '靴' *   0 | be_invalid
        '靴' *   1 | be_valid
        '靴' * 255 | be_valid
        '靴' * 256 | be_invalid
      end

      with_them do
        it { expect(Task.new(name: name, description: '靴屋に靴を買いに行く', user: user)).to be_valid? }
      end
    end

    context 'description' do
      where(:description, :be_valid?) do
        '靴' *    0 | be_valid
        '靴' *    1 | be_valid
        '靴' * 2000 | be_valid
        '靴' * 2001 | be_invalid
      end

      with_them do
        it { expect(Task.new(name: '靴を買う', description: description, user: user)).to be_valid? }
      end
    end

    context 'deadline' do
      where(:deadline, :be_valid?) do
        Time.zone.local(1993,  2, 24, 12, 30, 45) | be_invalid
        Time.zone.local(2018, 11, 12, 13, 14, 15) | be_invalid
        Time.zone.local(2018, 11, 12, 13, 14, 16) | be_valid
        Time.zone.local(2032,  5,  6, 12, 34, 56) | be_valid
      end

      with_them do
        it do
          travel_to(Time.zone.local(2018, 11, 12, 13, 14, 15)) do
            expect(Task.new(name: '靴を買う', deadline: deadline, user: user)).to be_valid?
          end
        end
      end
    end
  end
end
