#require "some_more_complex_hpath_tests"

describe Hpath do
  describe "#get" do
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
        expect(hpath_result).to eq([{:a=>"b"}, {:c=>"d"}])
      end
      
      it "processes \"/[key1, key2]\" for a hash" do
        hpath_result = Hpath.get({a: 1, b: 2, "c" => 3}, "/[a,c]")
        expect(hpath_result).to eq({a: 1, "c" => 3})
      end

      it "processes \"/[key=value]\" for a array of hashes" do
        hpath_result = Hpath.get([{a: "foo"}, {a: "bar"}, { "a" => :bar }, {a: "muff"}], "/[a=bar]")
        expect(hpath_result).to eq([{:a=>"bar"}, {"a"=>:bar}])
      end

      it "processes \"/[key1=value1,key2=value2]\" for a array of hashes" do
        hpath_result = Hpath.get([{a:"1", b:"2", c:"3"}, {"a" => "1", "b" => "2", c:"3"}, {a:"2", b:"1", c:"3"}], "/[a=1,b=2]")
        expect(hpath_result).to eq([{:a=>"1", :b=>"2", :c=>"3"}, {"a"=>"1", "b"=>"2", :c=>"3"}])
      end

      it "processes \"/[key1=value1,(key2=value2|key3=value3)]\" for a array of hashes" do
        hpath_result = Hpath.get([{a:"1", b:"2", c:"3"}, {a:"1", b:"5", c:"6"}, {a:"2", b:"1", c:"3"}], "/[a=1,(b=5|c=3)]")
        expect(hpath_result).to eq([{:a=>"1", :b=>"2", :c=>"3"}, {:a=>"1", :b=>"5", :c=>"6"}])
      end
      
      it "processes \"/array/key\" for an array of hashes" do
        hpath_result = Hpath.get([{a:"1", b:"2", c:"3"}, {a:"1", b:"5", c:"6"}, {a:"2", b:"1", c:"3"}], "/a")
        expect(hpath_result).to eq(["1", "1", "2"])
      end

=begin
      it "processes \"/key1/::parent\" for a hash" do
        hpath_result = Hpath.get({ foo: { bar: "foobar" } },  "/foo/::parent")
        expect(hpath_result).to eq({ foo: { bar: "foobar" } })
      end

      it "processes \"/[n]/::parent\" for an array of hashes" do
        hpath_result = Hpath.get([{ foo: { bar: "foobar" } }],  "/[0]/::parent")
        expect(hpath_result).to eq([{ foo: { bar: "foobar" } }])
      end
=end

      it "processes \"/**[filter]\"" do
        hpath_result = Hpath.get({
          query: {
            bool: {
              must: [
                {
                  query_string: {
                    query: "linux",
                    fields: ["_all", "title^2"]
                  }
                },
                {
                  query_string: {
                    query: "kofler",
                    fields: ["creator"]
                  }
                }
              ],
              should: [
                {
                  query_string: {
                    query: "linux",
                    fields: ["subject"]
                  }
                }
              ]
            }
          }
        }, "/**[query_string?]")
        expect(hpath_result).to eq(
          [{:query_string=>{:query=>"linux", :fields=>["_all", "title^2"]}},
           {:query_string=>{:query=>"kofler", :fields=>["creator"]}},
           {:query_string=>{:query=>"linux", :fields=>["subject"]}}]
        )
      end
    end

    describe "returns nil for non-matching hpath expressions" do
      it "does not process \"/key1\" for an empty array" do
        hpath_result = Hpath.get([], "/foo")
        expect(hpath_result).to eq(nil)
      end
    end
  end

  describe "#set" do
    describe "sets the object identified by its hpath to the given value" do
      it "processes \"/key1/key2\" for a hash" do
        Hpath.set(hash = {}, "/foo/bar", { muff: "foobar"})
        expect(hash).to eq({foo: { bar: { muff: "foobar"} }})
      end
=begin
      it "processes \"/[]/key2\" for a array" do
        Hpath.set(array = [], "/[]/bar", { foo: "bar"})
        expect(array).to eq([{ bar: {foo: "bar"} }])
      end

      it "processes \"/key1[]/key2\" for a array" do
        Hpath.set(hash = {}, "/key1[]/bar", { foo: "bar"})
        expect(hash).to eq({key1: [{bar: {foo: "bar"}}]})
      end

      it "processes \"/key1\" = 1 for a hash" do
        Hpath.set(hash = {}, "/key1", 1)
        expect(hash).to eq({key1: 1})
      end
=end
    end
  end
end
