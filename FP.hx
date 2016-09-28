package;

import haxe.ds.Option;

typedef Pair<T, U> = { _1 : T, _2 : U }
class Pairs {
	public static function and<T, U>(a : T, b : U) : Pair<T, U> {
		return { _1 : a, _2 : b};
	}
	public static function fst<T, U>(p : Pair<T, U>) : T {
		return p._1;
	}
	public static function snd<T, U>(p : Pair<T, U>) : U {
		return p._2;
	}
}

class Func {
	public static function fun<T>(x:T) : Void -> T {
		return function () return x;
	}

	public static function onCall<T,U>(f:T->U,t:T) : Void -> U {
		return function () return f(t);
	}

	public static function onCall2<A,B,U>(f:A->B->U,a:A,b:B) : Void -> U {
		return function () return f(a,b);
	}


	public static function andThen<A,B,C>(f : A -> B, g : B -> C) : A -> C {
		return function (x) return g(f(x));
	}

}

class Options {


	public static function ifOpt<T>(x : T, cond : Bool) : Option<T> {
		return cond?Some(x):None;
	}

	public static function ifPred<T>(x : T, pred : T -> Bool) : Option<T> {
		return pred(x)?Some(x):None;
	}

	public static function map<T,U>(opt : Option<T>, f: T -> U) : Option<U> {
		return flatMap(opt, function (x) return option(f(x)));
	}

	public static function map2<T,U, V>(optA : Option<T>, optB : Option<U>, f: T -> U -> V) : Option<V> {
		return flatMap(optA, function (a) return map(optB, f.bind(a)));
	}

	public static function foreach<T>(opt : Option<T>, f: T -> Void) {
		switch (opt) {
			case Some(x): f(x);
			case _:
		}
	}

	inline public static function fold<T,U>(opt : Option<T>, f: T -> U, g : Void -> U) : U {
		var res =
			switch (opt) {
				case Some(x): f(x);
				case _: g();
			};
		return res;
	}

	inline public static function foldValue<T,U>(opt : Option<T>, f: T -> U, g : U) : U {
		var res =
			switch (opt) {
				case Some(x): f(x);
				case _: g;
			};
		return res;
	}

	inline public static function flatMap<T,U>(opt : Option<T>, f: T -> Option<U>) : Option<U> {
		var res =
			switch (opt) {
				case Some(x): f(x);
				case _: None;
			};
		return res;
	}

	inline public static function flatMap2<T,U,V>(optA : Option<T>, optB : Option<U>, f: T -> U -> Option<V>) : Option<V> {
		var res =
			switch (optA) {
				case Some(a): flatMap(optB, f.bind(a));
				case _: None;
			};
		return res;
	}

	public static function filter<T>(opt : Option<T>, pred : T -> Bool) : Option<T> {
		return
			switch (opt) {
				case Some(x) if (pred(x)): Some(x);
				case _: None;
			};
	}

	inline public static function option<T>(x : Null<T>) : Option<T> {
		return (null == x)?None:Some(x);
	}

	public static function orElse<T>(opt: Option<T>, alt : Void -> Option<T>) : Option<T> {
		return opt == None? alt():opt;
	}

	public static function getOrElse<T>(opt: Option<T>, alt : Void -> T) : T {
		return
			switch (opt) {
				case Some(v): v;
				case None: alt();
			}
	}

	public static function getOrElseValue<T>(opt: Option<T>, alt : T) : T {
		return
			switch (opt) {
				case Some(v): v;
				case None: alt;
			}
	}

	inline public static function getUnsafe<T>(opt: Option<T>, error : Void -> String) : T {
		return getOrElse(opt, function () return { throw error(); null; });
	}

	inline public static function toArray<T>(opt : Option<T>) : Array<T> {
		var res =
			switch (opt) {
				case Some(x) : [x];
				case _: [];
			}
		return res;
	}

	inline public static function isDefined<T>(o : Option<T>) : Bool {
		return o != None;
	}

	inline public static function notDefined<T>(o : Option<T>) : Bool {
		return o == None;
	}

	inline public static function exists<T>(o : Option<T>, pred : T -> Bool) : Bool {
		var res = switch (o) {
			case None: false;
			case Some(x): pred(x);
		};
		return res;
	}

