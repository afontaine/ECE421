require 'matrix'

module MatrixFactory

  def self.create(klass, rows)
    klass.rows(rows)
  end

  def self.build(klass, row_count, column_count = row_count)
    row_count = row_count.to_i
    column_count = column_count.to_i
    block_given? ? klass.build(row_count, column_count) { |i,j|  yield i, j } : klass.build(row_count, column_count)
  end

end