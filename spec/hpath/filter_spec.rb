describe Hpath::Filter do
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