	inline public static function flatten<T>(o : Option<Option<T>>) : Option<T> {
		return flatMap(o, function (x) return x);
	}

}

class Arrays {


	inline public static function at<T>(arr:Array<T>, index : Int) : Option<T> {
		return Options.option(arr[index]);
	}

	inline public static function head<T>(arr: Array<T>) : Null<T> {
		return arr[0];
	}

	inline public static function tail<T>(arr: Array<T>) : Array<T> {
		return removeEntry(arr, arr[0]);
	}

	inline public static function isEmpty<T>(arr: Array<T>) : Bool {
		return arr.length == 0;
	}

	inline public static function insertAt<T>(arr : Array<T>, index : Int, v : T) : Array<T> {
		var res = arr.copy();
		res.insert(index, v);
		return res;
	}

	inline public static function removeEntry<T>(arr : Array<T>, v : T) : Array<T> {
		var res = arr.copy();
		res.remove(v);
		return res;
	}

	inline public static function drop<T>(arr:Array<T>, n: Int) :Array<T> {
		var res = [];
		for (i in n...arr.length) {
			res.push(arr[i]);
		}
		return res;
	}

	inline public static function dropRight<T>(arr:Array<T>, n: Int) :Array<T> {
		var res = [];
		for (i in 0...(arr.length-n)) {
			res.push(arr[i]);
		}
		return res;
	}

	inline public static function chunkBy<T>(arr:Array<T>, n: Int) :Array<Array<T>> {
		n = Std.int(Math.max(1, n));
		var res = [];
		var i = 0;
		var total = arr.length;
		while (i < total) {
			res.push(arr.slice(i, i+n));
			i += n;
		}
		return res;
	}


	inline public static function take<T>(arr:Array<T>, n: Int) :Array<T> {
		var res = [];
		var nbElem = Std.int(Math.min(n, arr.length));
		for (i in 0...nbElem) {
			res.push(arr[i]);
		}
		return res;
	}

	public static function takeWhile<T>(arr:Array<T>, pred: T -> Bool) :Array<T> {
		var res = [];
		for (x in arr) {
			if (!pred(x))
				return res;
			res.push(x);
		}
		return res;
	}

	public static function takeWhileRight<T>(arr:Array<T>, pred: T -> Bool) :Array<T> {
		return reversed(takeWhile(reversed(arr), pred));
	}

	public static function headOpt<T>(arr : Array<T>) : Option<T> {
		return Options.option(arr[0]);
	}

	public static function tailOpt<T>(arr : Array<T>) : Option<T> {
		return Options.option(arr[arr.length-1]);
	}

	inline public static function firstOpt<T>(arr: Array<T>) {
		return headOpt(arr);
	}

	inline public static function lastOpt<T>(arr: Array<T>) {
		return tailOpt(arr);
	}

	public static function collect<T,U>(arr : Array<T>, f: T -> Option<U>) : Array<U> {
		var res = [];
		for (v in arr) {
			switch (f(v)) {
				case Some(x) : res.push(x);
				case _ :
			}
		}
		return res;
	}

	public static function collectIfAllSome<T>(arr : Array<Option<T>>) : Option<Array<T>> {
		var res = [];
		for (v in arr) {
			switch (v) {
				case Some(x) : res.push(x);
				case _ : return None;
			}
		}
		return Some(res);
	}

	public static function collectOptions<T,U>(arr : Array<Option<T> >) : Array<T> {
		var res = [];
		for (v in arr) {
			switch (v) {
				case Some(x) : res.push(x);
				case _ :
			}
		}
		return res;
	}

	public static function foreach<T>(arr : Array<T>, f: T -> Void) {
		for (v in arr) {
			f(v);
		}
	}

	public static function foreachi<T>(arr : Array<T>, f: Int -> T -> Void) {
		var i = 0;
		for (v in arr) {
			f(i, v);
			i++;
		}
	}

	public static function map<T,U>(arr : Array<T>, f: T -> U) : Array<U> {
		var res = [];
		for (v in arr) {
			res.push(f(v));
		}
		return res;
	}

