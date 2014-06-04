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
If current root element is a hash, get a hash only with the given keys. If the current object is not a hash, but has methods named `key1, key2`, this methods are called and the results are returned.

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
If the current root element is a hash, return the value of the given key. If the current object is not a hash, but has a method named `key`, this method is called and the result is returned.

```ruby
Hpath.get {a: { b: "c" } }, "/a"
# => { b: "c" }
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/hpath/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
