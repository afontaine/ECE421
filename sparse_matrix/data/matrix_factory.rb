require 'contracts'
require 'matrix'
require_relative '../contracts/contract_extensions'

module MatrixFactory
  include Contracts
  include ContractExtensions

  Contract RespondTo[:rows], EnumerableOf[RespondTo[:each]] => Matrix
  def self.create(klass, rows)
    klass.rows(rows)
  end

  Contract RespondTo[:build], RespondTo[:to_i], Maybe[Or[RespondTo[:to_i], Func[Any => Any]]] => Or[Matrix, Enumerable]
  def self.build(klass, row_count, column_count = row_count)
    row_count = row_count.to_i
    column_count = column_count.to_i
    block_given? ? klass.build(row_count, column_count) { |i,j|  yield i, j } : klass.build(row_count, column_count)
  end

end