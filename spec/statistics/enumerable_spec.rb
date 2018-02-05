require 'spec_helper'

describe Enumerable do
  describe '#mean' do
    it 'calculates the mean of an specific collection' do
      expect((1..5).to_a.mean).to eq 3.0
      expect((1..10).to_a.mean).to eq 5.5
      expect((-10..-5).to_a.mean).to eq -7.5
    end
  end

  describe '#variance' do
    it 'calculates the *sample* variance of an specific collection' do
      expect((1..5).to_a.variance).to eq 2.5
      expect((1..10).to_a.variance).to eq 9.166666666666666
      expect((-10..-5).to_a.variance).to eq 3.5
    end
  end

  describe '#standard_deviation' do
    it 'calcultes the *sample* standard deviation of an specific collection' do
      expect((1..5).to_a.standard_deviation).to eq 1.5811388300841898
      expect((1..10).to_a.standard_deviation).to eq 3.0276503540974917
      expect((-10..-5).to_a.standard_deviation).to eq 1.8708286933869707
    end
  end
end
