(import [hy.models [HyKeyword :as Keyword HyString :as Str HySymbol :as Sym]])
(import [copy [copy]])
(import [mal_types [MalException Atom]])
(import [reader [read-str]])
(import [printer [pr-str]])

(defn sequential? [a]
  (or (instance? tuple a) (instance? list a)))

(defn equal [a b]
  (if (and (sequential? a) (sequential? b) (= (len a) (len b)))
      (every? (fn [[a b]] (equal a b)) (zip a b))

      (and (instance? dict a) (instance? dict b) (= (.keys a) (.keys b)))
      (every? (fn [k] (and (equal (get a k) (get b k)))) a)

      (= (type a) (type b))
      (= a b)

      False))

(def ns
  {"="        equal
   "throw"    (fn [a] (raise (MalException a)))

   "nil?"     none?
   "true?"    (fn [a] (and (instance? bool a) (= a True)))
   "false?"   (fn [a] (and (instance? bool a) (= a False)))
   "symbol"   (fn [a] (Sym a))
   "symbol?"  (fn [a] (instance? Sym a))
   "keyword"  (fn [a] (Keyword (if (keyword? a) a (+ ":" a))))
   "keyword?" (fn [a] (keyword? a))

   "pr-str"  (fn [&rest a] (Str (.join " " (map (fn [e] (pr-str e True)) a))))
   "str"     (fn [&rest a] (Str (.join "" (map (fn [e] (pr-str e False)) a))))
   "prn"     (fn [&rest a] (print (.join " " (map (fn [e] (pr-str e True)) a))))
   "println" (fn [&rest a] (print (.join " " (map (fn [e] (pr-str e False)) a))))
   "read-string" read-str
   "slurp"   (fn [a] (Str (-> a open .read)))

   "<"  <
   "<=" <=
   ">"  >
   ">=" >=
   "+"  +
   "-"  -
   "*"  *
   "/"  (fn [a b] (int (/ a b)))

   "list"      (fn [&rest args] (tuple args))
   "list?"     (fn [a] (instance? tuple a))
   "vector"    (fn [&rest a] (list a))
   "vector?"   (fn [a] (instance? list a))
   "hash-map"  (fn [&rest a] (dict (partition a 2)))
   "map?"      (fn [a] (instance? dict a))
   "assoc"     (fn [m &rest a] (setv m (copy m))
                               (for [[k v] (partition a 2)] (assoc m k v)) m)
   "dissoc"    (fn [m &rest a] (setv m (copy m))
                               (for [k a] (if (.has_key m k) (.pop m k))) m)
   "get"       (fn [m a] (if (and m (.has_key m a)) (get m a)))
   "contains?" (fn [m a] (if (none? m) None (.has_key m a)))
   "keys"      (fn [m] (tuple (.keys m)))
   "vals"      (fn [m] (tuple (.values m)))

   "sequential?" sequential?
   "cons"   (fn [a b] (tuple (chain [a] b)))
   "concat" (fn [&rest a] (tuple (apply chain a)))
   "nth"    (fn [a b] (get a b))
   "first"  (fn [a] (if (none? a) None (first a)))
   "rest"   (fn [a] (if (none? a) (,) (tuple (rest a))))
   "empty?" empty?
   "count"  (fn [a] (if (none? a) 0 (len a)))
   "apply"  (fn [f &rest a] (apply f (+ (list (butlast a)) (list (last a)))))
   "map"    (fn [f a] (tuple (map f a)))

   "atom"   (fn [a] (Atom a))
   "atom?"  (fn [a] (instance? Atom a))
   "deref"  (fn [a] a.val)
   "reset!" (fn [a b] (do (setv a.val b) b))
   "swap!"  (fn [a f &rest xs] (do (setv a.val (apply f (+ (, a.val) xs))) a.val))
   })