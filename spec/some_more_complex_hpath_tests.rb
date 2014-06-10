describe Hpath do
  describe "#get" do
    let(:object) do
      {
        hello: "world",
        empty_array: [],
        empty_hash: [],
        "string_key" => "foobar",
        some: {
          really: [
            {
              nested: [
                {
                  structure: "hello"
                },
                {
                  structure: "world"
                }
              ]
            }
          ]
        },
        foo: [
          {
            bar: 1
          },
          {
            bar: 2
          }
        ],
        arr_of_arrs: [
          [ [1,2] , [3,4,5] ],
          [ 6,7 ],
          8
        ],
        fields: [
         {"@tag"=>"020",
          "@ind1"=>"a",
          "@ind2"=>"1",
          "subfield"=>
           [{"@code"=>"a", "$"=>"2468492-2"},
            {"@code"=>"b", "$"=>"DNB"}]},
         {"@tag"=>"025",
          "@ind1"=>"a",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"991563239"}},
         {"@tag"=>"025",
          "@ind1"=>"z",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"2468492-2"}},
         {"@tag"=>"025",
          "@ind1"=>"o",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"645481530"}},
         {"@tag"=>"026",
          "@ind1"=>"-",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"ZDB2468492-2"}},
        ]
      }
    end

    it "returns elements which match the given path" do
      expect(described_class.get(object, "/hello")).to eq("world")
      expect(described_class.get(object, "/empty_array")).to eq([])
      expect(described_class.get(object, "/empty_hash")).to eq([])
      expect(described_class.get(object, "/foo")).to eq([{:bar=>1}, {:bar=>2}])
      expect(described_class.get(object, "/foo[0]")).to eq({:bar=>1})
      expect(described_class.get(object, "/foo[1]")).to eq({:bar=>2})
      expect(described_class.get(object, "/foo[]/bar")).to eq([1,2])
      expect(described_class.get(object, "/arr_of_arrs[0]/[1]/[2]")).to eq(5)
      expect(described_class.get(object, "/some/really[]/nested[]/structure")).to eq(["hello", "world"])
      expect(described_class.get(object, "/arr_of_arrs[0]")).to eq([[1, 2], [3, 4, 5]])
    end

    it "returns nil if the path is invalid" do
      expect(described_class.get(object, "/hello_world")).to eq(nil)
      expect(described_class.get(object, "/foo[3]")).to eq(nil)
      expect(described_class.get(object, "/foo[]/bar/muff")).to eq(nil)
    end

    it "allows searching for hashes by specifying key=value" do
      expect(described_class.get(object, "/fields/*[@tag=025|@tag=026]")).to eq(
        [{"@tag"=>"025",
          "@ind1"=>"a",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"991563239"}},
         {"@tag"=>"025",
          "@ind1"=>"z",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"2468492-2"}},
         {"@tag"=>"025",
          "@ind1"=>"o",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"645481530"}},
         {"@tag"=>"026",
          "@ind1"=>"-",
          "@ind2"=>"1",
          "subfield"=>{"@code"=>"a", "$"=>"ZDB2468492-2"}}]
      )
    end
  end

  describe "#set" do
    it "sets the objects value according to path and value" do
      described_class.set(object = {}, "/foo[]/bar", [1,2,3])
      expect(object).to eq({:foo=>[{:bar=>[1, 2, 3]}]})
    end
  end
end
