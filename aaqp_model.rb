class AAQPModel
  def self.make_instances(result_array)
    model_array = []
    result_array.length.times {|count| model_array << self.new(result_array[count])}
    model_array
  end
end
