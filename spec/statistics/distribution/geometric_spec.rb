require 'spec_helper'

describe Statistics::Distribution::Geometric do
  describe '#initialize' do
    it 'creates a distribution that does not allow probabilities of 100 % chance by default' do
      expect(described_class.new(rand).always_success_allowed).to be false
    end

    it 'creates a distribution that allows 100 % probabilities when specified' do
      expect(described_class.new(rand, always_success: true).always_success_allowed).to be true
    end
  end

  context 'when a probability of 100 % chance is allowed' do
    let(:p) { rand }
    let(:geometric) { described_class.new(p, always_success: true) }

    describe '#mean' do
      it 'returns the expected value for the geometric distribution' do
        expect(geometric.mean).to eq (1.0 - p) / p
      end
    end

    describe '#median' do
      it 'returns the expected value for the geometric distribution' do
        expect(geometric.median).to eq (-1.0 / Math.log2(1.0 - p)).ceil - 1.0
      end
    end

    describe '#mode' do
      it 'returns the expected value for the geometric distribution' do
        expect(geometric.mode).to be_zero
      end
    end

    describe '#cumulative_function' do
      it 'is not defined if the number of trials is negative' do
        expect(geometric.cumulative_function(rand(-10...0))).to be_nil
      end

      it 'is defined if the number of trials is zero' do
        expect(geometric.cumulative_function(0)).not_to be_nil
      end

      it 'returns the expected values for the geometric distribution' do
        # Results from R:
        # pgeom(c(1,2,3,4,5), 0.5)
        # [1] 0.750000 0.875000 0.937500 0.968750 0.984375

        geometric.probability_of_success = 0.5
        results = [0.750000, 0.875000, 0.937500, 0.968750, 0.984375]

        1.upto(5) do |trial|
          expect(geometric.cumulative_function(trial)).to eq results[trial - 1]
        end
      end
    end

    describe '#density_function' do
      it 'is not defined if the number of trials is negative' do
        expect(geometric.density_function(rand(-10...0))).to be_nil
      end

      it 'is defined if the number of trials is zero' do
        expect(geometric.density_function(0)).not_to be_nil
      end

      it 'returns the expected values for the geometric distribution' do
        # Results from R:
        # dgeom(c(1,2,3,4,5), 0.5)
        # [1] 0.250000 0.125000 0.062500 0.031250 0.015625

        geometric.probability_of_success = 0.5
        results = [0.250000, 0.125000, 0.062500, 0.031250, 0.015625]

        1.upto(5) do |trial|
          expect(geometric.density_function(trial)).to eq results[trial - 1]
        end
      end
    end
  end

  context 'when a probability of 100 % chance is not allowed' do
    let(:p) { rand }
    let(:geometric) { described_class.new(p, always_success: false) }

    describe '#mean' do
      it 'returns the expected value for the geometric distribution' do
        expect(geometric.mean).to eq 1.0 / p
      end
    end

    describe '#median' do
      it 'returns the expected value for the geometric distribution' do
        expect(geometric.median).to eq (-1.0 / Math.log2(1.0 - p)).ceil
      end
    end

    describe '#mode' do
      it 'returns the expected value for the geometric distribution' do
        expect(geometric.mode).to eq 1.0
      end
    end

    describe '#cumulative_function' do
      it 'is not defined if the number of trials is negative' do
        expect(geometric.cumulative_function(rand(-10...0))).to be_nil
      end

      it 'is not defined if the number of trials is zero' do
        expect(geometric.cumulative_function(0)).to be_nil
      end

      it 'returns the expected values for the geometric distribution' do
        ## We don't have a way to compare against R results because
        # the geometric distribution in R is calculated with p <= 1

        k = rand(1..10)

        expect(geometric.cumulative_function(k)).to eq (1.0 - ((1.0 - p) ** k))
      end
    end

    describe '#density_function' do
      it 'is not defined if the number of trials is negative' do
        expect(geometric.density_function(rand(-10...0))).to be_nil
      end

      it 'is not defined if the number of trials is zero' do
        expect(geometric.density_function(0)).to be_nil
      end

      it 'returns the expected values for the geometric distribution' do
        ## We don't have a way to compare against R results because
        # the geometric distribution in R is calculated with p <= 1

        k = rand(1..10)

        expect(geometric.density_function(k)).to eq ((1.0 - p) ** (k - 1.0)) * p
      end
    end
  end

  describe '#variance' do
    it 'returns the expected value for the geometric distribution' do
      p = rand
      geometric = described_class.new(p)

      expect(geometric.variance).to eq (1.0 - p) / (p ** 2)
    end
  end

  describe '#skewness' do
    it 'returns the expected value for the geometric distribution' do
      p = rand
      geometric = described_class.new(p)

      expect(geometric.skewness).to eq (2.0 - p) / Math.sqrt(1.0 - p)
    end
  end

  describe '#kurtosis' do
    it 'returns the expected value for the geometric distribution' do
      p = rand
      geometric = described_class.new(p)

      expect(geometric.kurtosis).to eq (6.0 + ((p ** 2) / (1.0 - p)))
    end
  end
end
