# Glug

Text-based markup for MapLibre and Mapbox GL.

Glug is a compact markup 'language' that compiles to GL JSON styles. It's implemented as a Ruby Domain-Specific Language (DSL), with all the flexibility that affords.

Unlike CartoCSS and MapCSS, Glug does not cascade rules as standard. Cascading can produce a large number of rules, which is bad for mobile performance, and can make styles difficult to manage. Instead, Glug encourages concise styling by nesting layer definitions, with limited cascading as an option.

Glug is a compiler. You should use it to generate JSON, then serve that JSON with your maps. Don't use Glug on the fly in production.

## A simple Glug stylesheet

```ruby
version 8
name "My first stylesheet"
source :osm_data, type: 'vector', url: 'http://my-server.com/osm.tilejson'
 
layer(:roads, zoom: 10..13, source: :osm_data) {
    line_width 6
    line_color 0x888888
    on(highway=='motorway', highway=='motorway_link') { line_color :blue }
    on(highway=='trunk', highway=='trunk_link') { line_color :green }
    on(highway=='primary', highway=='primary_link') { line_color :red }
    on(highway=='secondary') { line_color :orange }
    on(highway=='residential') { line_width 4 }
}
```

## Installation and running

`gem install glug`

Run glug from the command line:

`glug my_stylesheet.glug > my_stylesheet.json`

Use Glug from Ruby:

```ruby
require 'glug'

json = Glug::Stylesheet.new {
  version 8
  center [0.5,53]
}.to_json
```

