require "./Series"

struct DataFrame
	alias Index2ArrayType = Array(String)|Array(Float64)|Array(Float32)|Array(Int32)|Array(Int64)|Array(Float64|Int64)|Array(Int64|String)|Array(Float32|Int32)|Array(Float32|Float64)|Array(Int32|String)|Array(Int32|Int64)|Array(Float32|String)|Array(Float64|Int32)|Array(Float64|String)|Array(Float32|Int64)|Array(Float64|Int32|String)|Array(Float64|Int32|Int64)|Array(Int32|Int64|String)|Array(Float32|Float64|Int32)|Array(Float32|Int64|String)|Array(Float32|Float64|String)|Array(Float32|Int32|Int64)|Array(Float64|Int64|String)|Array(Float32|Int32|String)|Array(Float32|Float64|Int64)|Array(Float32|Float64|Int32|Int64)|Array(Float32|Float64|Int64|String)|Array(Float64|Int32|Int64|String)|Array(Float32|Float64|Int32|String)|Array(Float32|Int32|Int64|String)|Array(Float32|Float64|Int32|Int64|String)
	alias ColumnType = Int64|Float32|Float64|String|Int32|(Int64|String)|(Float32|Int64)|(Int32|String)|(Float32|Float64)|(Float32|String)|(Float32|Int32)|(Int32|Int64)|(Float64|Int64)|(Float64|String)|(Float64|Int32)|(Float32|Float64|Int64)|(Float64|Int32|Int64)|(Float32|Int32|String)|(Float32|Int32|Int64)|(Float32|Float64|String)|(Float32|Int64|String)|(Float32|Float64|Int32)|(Float64|Int64|String)|(Float64|Int32|String)|(Int32|Int64|String)|(Float32|Float64|Int32|Int64)|(Float32|Int32|Int64|String)|(Float32|Float64|Int64|String)|(Float64|Int32|Int64|String)|(Float32|Float64|Int32|String)|(Float32|Float64|Int32|Int64|String)
	alias KType = String
	property dict = Hash(KType, Series).new
	property index, columns # index/columns only support String
	def initialize(data, @index  = [] of KType, @columns  = [] of KType)
		if data.is_a?(Hash) # copy data to dict
			## check data.key and data.value
			data.values.each do |e|
				raise "error: DataFrame only support Hash(String, Array(Int32|Int64|String|Float32|Float64)) yet, instead of #{typeof(e)}\n" unless e.is_a?(Array)
			end

			# check and get index
			nrow_number = data.first_value.size
			#puts "data.first_value is #{data.first_value}"
			if index.size == 0
				(0...nrow_number).to_a.each {|e| index << e.to_s}
			elsif index.size != nrow_number
				raise "error: data have #{nrow_number} lines, but you give index size is #{index.size}, index is #{index}\n" 
			end

			# check and get columns
			if columns.size == 0
				data.keys.each {|e| columns << e.to_s}
			elsif columns.size != data.keys.size
				raise "error: data have #{data.keys.size} columns, but columns: size #{columns.size}\n"
			end

			## copy data to dict with new index and columns
			data.keys.each_with_index do |key, i| 
				column = columns[i].to_s
				dict[column] = Series.new unless dict.has_key?(column)
				data[key].each_with_index do |e, j| 
					dict[column].add index[j], e
				end
				data.delete(key)
			end

		elsif data.is_a?(Array)
			raise "warn: Array support is to do for DataFrame\n"
		else
			raise "error: only support Hash or Array yet\n"
		end

	end
	def head(nrow = 3)
		data_head = Hash(KType, Array(ColumnType)).new
		dict.keys.each do |e|
			dict[e][0...nrow].to_a.each do |ee|
				data_head[e] = Array(ColumnType).new unless data_head.has_key?(e)
				data_head[e] << ee
			end
		end
		return DataFrame.new(data_head)
	end
	def [](column_name : String)
		if dict.has_key?(column_name)
			return dict[column_name]
		else
			puts "keys is #{dict.keys}"
			raise "error: DataFrame have no column #{column_name}\n"
		end
	end
	def [](col_number : Int32|Int64)
		return dict[dict.keys[col_number]]
	end
	def [](range : Range)
		puts "not support range yet"
	end
	def [](series : Series)
		new_index = series.index
		new_columns = columns
		data_series = Hash(KType, Array(ColumnType)).new
		series.index.each do |i|
			new_columns.each do |c|
				data_series[c] = Array(ColumnType).new unless data_series.has_key?(c)
				data_series[c] << dict[c][i]
			end
		end
		return DataFrame.new(data_series, new_index, new_columns)
	end
	def loc
		return self.t
	end
	def t
		new_index = [] of KType
		new_columns = [] of KType
		index.each {|e| new_columns << e}
		columns.each {|e| new_index << e}

		data_t = Hash(KType, Array(ColumnType)).new
		index.each_with_index do |value, i|
			value = value.to_s
			dict.keys.each do |key|
				data_t[value] = Array(ColumnType).new unless data_t.has_key?(value)
				data_t[value] << dict[key][i]
			end
		end
		#puts "t index is #{new_index}, new_columns is #{new_columns}"
		return DataFrame.new(data_t, new_index, new_columns)
		# Transpose index and columns
	end
	def to_str(sep : String = "\t")
		str = sep
		columns.each {|e| str +="#{e}#{sep}"}
		str = str.gsub(/#{sep}$/, "\n")

		(0...index.size).to_a.each do |i|
			str += "#{index[i]}#{sep}"
			dict.keys.each do |key|	
				str = "#{str}#{dict[key][i]}#{sep}"
			end
			str = str.gsub(/#{sep}$/, "\n")
		end
		return str
	end
end


def dataframe_test
	t = {"C4" => [1,2,"4","C"], "B3" => ["A", "B", 3,"D"]}
	puts typeof(t)
	puts "t is #{t}"
	y = DataFrame.new(t)

	puts "y.index #{y.index}"
	puts "y.columns #{y.columns}"
	puts "y[C4][0] is "
	puts y["C4"][0]
	puts y[1][1]

	puts "y.head().to_str() is \n#{y.head().to_str()}"

	puts "dict is #{y.dict}"

	puts "y.t.to_str() is #{y.t.to_str()}"

	puts "y.loc[0][C4] is "
	puts y.loc.index
	puts y.loc.columns
	puts y.loc["0"]["C4"]
	puts y.loc[1][1]
end

