require 'spec_helper'
require 'hangperson_game'

module HangpersonGameSpecHelper do
  def guess_several_letters(game, letters)
    letters.chars do |letter|
      game.guess(letter)
    end
  end
end

describe HangpersonGame do
  include HangpersonGameSpecHelper

  let(:game) { HangpersonGame.new(word) }
  let(:word) { 'gorp' }

  subject { game }
  it { expect(game).to be_an_instance_of(HangpersonGame) }
  it { expect(game.word).to eq(param) }
  it { expect(game.guesses).to be_empty }
  it { expect(game.wrong_guesses).to be_empty }

  describe '#guess' do
    let(:word) { 'garply' }
    subject { game.guess(guess) }

    context "guessing with a matching letter but different case" do
      let(:guess) { 'A' }

      it "doesn't match since it's case-sensitive" do
        expect(subject).to be false
      end

      context "after guessing" do
        before { subject }

        it { expect(game.guesses).to be_empty }
        it { expect(game.wrong_guesses).to be_empty }
      end
    end

    context 'correctly' do
      let(:guess) { 'a' }

      it { expect(subject).to be true }

      context "after guessing" do
        before { subject }

        it { expect(game.guesses).to eql(guess) }
        it { expect(game.wrong_guesses).to be_empty }
      end
    end

    context 'incorrectly' do
      let(:guess) { 'z' }

      it { expect(subject).to be false }

      context "after guessing" do
        before { subject }

        it { expect(game.guesses).to eql(guess) }
        it { expect(game.wrong_guesses).to eql(guess) }
      end
    end

    context "guessing the same letter again" do
      let(:guess) { 'a' }
      before { game.guess(guess) }

      it { expect(subject).to be false }

      it { expect { ->{subject} }.to_not change { game.reload.guesses }.from(guess) }
      it { expect { ->{subject} }.to_not change { game.reload.wrong_guesses }.from(guess) }
    end

    context "invalid inputs" do
      let(:inputs) { ['', '%', nil] }
      inputs.each do |input|
        it { expect { ->{subject} }.to raise_error(ArgumentError) }
      end
    end
  end

  describe '#word_with_guesses' do
    let(:word) { 'banana' }

    # for a given set of guesses, what should the word look like?
    let(:test_cases) do
      {
        'bn' =>  'b-n-n-',
        'def' => '------',
        'ban' => 'banana'
      }
    end
    test_cases.each_pair do |guesses, displayed|
      it "should be '#{displayed}' when guesses are '#{guesses}'" do
        guess_several_letters(game, guesses)
        expect(game.word_with_guesses).to eq(displayed)
      end
    end
  end

  describe '#game_status' do
    subject { game.game_status }

    before { guess_several_letters(game, guesses) }
    let(:word) { 'dog' }

    context 'all letters guessed' do
      let(:guesses) { 'ogd' }
      it { expect(subject).to eq(described_class::GAME_STATUS_WIN) }
    end

    context 'after 7 incorrect guesses' do
      let(:guesses) { 'tuvwxyz' }
      it { expect(subject).to eq(described_class::GAME_STATUS_LOSE) }
    end

    context 'neither win nor lose' do
      let(:guesses) { 'do' }
      it { expect(subject).to eq(described_class::GAME_STATUS_PLAY) }
    end
  end
end
