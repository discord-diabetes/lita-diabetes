require 'lita-diabetes'
require 'spec_helper'

describe Lita::Handlers::Diabetes, lita_handler: true do
  it { is_expected.to route '45' }
  it { is_expected.to route '7.9' }
  it { is_expected.to route_command 'estimate a1c 102' }
  it { is_expected.to route_command 'estimate a1c 4.9' }
  it { is_expected.to route_command 'estimate average 5.7' }
  it { is_expected.to route_command 'estimate average 45' }
  it 'converts mg/dL to mmol/L' do
    send_message('90')
    expect(replies.last).to eq('90 mg/dL is 5.0 mmol/L')
  end
  it 'converts mmol/L to mg/dL' do
    send_message('5.5')
    expect(replies.last).to eq('5.5 mmol/L is 99 mg/dL')
  end
  it 'ignores URI in message' do
    send_message('https://www.reddit.com/r/diabetes/comments/354r77/20yo_diagnosed_with_type_1_today/cr17as0?context=3')
    expect(replies.last).to be(nil)
  end
  it 'ignores numbers without underscores' do
    send_message('test message 34 please ignore')
    expect(replies.last).to be(nil)
  end
  it 'ignores decimal numbers without underscores' do
    send_message('test message 3.4 please ignore')
    expect(replies.last).to be(nil)
  end
  it 'ignores numbers without leading underscore' do
    send_message('test message 34_ please ignore')
    expect(replies.last).to be(nil)
  end
  it 'ignores decimal numbers without leading underscore' do
    send_message('test message 3.4_ please ignore')
    expect(replies.last).to be(nil)
  end
  it 'ignores numbers without trailing underscore' do
    send_message('test message _34 please ignore')
    expect(replies.last).to be(nil)
  end
  it 'ignores decimal numbers without trailing underscore' do
    send_message('test message _3.4 please ignore')
    expect(replies.last).to be(nil)
  end
  it 'ignores numbers at beginning of line' do
    send_message('54 test message')
    expect(replies.last).to be(nil)
  end
  it 'ignores decimal numbers at beginning of line' do
    send_message('5.4 test message')
    expect(replies.last).to be(nil)
  end
  it 'ignores numbers at end of line' do
    send_message('test message 54')
    expect(replies.last).to be(nil)
  end
  it 'ignores decimal numbers at end of line' do
    send_message('test message 5.4')
    expect(replies.last).to be(nil)
  end
  it 'converts numbers with underscores' do
    send_message('test message _90_ please ignore')
    expect(replies.last).to eq('90 mg/dL is 5.0 mmol/L')
  end
  it 'converts decimal numbers with underscores' do
    send_message('test message _5.0_ please ignore')
    expect(replies.last).to eq('5.0 mmol/L is 90 mg/dL')
  end
  it 'converts mg/dl numbers by text' do
    send_message('test message 90 mg/dl please ignore')
    expect(replies.last).to eq('90 mg/dL is 5.0 mmol/L')
  end
  it 'converts mg/dl numbers by text with missing slash' do
    send_message('test message 90 mgdl please ignore')
    expect(replies.last).to eq('90 mg/dL is 5.0 mmol/L')
  end
  it 'converts mmol/L numbers by text' do
    send_message('test message 5.0 mmol/l please ignore')
    expect(replies.last).to eq('5.0 mmol/L is 90 mg/dL')
  end
  it 'converts mmol/L numbers by text with missing unit' do
    send_message('test message 5.0 mmol please ignore')
    expect(replies.last).to eq('5.0 mmol/L is 90 mg/dL')
  end
  it 'converts mg/dl numbers with a decimal' do
    send_message('test message 99.9 mg/dl please ignore')
    expect(replies.last).to eq('99.9 mg/dL is 5.5 mmol/L')
  end
  it 'converts mmol/L numbers by themselves' do
    send_message('45 mmol/L')
    expect(replies.last).to eq('45 mmol/L is 811 mg/dL')
  end
end
