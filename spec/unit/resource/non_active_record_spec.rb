require 'rails_helper'

# A plain Ruby resource, e.g. a background job read from a queue backend.
class NonArRecord
  include ActiveModel::Model
  attr_accessor :id, :title
end

class NonArRecordWithFinder < NonArRecord
  def self.find_by(conditions)
    new(id: conditions[:id], title: 'Found') if conditions[:id] == '42'
  end
end

module ActiveAdmin
  RSpec.describe Resource, "for a non-ActiveRecord class" do
    let(:application) { ActiveAdmin::Application.new }
    let(:namespace) { ActiveAdmin::Namespace.new application, :admin }
    let(:resource_config) { ActiveAdmin::Resource.new namespace, NonArRecord }

    it "has no default attributes" do
      expect(resource_config.resource_attributes).to eq({})
      expect(resource_config.resource_columns).to eq []
    end

    it "has no default filters" do
      expect(resource_config.filters).to eq({})
    end

    it "defaults sort order to id_desc" do
      expect(resource_config.sort_order).to eq 'id_desc'
    end

    it "disables comments by default" do
      expect(resource_config.comments?).to eq false
    end

    it "allows comments to be enabled explicitly" do
      resource_config.comments = true
      expect(resource_config.comments?).to eq true
    end

    describe "#find_resource" do
      it "returns nil when the class has no find_by" do
        expect(namespace.register(NonArRecord).find_resource('42')).to be_nil
      end

      it "uses find_by(id:) when available" do
        config = namespace.register(NonArRecordWithFinder)
        expect(config.find_resource('42').title).to eq 'Found'
      end
    end
  end

  RSpec.describe OrderClause, "for a non-SQL collection" do
    let(:application) { ActiveAdmin::Application.new }
    let(:namespace) { ActiveAdmin::Namespace.new application, :admin }
    let(:config) { ActiveAdmin::Resource.new namespace, NonArRecord }

    it "returns the collection unchanged" do
      collection = [NonArRecord.new(id: 1)]
      expect(described_class.new(config, 'id_desc').apply(collection)).to equal collection
    end
  end

  RSpec.describe Filters::Active, "without a search" do
    let(:application) { ActiveAdmin::Application.new }
    let(:namespace) { ActiveAdmin::Namespace.new application, :admin }
    let(:config) { ActiveAdmin::Resource.new namespace, NonArRecord }

    it "has no filters" do
      expect(described_class.new(config, nil).filters).to eq []
    end
  end

  RSpec.describe Helpers::Collection, "with a query object" do
    include described_class

    let(:query) { double('query', count: 3) }

    it "counts a collection that is not a Relation" do
      expect(collection_size(query)).to eq 3
    end
  end

  RSpec.describe Views::TableFor::Column, "with a non-ActiveRecord class" do
    it "is not sortable by default" do
      column = described_class.new(:title, :title, NonArRecord)
      expect(column).not_to be_sortable
    end

    it "is sortable when requested" do
      column = described_class.new(:title, :title, NonArRecord, sortable: :title)
      expect(column).to be_sortable
    end
  end
end
