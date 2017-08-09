require 'spec_helper'

describe Statistics::Distribution::F do
  describe '#density_function' do
    it 'returns the expected values for the F distribution' do
      d1, d2 = 1, 2
      f_distribution = described_class.new(d1, d2)
      results = [0.19245009, 0.08838835, 0.05163978, 0.03402069, 0.02414726]

      (1..5).each_with_index do |number, index|
        expect(f_distribution.density_function(number).round(8)).to eq results[index]
      end
    end

    it 'uses the defined beta function for the Beta distribution' do
      x, y = 1, 2
      expect(Statistics::Distribution::Beta).to receive(:beta_function)
        .with(x/2.0, y/2.0).and_call_original

      described_class.new(x, y).density_function(rand(1..10))
    end
  end

  describe '#mean' do
    it 'returns the expected mean value for the F distribution' do
      d2 = rand(3..10)
      expected_mean = d2/(d2 - 2).to_f

      f_distribution = described_class.new(1, d2)

      expect(f_distribution.mean).to eq expected_mean
    end

    it 'is not defined for d2 values less or equal than 2' do
      f_distribution = described_class.new(rand(10), rand(-10..2))

      expect(f_distribution.mean).to be_nil
    end
  end

  describe '#mode' do
    it 'returns the expected mode for the F distribution' do
      d1, d2 = rand(3..10), rand(10)
      expected_mode = ((d1 - 2)/d1.to_f) * (d2/(d2 + 2).to_f)

      f_distribution = described_class.new(d1, d2)

      expect(f_distribution.mode).to eq expected_mode
    end

    it 'is not defined for d1 values less or equal than 2' do
      f_distribution = described_class.new(rand(-10..2), rand(10))

      expect(f_distribution.mode).to be_nil
    end
  end
end
