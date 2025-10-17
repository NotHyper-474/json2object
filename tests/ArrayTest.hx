/*
Copyright (c) 2017-2018 Guillaume Desquesnes, Valentin Lemière

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package tests;

import tests.EnumTest.Enum1;
import haxe.Json;
import json2object.JsonParser;
import json2object.JsonWriter;
import json2object.utils.JsonSchemaWriter;
import utest.Assert;


@:structInit
class Params
{
	public function new(name:String, value:Dynamic)
	{
		this.name = name;
		this.value = value;
	}

	public var name:String;
	//@:jcustomwrite(tests.ArrayTest.writeDynamic)
	public var value:Dynamic;
}

class ClassTest
{

	public function new(time:Int, ?kind:String, ?v:Dynamic, params:Array<Int>, enum1:Enum1)
	{
		this.time = time;
		this.kind = kind;
		this.v = v;
		this.params = params;
		enumTest = enum1;
	}

	@:alias("t")
	public var time:Int;

	@:alias("k")
	@:optional
	@:default("")
	public var kind:String;


	//@:jcustomwrite(tests.ArrayTest.writeDynamic)
	//@:jcustomparse(tests.ArrayTest.writeDynamic)
	@:jforceDynamic
	@:optional
	public var v:Dynamic;

	@:optional
	@:default([])
	@:alias("p")
	public var params:Array<Int>;

	@:alias("e")
	public var enumTest:Enum1;
}

class ArrayTest implements utest.ITest {
	public function new () {}

	@:access(haxe.format.JsonPrinter)
	public static function writeDynamic(v:Dynamic)
	{
		var printer = new haxe.format.JsonPrinter(null, '\t');
		printer.write('', v);
		return printer.buf.toString();
	}

	public function test1 () {
		var parser = new JsonParser<Array<Int>>();
		var writer = new JsonWriter<Array<Int>>();
		var data = parser.fromJson('[0,1,4,3]', "");
		var oracle = [0,1,4,3];
		for (i in 0...data.length) {
			Assert.equals(oracle[i], data[i]);
		}
		Assert.equals(0, parser.errors.length);
		Assert.same(data, parser.fromJson(writer.write(data, "  "),"test"));

		data = parser.fromJson('[0,1,4.4,3]', "");
		Assert.equals(1, parser.errors.length);
		oracle = [0,1,3];
		for (i in 0...data.length) {
			Assert.equals(oracle[i], data[i]);
		}
		Assert.same(data, parser.fromJson(writer.write(data),"test"));

		var dyn = [new ClassTest(0, null, 10, [], EnumValue1("Some value"))];
		var writer1 = new JsonWriter<Array<ClassTest>>(true);
		var j = writer1.write(dyn, '  ');
		trace(j);
		var jj = new JsonParser<Array<ClassTest>>().fromJson(j);
	}

	#if !lua
	public function test2 () {
		var schema = new JsonSchemaWriter<Array<Int>>().schema;
		var oracle = '{"$$schema": "http://json-schema.org/draft-07/schema#","items": {"type": "integer"},"type": "array"}';
		Assert.isTrue(JsonComparator.areSame(oracle, schema));
	}
	#end
}
