describe Hpath::Parser do
  let(:parser) { Hpath::Parser.new }

  it "parses a hpath string into a tree structure" do
=begin
    expect(parser.parse("/foo/bar/*[a=b,c=d,(e<d|e>f)]/foo[1]/bar[<10]")).to eq(
      {:path=>
        [{:identifier=>:foo, :filter=>nil, :index=>nil},
         {:identifier=>:bar, :filter=>nil, :index=>nil},
         {:identifier=>:*,
          :filter=>
           {:and_filter=>
             [{:key_value_filter=>{:key=>:a, :operator=>"=", :value=>"b"}},
              {:key_value_filter=>{:key=>:c, :operator=>"=", :value=>"d"}},
              {:or_filter=>
                [{:key_value_filter=>{:key=>:e, :operator=>"<", :value=>"d"}},
                 {:key_value_filter=>{:key=>:e, :operator=>">", :value=>"f"}}]}]},
          :index=>nil},
         {:identifier=>:foo, :filter=>nil, :index=>1},
         {:identifier=>:bar,
          :filter=>{:key_value_filter=>{:key=>nil, :operator=>"<", :value=>"10"}},
          :index=>nil}]}
    )
=end
  end
end
