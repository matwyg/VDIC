virtual class shape;
	protected real width=-1;
	protected real height=-1;

	function new(real w, real h);
		width = w;
		height = h;
	endfunction : new

	pure virtual function real get_area();

	pure virtual function void print();

endclass : shape

class rectangle extends shape;

	function new(real w, real h);
		super.new(w, h);
	endfunction : new

	function real get_area();
		return width*height;
	endfunction : get_area

	function void print();
		$display ("Rectangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print

endclass : rectangle

class square extends rectangle;

	function new(real s);
		super.new(s, s);
	endfunction : new

	function void print();
		$display ("Square w=%g area=%g", width, get_area());
	endfunction : print

endclass : square

class triangle extends shape;

	function new(real w, real h);
		super.new(w, h);
	endfunction : new

	function real get_area();
		return width*height/2;
	endfunction : get_area

	function void print();
		$display ("Triangle w=%g h=%g area=%g", width, height, get_area());
	endfunction : print

endclass : triangle

class shape_factory;

	static function shape make_shape(string shape_type, real w, real h);
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		case (shape_type)
			"rectangle" : begin
				rectangle_h = new(w, h);
				return rectangle_h;
			end

			"square" : begin
				square_h = new(w);
				return square_h;
			end

			"triangle" : begin
				triangle_h = new(w, h);
				return triangle_h;
			end

			default :
				$fatal (1, {"No such shape: ", shape_type});

		endcase // case (species)

	endfunction : make_shape

endclass : shape_factory


class shape_reporter #(type T=shape);

	protected static T queues_shape_storage[$];
	protected static real sum_of_area;

	static function void store_shape(T l);
		queues_shape_storage.push_back(l);
	endfunction : store_shape

	static function void report_shapes();
		foreach (queues_shape_storage[i]) begin
			queues_shape_storage[i].print();
			sum_of_area = sum_of_area + queues_shape_storage[i].get_area();
		end
		$display("Total area: %g \n", sum_of_area);
	endfunction : report_shapes

endclass : shape_reporter


module top;

	initial begin
		shape shape_h;
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		bit[31:0] cast_ok;

		int read_file;
		int cnt;

		string shape_type;
		real w;
		real h;

		read_file = $fopen("./lab02part2A_shapes.txt", "r");
		cnt = $fscanf(read_file, "%s %g %g", shape_type, w, h);

		while(cnt == 3) begin

			shape_h = shape_factory::make_shape(shape_type, w, h);

			if(shape_type == "rectangle") begin
				cast_ok = $cast(rectangle_h, shape_h);
				shape_reporter #(rectangle)::store_shape(rectangle_h);
			end
			else if(shape_type == "square") begin
				cast_ok = $cast(square_h, shape_h);
				shape_reporter #(square)::store_shape(square_h);
			end
			else if(shape_type == "triangle") begin
				cast_ok = $cast(triangle_h, shape_h);
				shape_reporter #(triangle)::store_shape(triangle_h);
			end
			else begin
				$fatal (1, {"No such shape: ", shape_type});
			end

			cnt = $fscanf(read_file, "%s %g %g ", shape_type, w, h);
		end

		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(square)::report_shapes();
		shape_reporter#(triangle)::report_shapes();

		$fclose(read_file);
  
	end

endmodule : top
