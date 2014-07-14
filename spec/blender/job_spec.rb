require 'spec_helper'

describe Blender::Job do
  let(:driver) do
    Object.new
  end
  it '#should use default driver if no tasks are given' do
    job = Blender::Job.new(1, driver , [] ,[])
    expect(job.driver).to eq(driver)
  end
  it 'should not use default driver if all tasks has same driver' do
    t1 = create_task('t1', driver)
    t2 = create_task('t2', driver)
    t3 = create_task('t3', driver)
    job = Blender::Job.new(1, Object.new , [] ,[t1, t2, t3])
    expect(job.driver).to eq(driver)
  end
  it 'should raise exception if multiple drivers are present in task list ' do
    t1 = create_task('t1', driver)
    t2 = create_task('t2', Object.new)
    t3 = create_task('t3', driver)
    expect do
      Blender::Job.new(1, Object.new, [] ,[t1, t2, t3])
    end.to raise_error(Blender::Exceptions::MultipleDrivers)
  end
  describe '#name' do
    it 'with one host, one task' do
      t1 = create_task('t1', driver)
      job = Blender::Job.new(1, Object.new, ['a'] ,[t1])
      expect(job.name).to eq('t1 on a')
    end
    it 'with one host, many tasks' do
      t1 = create_task('t1', driver)
      t2 = create_task('t2', driver)
      job = Blender::Job.new(1, Object.new, ['a'] ,[t1, t2])
      expect(job.name).to eq('2 tasks on a')
    end
    it 'with 0 hosts, many tasks' do
      t1 = create_task('t1', driver)
      t2 = create_task('t2', driver)
      t3 = create_task('t3', driver)
      job = Blender::Job.new(1, Object.new, [] ,[t1, t2, t3])
      expect(job.name).to eq('3 tasks on 0 members')
    end
    it 'with many hosts, many tasks' do
      t1 = create_task('t1', driver)
      t2 = create_task('t2', driver)
      job = Blender::Job.new(1, Object.new, ['a', 'b', 'c'] ,[t1, t2])
      expect(job.name).to eq('2 tasks on 3 members')
    end
    it 'with many hosts one task' do
      t1 = create_task('t1', driver)
      job = Blender::Job.new(1, Object.new, ['a', 'b', 'c'] ,[t1])
      expect(job.name).to eq('t1 on 3 members')
    end
  end
end
