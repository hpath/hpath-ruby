# Hpath

This code is heavy work in progress and does not work today. The examples and usage hints given below only show the goals.

## Installation

Add this line to your application's Gemfile:

    gem 'hpath'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hpath

## Usage

Here are some examples of hpath in action.

```ruby
record = {
  title: "About a hash",
  creator: [
    "Hashman",
    "Hashboy"
  ],
  price: [
    { currency: :USD, value: 12.99 },
    { currency: :EUR, value:  8.99 }
  ],
  subject: [
    { type: "automatic", value: "hash" },
    { type: "automatic", value: "hashes" },
    { type: "automatic", value: "ruby" },
    { type: "manual", value: "hash" },
    { type: "manual", value: "array" },
    { type: "manual", value: "Hashman" },
    { type: "manual", value: "Hashboy" },
  ],
  _source: {
    "id" => "123",
    "title" => "<h1>About a hash</h1>",
    ...
  }
}

Hpath.get record, "/title"
# => "About a hash"

Hpath.get record, "/_source/id"
# => "123"

Hpath.get record, "/_source/[id, title]"
# => { "id" => "123", "title" => "<h1>About a hash</h1>" }

Hpath.get record, "/price/*[currency=:USD]"
# => [{ currency: :USD, value: 12.99 }]

Hpath.get record, "/price/*[currency=:USD,value<10]"
# => nil

Hpath.get record, "/price/*[(currency=:USD|currency=:EUR),value<10]"
# => [{ currency: :EUR, value:  8.99 }]

Hpath.get record, "/subject/*[:type='automatic']"
# => [
#      { type: "automatic", value: "hash" },
#      { type: "automatic", value: "hashes" },
#      { type: "automatic", value: "ruby" }
#    ]

Hpath.get record, "/subject/*[:type='automatic']/type"
# => ["automatic", "automatic", "automatic"]
```

## Syntax

### `/`
Get the root element.

```ruby
Hpath.get [:a,:b,:c], "/"
# => [:a,:b,:c]
```

### `/[n]`
Get the n-th element of an array.

```ruby
Hpath.get [:a,:b,:c], "/[1]"
# => :a
```

### `/[n,m,...]`
Get the n-th, m-th and ... element of an array.

```ruby
Hpath.get [:a,:b,:c], "/[1,2]"
# => [:a,:b]
```

### `/[key1, key2, ...]`
If current element is a hash, get a hash only with the given keys. Since it cannot be determined, if the key is a symbol or a string, both interpretations are checked. If the current object is not a hash, but has methods named `key1, key2`, this methods are called and the results are returned.

```ruby
Hpath.get {a: "b", c: "d", e: "f"}, "/[a,c]"
# => {a: "b", c: "d"}
```

### `/*`
Get all elements of the current root element. If it's a array, this simply returns the array. If it's a hash, an array of all key/value pairs is returned.

```ruby
Hpath.get [:a,:b,:c], "/*"
# => [:a,:b,:c]
```

```ruby
Hpath.get {a: "b", c: "d", e: "f"}, "/*"
# => [{a: "b"}, {c: "d"}, {e: "f"}]
```

### `/key`
If the current element is a hash, return the value of the given key. If the current element is not a hash, but has a method named `key`, this method is called and the result is returned.

```ruby
Hpath.get {a: { b: "c" } }, "/a"
# => { b: "c" }
```

If the current element is an array, the non-array behaviour is applied to all members of the array.

```ruby
Hpath.get([{a:"1", b:"2", c:"3"}, {a:"2", b:"5", c:"6"}], "/a")
# => ["1", "2"]
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/hpath/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