	public static function map2<T,U, V>(arr : Array<T>, arr2 : Array<U>, f: T -> U -> V) : Array<V> {
		var res = [];
		var i = 0;
		var length = Std.int(Math.min(arr.length, arr2.length));
		for (i in 0...length) {
			res.push(f(arr[i], arr2[i]));
		}
		return res;
	}

	public static function mapi<T,U>(arr : Array<T>, f: T -> Int -> U) : Array<U> {
		var res = [];
		var acc = 0;
		for (v in arr) {
			res.push(f(v, acc));
			acc += 1;
		}
		return res;
	}

	inline public static function flatMap<T,U>(arr : Array<T>, f: T -> Array<U>) : Array<U> {
		var res = [];
		for (v in arr) {
			res = res.concat(f(v));
		}
		return res;
	}

	inline public static function flatten<T>(arr : Array<Array<T>>) : Array<T> {
		var res = [];
		for (v in arr) {
			res = res.concat(v);
		}
		return res;
	}

	inline public static function foldLeft<I,O>(arr : Array<I>, init: O, func : I -> O -> O) : O {
		var res = init;
		for (v in arr) {
			res = func(v, res);
		}
		return res;
	}

	inline public static function foldLefti<I,O>(arr : Array<I>, init: O, func : Int -> I -> O -> O) : O {
		var index = 0;
		var res = init;
		for (v in arr) {
			res = func(index, v, res);
			index = index + 1;
		}
		return res;
	}

	inline public static function foldRight<I,O>(arr : Array<I>, init: O, func : I -> O -> O) : O {
		var res = init;
		for (v in reversed(arr)) {
			res = func(v, res);
		}
		return res;
	}

	inline public static function foldRighti<I,O>(arr : Array<I>, init: O, func : Int -> I -> O -> O) : O {
		var index = arr.length;
		var res = init;
		for (v in reversed(arr)) {
			res = func(index, v, res);
			index = index - 1;
		}
		return res;
	}

	public static function unfold<A, B>(a : A, f : A -> Option<Pair<A, B> > ) : Array<B> {
		var res = [];
		var cont = true;
		while (cont) {
			var v = f(a);
			switch (v) {
				case None: cont = false;
				case Some(p): a = p._1; res.push(p._2);
			}
		}
		return res;
	}

	public static function reduceLeft<T>(arr : Array<T>, func : T -> T -> T) : Option<T> {
		var res = arr[0];
		if (res == null) {
			return None;
		} else {
			for (i in 1...arr.length) {
				res = func(res, arr[i]);
			}
			return Some(res);
		}
	}

	public static function zipWithIndex<T>(arr : Array<T>) : Array<Pair<T,Int> > {
		var res : Array<Pair<T, Int> > = [];
		var acc = 0;
		for (x in arr) {
			res.push({ _1 : x, _2 : acc});
			acc += 1;
		}
		return res;
	}

	public static function unzip<T, U>(arr : Array<Pair<T, U>>) : Pair<Array<T>, Array<U> > {
		var first = [];
		var second = [];
		for (x in arr) {
			first.push(x._1);
			second.push(x._2);
		}
		return { _1 : first, _2 : second };
	}


	public static function filter<T>(arr : Array<T>, pred : T -> Bool) : Array<T> {
		var res = [];
		for (v in arr) {
			if (pred(v)) {
				res.push(v);
			}
		}
		return res;
	}

// based on ref equality - not structural.
	public static function distinct<T>(arr : Array<T>) : Array<T> {
		var res = [];
		for (v in arr) {
			res.remove(v);
			res.push(v);
		}
		return res;
	}

	public static function distinctEq<T>(arr : Array<T>, eq : T -> T -> Bool) : Array<T> {
		var res = [];
		for (v in arr) {
			var found = Lambda.find(res, function (o) return eq(o,v)) != null;
			if (!found) {
				res.push(v);
			}
		}
		return res;
	}

	public static function find<T>(arr : Array<T>, pred : T -> Bool) : Option<T> {
		for (v in arr) {
			if (pred(v))
				return Some(v);
		}
		return None;
	}

	public static function findi<T>(arr : Array<T>, pred : T -> Int -> Bool) : Option<T> {
		var i = 0;
		for (v in arr) {
			if (pred(v, i))
				return Some(v);
			i += 1;
		}
		return None;
	}

