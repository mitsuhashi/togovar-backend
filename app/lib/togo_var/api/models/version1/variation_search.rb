# frozen_string_literal: true

module TogoVar
  module API
    module Models
      module Version1
        class VariationSearch < Base
          ACCEPTABLE_COMPONENTS = { id: Id,
                                    location: Location,
                                    type: VariationType,
                                    consequence: VariationConsequence,
                                    sift: Sift,
                                    polyphen: Polyphen,
                                    alphamissense: AlphaMissense,
                                    frequency: VariationFrequency,
                                    significance: ClinicalSignificance,
                                    gene: Gene,
                                    disease: Disease,
                                    and: And,
                                    or: Or }.freeze

          module Defaults
            LIMIT = 100
          end

          attr_reader :query
          attr_reader :limit
          attr_reader :offset
          attr_accessor :options

          validates :limit, presence: true
          validates :limit, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000 }
          validate do
            next if offset.nil?

            case offset
            when Numeric
              min = 0
              max = 10_000 - limit
              errors.add(:offset, "must be greater than or equal to #{min}") if offset < min
              errors.add(:offset, "must be less than or equal to #{max}(= 10,000 - #{limit})") if max < offset
            when Array
              errors.add(:offset, 'must consist of at least 2 elements [chrom(index), pos]') if offset.size < 2
              errors.add(:offset, 'must consist of at most 4 elements [chrom(index), pos, ref, alt]') if offset.size > 4

              case offset[0].to_s
              when /(chr)?X/
                offset[0] = 23
              when /(chr)?Y/
                offset[0] = 24
              when /(chr)?MT/
                offset[0] = 25
              end

              begin
                Integer(offset[0])
                Integer(offset[1])
              rescue ArgumentError
                errors.add(:base, 'First two elements of offset must be numeric') if offset.size > 4
              end
            else
              errors.add(:offset, 'must be a numeric or an array')
            end
          end

          def initialize(*args)
            super

            hash = @args.first || {}

            @query = hash.fetch(:query, {})
            @limit = hash.fetch(:limit, Defaults::LIMIT).to_i
            @offset = (offset = hash[:offset]).is_a?(Array) ? offset : offset&.to_i
            @options = {}
          end

          # @return [Array]
          def models
            @models ||= [{ query: Query.new(@query) }]
          end

          def to_hash
            validate

            user = @options[:user]
            source = Variation.frequency_datasets(user).map do |x| # TODO: remove if dataset renamed
              case x.to_s
              when 'jga_wes'
                :jga_ngs
              when /^bbj_riken.mpheno\d+$/
                :"#{x}.all"
              else
                x
              end
            end

            query = Elasticsearch::DSL::Search.search do
              query do
                bool do
                  must Variation.default_condition
                  must do
                    bool do
                      should do
                        nested do
                          path :frequency
                          query do
                            terms 'frequency.source': source
                          end
                        end
                      end
                      should do
                        nested do
                          path :conditions
                          query do
                            terms 'conditions.source': Variation.condition_datasets(user)
                          end
                        end
                      end
                    end
                  end
                  if (q = models.first[:query].to_hash).present?
                    must q
                  end
                end
              end
            end.to_hash[:query]

            limit = @limit
            offset = @offset

            hash = Elasticsearch::DSL::Search.search do
              query query
              sort do
                by :'chromosome.index'
                by :'vcf.position'
                by :'vcf.reference'
                by :'vcf.alternate'
              end
              size limit
              from offset if offset.is_a?(Numeric)
            end.to_hash

            if offset.is_a?(Array)
              hash.update(search_after: [offset[0].to_i, offset[1].to_i, offset[2].to_s, offset[3].to_s])
            end

            hash.compact
          end

          class Query < Base
            validate { errors.add(:args, 'must be an array of a component') unless args.size == 1 }
            validate { errors.add(:args, 'contains objects other than Hash') unless args.all? { |x| x.is_a?(Hash) } }
            validate { errors.add(:args, 'contains unexpected component') if args.first.size > 1 }
            validate do
              key, _value = extract_component
              next if key.nil? || (key.present? && acceptable_components.key?(key.to_sym))

              list = acceptable_components.keys.to_sentence(CommonOptions::SENTENCE_OR_CONNECTORS)
              errors.add(:args, "must consist of '#{list}'")
            end

            # @return [Array]
            def models
              @models ||= begin
                            key, value = extract_component
                            return [] unless key.present? && (klass = acceptable_components[key.to_sym])

                            [{ key.to_sym => klass < Bool ? klass.new(*value) : klass.new(value) }]
                          end
            end

            def to_hash
              validate

              Elasticsearch::DSL::Search.search do
                if (q = models.first&.values&.first)
                  query q
                end
              end.to_hash[:query]
            end

            protected

            def acceptable_components
              VariationSearch::ACCEPTABLE_COMPONENTS
            end

            private

            # @return [Array] the first key-value pair of hash passed to args
            def extract_component
              @args.first&.first || []
            end
          end
        end
      end
    end
  end
end
