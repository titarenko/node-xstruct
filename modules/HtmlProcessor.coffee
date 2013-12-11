moment = require "moment"
cheerio = require "cheerio"

module.exports = class HtmlProcessor

	constructor: (@_result, @_emitter) ->
		@_initial = @_result

	get: (func) ->
		html = new HtmlProcessor @_initial, @_emitter
		func(html)._result

	css: (css) ->
		result = if typeof @_result is "function" then @_result(css) else @_result.find(css)
		@_answer "css", result, 
			css: css
			result: (r) -> r.length

	attr: (name) ->
		@_answer "attr", @_result.attr(name), 
			attr: name

	trim: ->
		@_answer "trim", @_result.replace(/^[ \t\r\n]+|[\t\r\n ]+$/g, "")

	text: ->
		@_answer "text", @_result.text()

	regex: (r) ->
		@_answer "regex", (@_result.match r)?[0], 
			regex: r.toString()

	replace: (what, replacement) ->
		@_answer "replace", @_result.replace(what, replacement), 
			what: what,
			replacement: replacement 

	float: ->
		float = parseFloat @_result
		@_answer "float", if isNaN float then null else float 

	parse: (format) ->
		@_answer "parse", moment(@_result, format)._d,
			format: format

	format: (format) ->
		@_answer "format", moment(@_result).format(format),
			format: format

	at: (index) ->
		@_answer "at", @_result.eq(index),
			index: index
			result: (r) -> r.length

	map: (func) ->
		mapper = (element, index) =>
			html = new HtmlProcessor cheerio(element), @_emitter
			func(html, index)
		@_answer "map", @_result.toArray().map(mapper),
			result: (r) -> r.length

	coalesce: (value) ->
		@_answer "coalesce", @_result or value,
			value: value

	_answer: (name, value, meta) ->
		@_result = value
		meta = meta or {}
		if typeof meta.result is "function"
			meta.result = meta.result @_result
		else
			meta.result = @_result
		@_emitter name, meta
		@
