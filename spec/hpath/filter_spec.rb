describe Hpath::Filter do
  describe "key exists filter \"[foobar?\"]" do
    context "when object is a array of hashes" do
      let(:filter) { Hpath::Filter.new(key_existence_filter: { key: "foobar"} ) }
      let(:array_of_hashes) { [{foobar: 1}, {foo: 2}, {bar: 3}, {foobar: "foobar"}]}

      it "returns hashes, which include the given key" do
        filtered_array = array_of_hashes.select{ |e| filter.applies?(e) }
        expect(filtered_array).to eq([{foobar: 1}, {foobar: "foobar"}])
      end
    end
  end

  context "initialized with a (nested) filter hash" do
    let(:filter_hash) { Hpath::Parser.new.parse("/array/*[a=b,c=d,(e=d|e=f)]")[:path].first[:filter] }

    describe ".filter" do
      context "when given object is an array containing hashes" do
        let(:filter) { Hpath::Filter.new(Hpath::Parser.new.parse("/array/*[a=b,c=d,(e=d|e=f)]")[:path][1][:filter]) }

        it "returns only hashes which match the filter" do
          #w = [{a: "b", c: "d", e: "f"}, {a: "b", c: "d", e: "z"}].select { |e| filter.applies?(e) }
        end
      end
    end
  end
end
