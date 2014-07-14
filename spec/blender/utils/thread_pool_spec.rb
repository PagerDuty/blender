require 'spec_helper'

describe Blender::Utils::ThreadPool do
  let(:pool) { described_class.new(5)}
  it 'should parallelize works' do
    10.times do
      pool.add_job do
        sleep 1
      end
    end
    t1 = Time.now
    pool.run_till_done
    t2 = Time.now
    expect(t2 - t1).to be < 4
  end
end