	inline public static function exists<T>(arr : Array<T>, pred : T -> Bool) : Bool {
		return Options.isDefined(find(arr, pred));
	}

	inline public static function all<T>(arr : Array<T>, pred : T -> Bool) : Bool {
		for (x in arr) {
			if (!pred(x)) {
				return false;
			}
		}
		return true;
	}

	public static function reversed<T>(arr : Array<T>) : Array<T> {
		var res = arr.copy();
		res.reverse();
		return res;
	}

	public static function partition<T>(arr : Array<T>, pred : T -> Bool) : { ok : Array<T>, nok : Array<T> } {
		var ok = [];
		var nok = [];

		for (x in arr) {
			if (pred(x))
				ok.push(x);
			else
				nok.push(x);
		}
		return {
			ok : ok,
			nok : nok
		};
	}

	public static function joinWith<T>(arr : Array<T>, v : T) : Array<T> {
		var res = [];
		for (x in arr) {
			res.push(x);
			res.push(v);
		}
		res.pop();
		return res;
	}

	public static function curse<T>(arr : Array<T>, pred : T -> T -> Int) : Array<T> {
		var res = arr.copy();
		res.sort(pred);
		return res;
	}

	public static function chars(s : String) : Array<String> {
		var res = [];
		for (i in 0...s.length) {
			res.push(s.charAt(i));
		}
		return res;
	}

}

class Maps {

	public static function getOpt<K,V>(map :Map<K, V>, k : K) : Option<V> {
		return Options.option(map.get(k));
	}

	public static function getOrElse<K,V>(map :Map<K, V>, k : K, alt : Void -> V) : V {
		var x = map.get(k);
		return (x ==null)?alt():x;
	}

	public static function getOrElseUpdate<K,V>(map :Map<K, V>, k : K, alt : Void -> V) : V {
		var x = map.get(k);
		return
			if (x==null) {
				var res = alt();
				map.set(k, res);
				res;
			} else x;
	}

	inline public static function copy<V>(map : Map<Int,V>) : Map<Int, V> {
		return copyGen(map, function () return new haxe.ds.IntMap<V>());
	}

	public static function copyGen<K, V>(map : Map<K,V>, newMap : Void -> Map<K, V>) : Map<K, V> {
		var newMap = newMap();
		for (k in map.keys()) {
			newMap.set(k, map.get(k));
		}
		return newMap;
	}

	public static function update<V>(map :Map<Int, V>, k : Int, f : Option<V> -> Option<V> ) : Map<Int, V> {
		var newMap = copy(map);
		Options.fold(
			f(Options.option(map.get(k))),
			function (v) return newMap.set(k, v),
			function () newMap.remove(k)
		);
		return newMap;
	}

	public static function toArray<K, V>(map : Map<K,V>) : Array<Pair<K, V> > {
		var res = [];
		for (k in map.keys()) {
			res.push(Pairs.and(k, map.get(k)));
		}
		return res;
	}

	public static function forEach<K, V>(map : Map<K,V>, pred : K -> V -> Void) : Void {
		for (k in map.keys()) {
			var v = map.get(k);
			pred(k, v);
		}
	}

	public static function forEachValue<K, V>(map : Map<K,V>, pred : V -> Void) : Void {
		for (v in map.iterator()) {
			pred(v);
		}
	}

	public static function forEachKey<K, V>(map : Map<K,V>, pred : K -> Void) : Void {
		for (k in map.keys()) {
			pred(k);
		}
	}
}

class Thunk {

	inline public static function thunk<T>(x : T) : Void -> T {
		return function () return x;
	}

}

class Strings {
	public static function mkString(arr : Array<String>, sep : String = "", start : String = "", end : String = "") {
		return [start, arr.join(sep), end].join("");
	}
}

class Iterators {

	public static function toArray<T>(iterator: Iterator<T>) : Array<T> {
		var res = [];
		for (alpha in iterator) {
			res.push(alpha);
		}
		return res;
	}

}

class AllEq {
	
	public static function isEqual<T, U : T>(t : T, u : U) {
		return u == t;
	}

}
