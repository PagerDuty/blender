require 'spec_helper'
describe Blender::SchedulingStrategy do
  let(:hosts){ %w{ h1 h2 h3 } }
  let(:tasks){ Array.new(4){ |n| create_task("t#{n}") } }
  let(:driver){ Object.new }
  subject(:jobs) do
    described_class.new.compute_jobs(tasks)
  end
  describe Blender::SchedulingStrategy::Default do
    before do
      tasks.each{|t| t.members(hosts)}
    end
    it 'number of jobs' do
      expect(jobs.size).to eq(hosts.size * tasks.size)
    end
    it 'fist job should be first task on first host' do
      expect(jobs.first.tasks).to eq([tasks.first])
      expect(jobs.first.hosts).to eq([hosts.first])
    end
    it 'last job should be last task on last host' do
      expect(jobs[-1].tasks).to eq([tasks.last])
      expect(jobs[-1].hosts).to eq([hosts.last])
    end
    it 'all jobs should have one host' do
      expect(jobs.map(&:hosts).map(&:size).uniq).to eq([1])
    end
    it 'all jobs should have one task' do
      expect(jobs.map(&:tasks).map(&:size).uniq).to eq([1])
    end
  end
  describe Blender::SchedulingStrategy::PerHost do
    before do
      tasks.each{|t| t.members(hosts)}
    end
    it 'number of jobs' do
      expect(jobs.size).to eq(hosts.size)
    end
    it 'fist job should be all tasks on first host' do
      expect(jobs.first.tasks).to eq(tasks)
      expect(jobs.first.hosts).to eq([hosts.first])
    end
    it 'last job should be all tasks on last host' do
      expect(jobs[-1].tasks).to eq(tasks)
      expect(jobs[-1].hosts).to eq([hosts.last])
    end
    it 'all jobs should have one host' do
      expect(jobs.map(&:hosts).map(&:size).uniq).to eq([1])
    end
    it 'all jobs should have all task' do
      expect(jobs.map(&:tasks).map(&:size).uniq).to eq([tasks.size])
    end
  end
  describe Blender::SchedulingStrategy::PerTask do
    before do
      tasks.each{|t| t.members(hosts)}
    end
    it 'number of jobs' do
      expect(jobs.size).to eq(tasks.size)
    end
    it 'fist job should be first task on all hosts' do
      expect(jobs.first.tasks).to eq([tasks.first])
      expect(jobs.first.hosts).to eq(hosts)
    end
    it 'last job should be last task on all hosts' do
      expect(jobs[-1].tasks).to eq([tasks.last])
      expect(jobs[-1].hosts).to eq(hosts)
    end
    it 'all jobs should have all hosts' do
      expect(jobs.map(&:hosts).map(&:size).uniq).to eq([hosts.size])
    end
    it 'all jobs should have one task' do
      expect(jobs.map(&:tasks).map(&:size).uniq).to eq([1])
    end
  end
end
