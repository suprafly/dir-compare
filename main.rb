
# Christopher Lyman
# http://www.suprafly.net

# A class that compares the contents of base directory to comparison directory
# Currently executes @ depth(2)

# Features to be added:
# Allow user to set depth of directory search
# Allow user to specify a REGEX to evaluate directory based upon



class Dir_Compare
 def initialize(k,t)
	@b1 = k
	@b2 = t
	@bdr = Dir.entries(@b1)
	@cdr = Dir.entries(@b2)

	@bdr = clean_up(@bdr)
	@cdr = clean_up(@cdr)
	@base_dir = Hash.new
	@diff=[]

	@discrep = false	#Discrepancy file setup
	@di = [File.expand_path(File.dirname(__FILE__)),"discrep.txt"].join("/")
	File.delete(@di) if File.exists?(@di)

 end

 def clean_up(c)
	c = c - [".", ".."] if c != nil
 end

 def start_sweep(mode)
	b_diff = @bdr - @cdr
	c_diff = @cdr - @bdr

	if mode == 1
	 if b_diff == [] && c_diff == []
	   puts "Identical directory structure"
	 else
	   if b_diff != []
	    puts "Present in base but not present in comparison: ", b_diff
	   else
	    puts "Present in comparison but not present in base: ", c_diff
	   end
	 end

	else mode == 2				

	  mode2

	  puts "1 for screen output, 2 for file output: "	#Output all results
	  j = STDIN.gets

	  if @diff == nil
	    puts "Directories are identical"
	  else
	   if j == 2
	  	puts "See output.txt for files missing"
	  	afile = File.new("/home/truck/programs/dir_comp/output.txt","w")
	  	if afile
	   	   afile.syswrite(["Missing from base directory:\n",@diff.join("\n")].join)
	  	else
	   	   puts "Unable to open output.txt!"
	  	end
	  	afile.close
	   else
	   	puts ["Missing from base directory:\n",@diff.join("\n")].join
	   end# J = 2 END
	 end #DIFF NIL END
	end #MODE IF ELSE END
	puts "\nThere were discrepancies. Please see discrep.txt for more information." if @discrep

 end #DEF OUTPUT END

 def mode2
	@bdr.each do |x| 
		@base_dir[x] = Dir.entries(@b1+"/"+x) if File.directory? "#{@b1}/#{x}"
		@base_dir[x] = clean_up(@base_dir[x])
	end

	@cdr.each do |x|
		if !@base_dir.has_key?(x)						#An element in Comp is not found in Base
			@diff.push "#{@b2}/#{x}/"
		else	#Element in Comp found in Base
			x.each do |y| 
				c_sub = Dir.entries("#{@b2}/#{x}") if File.directory? "#{@b2}/#{x}"		#COMP/SUB/
				c_sub = clean_up(c_sub)
				b_sub = Dir.entries("#{@b1}/#{x}") if File.directory? "#{@b1}/#{x}"		#BASE/SUB/
				b_sub = clean_up(b_sub)
				if b_sub == [] and c_sub != []
					c_sub.each do |z|  
						@diff.push "#{@b2}/#{x}/#{z}"
					end	
				end
				c_sub.each do |z|					#For each Sub directory element
					if !b_sub.include?(z)			#Sub directory entry not present
						@diff.push "#{@b2}/#{x}/#{z}"
					else											#Sub directories Present, Check elements
						c_sub2 = Dir.entries("#{@b2}/#{x}/#{z}") if File.directory? "#{@b2}/#{x}/#{z}"	#COMP/SUB/*.*
						b_sub2 = Dir.entries("#{@b1}/#{x}/#{z}") if File.directory? "#{@b1}/#{x}/#{z}"	#BASE/SUB/*.*
						b_sub2 = clean_up(b_sub2)
						c_sub2 = clean_up(c_sub2)
						c_sub2 = c_sub2.sort if c_sub2 != nil		#Sorting the arrays if they contain anything
						b_sub2 = b_sub2.sort if b_sub2 != nil
						discrep_method(b_sub2,c_sub2,x,z)
					end
				end #c_sub each END
			end #@base_dir each END
		end
	end #cdr each END
	@diff = @diff.uniq

 end

 def discrep_method(b_sub2,c_sub2,x,z)
	if c_sub2 != b_sub2
		@diff.push "#{@b2}/#{x}/#{z}"
		@discrep = true
		afile = File.new("/home/truck/programs/dir_comp/discrep.txt","a")
		if afile
		   afile.syswrite("\n\n#{x}/#{z}:\n\nFrom Base:\n")
		   afile.syswrite("No Entries") if b_sub2 == []
		   afile.syswrite([b_sub2-c_sub2].join("\n")) if b_sub2 != []
		   afile.syswrite("\n\nFrom Compared:\n")
		   afile.syswrite("No Entries") if c_sub2 == []
		   afile.syswrite([c_sub2-b_sub2].join("\n")) if c_sub2 != []
		else
		   puts "Unable to open discrep.txt!"
		end
		afile.close
	end
 end

end #CLASS END


dir_sweep = Dir_Compare.new(ARGV[0],ARGV[1])

puts "Type 1 for subdirectory comparison or 2 for full directory trace:"
mode = (STDIN.gets).to_i

dir_sweep.start_sweep(mode)





