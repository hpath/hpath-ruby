describe Hpath do
  describe "#get" do
    it "takes an object and a hpath string" do
      # Hpath.get(object, "/foo/bar")
    end

    describe "returns the corresponding value from the given object" do
      it "processes \"/key\" for a nested hash" do
        hpath_result = Hpath.get({ foo: { bar: 1 } }, "/foo")
        expect(hpath_result).to eq({ bar: 1 })
      end

      it "processes \"/[n]\" for an array" do
        hpath_result = Hpath.get([1,2,3], "/[0]")
        expect(hpath_result).to eq(1)
      end

      it "processes \"/[m,n]\" for an array" do
        hpath_result = Hpath.get([1,2,3], "/[0,1]")
        expect(hpath_result).to eq([1,2])
      end

      it "processes \"/key1/key2\" for a nested hash" do
        hpath_result = Hpath.get({ foo: { bar: 1 } }, "/foo/bar")
        expect(hpath_result).to eq(1)
      end

      it "processes \"/*\" for an array" do
        hpath_result = Hpath.get([1,2,3], "/*")
        expect(hpath_result).to eq([1,2,3])
      end

      it "processes \"/*\" for a hash" do
        hpath_result = Hpath.get({a: "b", c: "d"}, "/*")
        expect(hpath_result).to eq([{a: "b"}, {c: "d"}])
      end
      
      it "processes \"/[key1, key2]\" for a hash" do
        hpath_result = Hpath.get({a: 1, b: 2, c:3}, "/[a,c]")
        expect(hpath_result).to eq({a: 1, c: 3})
      end

      it "processes \"/[key=value]\" for a array of hashes" do
        hpath_result = Hpath.get([{a: "foo"}, {a: "bar"}, {a: "muff"}], "/[a=bar]")
        expect(hpath_result).to eq([{a: "bar"}])
      end

      it "processes \"/[key1=value1,key2=value2]\" for a array of hashes" do
        hpath_result = Hpath.get([{a:"1", b:"2", c:"3"}, {a:"1", b:"2", c:"3"}, {a:"2", b:"1", c:"3"}], "/[a=1,b=2]")
        expect(hpath_result).to eq([{a:"1", b:"2", c:"3"}, {a:"1", b:"2", c:"3"}])
      end

      it "processes \"/[key1=value1,(key2=value2|key3=value3)]\" for a array of hashes" do
        hpath_result = Hpath.get([{a:"1", b:"2", c:"3"}, {a:"1", b:"5", c:"6"}, {a:"2", b:"1", c:"3"}], "/[a=1,(b=5|c=3)]")
        expect(hpath_result).to eq([{:a=>"1", :b=>"2", :c=>"3"}, {:a=>"1", :b=>"5", :c=>"6"}])
      end
    end
  end
end