You should refer to the [Mapbox GL style documentation](https://www.mapbox.com/mapbox-gl-style-spec/) to understand GL styles and their properties. This README only explains how Glug expresses those properties.

## Stylesheet and sources

Stylesheet-wide properties are defined simply:

```ruby
  version 8
  center [-1.3,51.5]
```

Sources are defined as hashes, with the source name specified as a symbol:

```ruby
  source :mapbox_streets, type: 'vector',
         url: 'mapbox://mapbox.mapbox-streets-v5', default: true
```

Note the `default: true` extension. This registers the source as the default for your style, so you don't have to specify it in every layer.

## Layers - the basics

Layers are the meat of the styling, where Glug does most of its work.

### Creating a layer

You create a layer like this:

```ruby
  layer(:water, zoom: 5..13, source: :osm_data) {
    # Style definitions go here...
  }
```

The layer call begins with the layer id (`:water`) and then any additional layer-wide properties (source, source_layer, metadata, interactive). If no source is specified, the default will be used. If no source_layer is specified, the layer id will be used - so in this case, Glug would assume a source_layer of 'water'.

Zoom levels are always specified as Ruby ranges (`5..13`) rather than separate minzoom/maxzoom properties.

### Style definitions

Style properties are defined as you'd expect:

```ruby
  line_width 5
  line_color 0xFF07C3
```

Glug will automatically create the 'type' property for you based on the styles you define. Use 'line_width' or 'line_color', and Glug will set 'type' to 'line'. GL styles don't allow you to mix different types (e.g. lines and fills) within one layer.

Use underscores in property names where the GL style spec has a hyphen, so 'line_color' rather than 'line-color'.

When defining colours, note that Ruby specifies hex colours like so: `0xC38291`. This means you need to specify all six digits of a hex colour, so `0xCC3388` rather than '#C38'. You can avoid this by supplying a string instead: `"#C38"`.

You can use either symbols (`:blue`) or strings (`"blue"`): both will be written out as strings.

### Filters and expressions

Glug wraps GL styles' powerful [expressions](https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/) in a more familiar format, so you can easily make your styles react to tags/attributes. At its simplest, Glug allows you to add a test like this:

```ruby
  filter highway=='primary'
```

Adding this to a layer will mean the style only applies to primary roads. It uses Ruby's `==` test, not the single '=' you might expect from CSS-based language. You can use other operators, including numeric ones:

```ruby
  filter population<30000
```
and 'in'/'not_in' lists:

```ruby
  filter amenity.in('pub','cafe','restaurant')
```

You can separate tests with commas to match multiple choices:

```
  filter amenity=='pub', tourism=='hotel'
```

You can join tests together with `&` (and) and `|` (or) operators:

```ruby
  filter (place=='town') & (population>100000)
```

You can combine several such operators, but be liberal with parentheses to make the precedence clear:

```ruby
  filter ( (place=='town') & (population>100000) ) | (place=='city')
```
Alternatively, you can also express multiple choices with the `any[]` and `all[]` operators:

```ruby
  filter any[amenity=='pub', tourism=='hotel', amenity=='restaurant']
```

### Using expressions as properties

You can also use expressions to set GL properties programmatically. For example, to set the colour of a circle based on the 'temperature' tag in the vector tile:

```ruby
  circle_color rgb(temperature, 0, temperature/2)
```

If you're following along with the GL [expressions spec](https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/), GL JSON operators are expressed as an array, and in Glug we write them as a operator name ('rgb') followed by the arguments in parentheses.

A more complex example:

```ruby
  fill_color let('density', population/sqkm) <<
    interpolate([:linear], zoom(),
      8,  interpolate([:linear], var('density'), 274, to_color("#edf8e9"), 1551, to_color("#006d2c")),
      10, interpolate([:linear], var('density'), 274, to_color("#eff3ff"), 1551, to_color("#08519c"))
    )
```

Several operators can also be used as dot (postfix) methods. For example, `name.length` will return the length of the name tag; `name.upcase` will return it in upper case; and `in` can be used with a list of values, e.g. `ref.in("M1","M5","M6")`. For the list of operators where this applies, see DOT_METHODS in condition.rb.

Note the following:

* You don't need to use the `get` operator - you can just write the tag name, e.g. `temperature`. (You can still use `get` in case of a clash with a reserved word.)
* For the GL operator 'format', write `string_format` instead; for 'id', write `feature_id`; for 'case', write `case_when`; for the '!' operator, write `_!`. (These are Ruby reserved words or used elsewhere in Glug.)
* Where a GL operator has a dash, write it with an underscore (e.g. `to_color`).
* Arrays can be accessed in standard bracketed subscript notation, e.g. `colours[5]` (compiled to 'at' in the GL style).
* Within colour operators, you'll need to write colours as strings (e.g. "#FF0000") rather than Ruby hex values.
* To concatenate two operators (often where the first is `let`), use `<<`.
* You may still need to use `literal(1,2,3)` to write an array or object value.


## Sublayers and cascading

### Sublayers

Filter expressions come into their own when defining sublayers.

A sublayer inherits all the properties of its parent layer, and adds more, if a test is fulfilled. For example, if you wanted to show all roads 2px wide, but motorways 4px wide:

```ruby
  layer(:roads) {
    line_color :black
    line_width 2
    on(highway=='motorway') { line_width 4 }
  }
```

Sublayers are introduced with the `on` instruction, which expects either a zoom range, an expression, or both. The following are all valid:

```ruby
  on(highway=='motorway') { line_width 4 }
  on(8..12, highway=='motorway') { line_color :blue }
  on(3..6) { line_width 2 }
  on(8, highway=='motorway', oneway='yes') { line-width 2 }
```

Sublayers can be nested:

```ruby
  on(3..6) {
    line_width 2
    on(highway=='motorway') { line-color :blue }
  }
```
Do not add a space between `on` and the parentheses. If your filter breaks, add more parentheses.

Sometimes, you may wish to only generate the sublayers, and suppress the partially unstyled parent layer. You can achieve this with the `suppress` instruction:

```ruby
  layer(:roads) {
    line_width 4
    on(highway=='trunk') { line_color :green }
    on(highway=='primary') { line_color :blue }
    on(highway=='secondary') { line_color :orange }
    suppress
  }
```

Sublayers have no special meaning in GL styles; they are normal layers like any other. Glug unwraps the 'inherited' properties and creates a layer accordingly. Points to note:

* Glug names sublayers automatically: the first sublayer of `roads` will be `roads__1`. If you want to give a sublayer an explicit layer id, write `id :minor_roads`.
* If two layers share a source, filter, zoom levels, type, and certain ('layout') properties, the GL renderer can optimise drawing by reusing the same definition. Glug does this invisibly so you don't need to specify it in your style.
* Layer ordering follows the order of your stylesheet.
* Nested zoom levels simply overwrite their 'parents', so a zoom 7 nested within a zoom 3..6 will still render at zoom 7.

### Cascading

An intentionally limited form of cascading is provided:

```ruby
  layer(:roads) {
    line_width 4

    cascade(motor_vehicle=='no') { line_width 2 }
    uncascaded(motor_vehicle!='no')

    on(highway=='trunk') { line_color :green }
    on(highway=='primary') { line_color :blue }
    suppress
  }
```

For each sublayer, a cascaded variant is applied with the `motor_vehicle=='no'` test. The uncascaded sublayer gets an extra condition, too, to avoid both versions being drawn when `motor_vehicle=='no'`.

The result is four layers:

1. If `highway=='trunk'` & `motor_vehicle=='no'`, draw `line_color: :green` and `line_width 2`
2. If `highway=='primary'` & `motor_vehicle=='no'`, draw `line_color: :blue` and `line_width 2`
3. If `highway=='trunk'` & `motor_vehicle!='no'`, draw `line_color: :green` and `line_width 4`
4. If `highway=='primary'` & `motor_vehicle!='no'`, draw `line_color: :blue` and `line_width 4`

The `cascade` instruction applies to sublayers created below it, but not to those created above, or to the parent layer. Cascades do not multiply each other, so if you write

```ruby
    cascade(motor_vehicle=='no') { line_width 2 }
    cascade(route=='bus') { line_color :red }
```

this will not create rules for a combined `motor_vehicle=='no' & route=='bus'` condition - you must do that yourself.

Each cascade doubles the number of sublayer rules, so use them with great care!

### Still Ruby

Despite these additions, Glug is Ruby at heart so you can use comments, variables, includes, multi-statement lines, do/end blocks, all as you'd expect. Don't expect error-trapping to quite be the same - since Glug interprets unknown words as tag keys, errors can sometimes be swallowed up.

You can even use Ruby's lambdas to set a value as a fraction of the previously set one:

```ruby
  line_width 4
  on(urban==true) { line_width ->(old_value){ old_value/2.0 } }
```

## To do

* Glug is in alpha. Things may break.
* Glug doesn't yet support class-specific paint properties.
* Glug doesn't yet do anything clever with sprite or glyph directives, but maybe it should.

## Contributing

Bug reports, suggestions and (especially!) pull requests are very welcome on the Github issue tracker. Please check the tracker to see if your issue is already known, and be nice. For questions, please use IRC (irc.oftc.net or http://irc.osm.org, channel #osm-dev) and http://help.osm.org.

Formatting: braces and indents as shown, hard tabs (4sp). (Yes, I know.) Please be conservative about adding dependencies.

## Copyright and contact

Richard Fairhurst, 2022. This code is licensed as FTWPL; you may do anything you like with this code and there is no warranty.

If you'd like to sponsor development of Glug, you can contact me at richard@systemeD.net.

Check out [tilemaker](https://github.com/systemed/tilemaker) to produce the vector tiles which MapLibre and Mapbox GL consume.
