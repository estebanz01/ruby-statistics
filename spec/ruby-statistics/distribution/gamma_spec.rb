# frozen_string_literal: true

require 'spec_helper'

describe RubyStatistics::Distribution::Gamma do
  let(:shape_p) { 4 }
  let(:scale_p) { 2 }
  let(:rate_p) { 1.0 / shape_p }
  let(:rate_gamma) { described_class.new(shape: shape_p) }
  let(:scale_gamma) { described_class.new(shape: shape_p, scale: scale_p) }

  before do
    # so we can check that the rate/scale attr has been called
    allow(rate_gamma).to receive(:rate).and_call_original
    allow(scale_gamma).to receive(:scale).and_call_original
  end

  describe '#as_rate?' do
    it 'is true when no scale parameter is defined' do
      expect(described_class.new(shape: 1)).to be_as_rate
    end

    it 'is false when a scale parameter is defined' do
      expect(described_class.new(shape: 1, scale: 1)).to_not be_as_rate
    end
  end

  describe '#mean' do
    context 'when the scale parameter is defined' do
      it 'returns the expected value using the scale parameter' do
        expect(scale_gamma.mean).to eq shape_p * scale_p
        expect(scale_gamma).to have_received(:scale).at_least(:once)
      end
    end

    context 'when the rate parameter is used' do
      it 'returns the expected value using the rate parameter' do
        expect(rate_gamma.mean).to eq shape_p / rate_p
        expect(rate_gamma).to have_received(:rate).once
      end
    end
  end

  describe '#mode' do
    it 'returns zero if the shape is zero' do
      expect(described_class.new(shape: 0).mode).to be_zero
    end

    it 'returns zero if the shape is negative' do
      expect(described_class.new(shape: -1).mode).to be_zero
    end

    context 'when the scale parameter is defined' do
      it 'returns the expected calculations using the scale parameter' do
        expect(scale_gamma.mode).to eq (shape_p - 1.0) * scale_p
        expect(scale_gamma).to have_received(:scale).at_least(:once)
      end
    end

    context 'when the rate parameter is used' do
      it 'returns the expected calculations using the rate parameter' do
        expect(rate_gamma.mode).to eq (shape_p - 1.0) / rate_p
        expect(rate_gamma).to have_received(:rate).at_least(:once)
      end
    end
  end

  describe '#variance' do
    context 'when the scale parameter is defined' do
      it 'returns the expected calculations using the scale parameter' do
        expect(scale_gamma.variance).to eq shape_p * (scale_p ** 2.0)
        expect(scale_gamma).to have_received(:scale).at_least(:once)
      end
    end

    context 'when the rate parameter is used' do
      it 'returns the expected calculations using the rate parameter' do
        expect(rate_gamma.variance).to eq shape_p / (rate_p ** 2.0)
        expect(rate_gamma).to have_received(:rate).at_least(:once)
      end
    end
  end

  describe '#skewness' do
    it 'returns the expected calculation for both types of gamma definitions' do
      skewness = 2.0 / Math.sqrt(shape_p)

      expect(rate_gamma.skewness).to eq(skewness)
      expect(scale_gamma.skewness).to eq(skewness)
    end
  end

  describe '#density_function' do
    context 'when the scale parameter is defined' do
      it 'returns the excepted calculations' do
        # Values extracted using dgamma(x, shape = shape_p, scale = scale_p) in R 4.4.1
        values = [0.006318028, 0.03065662, 0.06275536, 0.09022352, 0.1068815]

        values.each_with_index do |value, index|
          expect(scale_gamma.density_function(index + 1)).to be_within(0.0000001).of(value)
        end
      end
    end

    context 'when the rate parameter is used' do
      it 'returns the expected calculations' do
        # Values extracted using dgamma(x, shape = shape_p, rate = rate_p) in R 4.4.1
        values = [0.0005070318, 0.003159014, 0.008303318, 0.01532831, 0.02331582]

        values.each_with_index do |value, index|
          expect(rate_gamma.density_function(index + 1)).to be_within(0.0000001).of(value)
        end
      end
    end
  end

  describe '#cumulative_function' do
    context 'when the scale parameter is defined' do
      it 'returns the expected calculations' do
        # Values extracted using pgamma(x, shape = shape_p, scale = scale_p) in R 4.4.1
        values = [0.001751623, 0.01898816, 0.06564245, 0.1428765, 0.2424239]

        values.each_with_index do |value, index|
          expect(scale_gamma.cumulative_function(index + 1)).to be_within(0.0000001).of(value)
        end
      end
    end

    context 'when the rate parameter is used' do
      it 'returns the expected calculations' do
        # Values extracted using pgamma(x, shape = shape_p, rate = rate_p) in R 4.4.1
        values = [0.0001333697, 0.001751623, 0.007292167, 0.01898816, 0.03826905]

        values.each_with_index do |value, index|
          expect(rate_gamma.cumulative_function(index + 1)).to be_within(0.0000001).of(value)
        end
      end
    end
  end
end
