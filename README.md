This is an experiment with printing contracts at the REPL.

Here's an example use:

````
$ git clone git@github.com:takikawa/contract-repl.git
$ raco link contract-repl
$ racket
Welcome to Racket v5.3.3.8.
-> (require contract-repl)
-> dict-ref
- : (->i ((d d:dict?) (k (d) ...)) ((default any/c)) any)
#<procedure:d:dict-ref>
````

It gets more interesting with higher-order uses:

````
$ racket
Welcome to Racket v5.3.3.8.
-> (require contract-repl)
-> (module m racket
     (define (f v) (box v))
     (provide (contract-out [f (-> integer? (box/c integer?))])))
-> (require 'm)
-> (f 5)
- : (box/c integer?)
'#&5
````

You can put the following in your `.racketrc` to enable the
contract features for any REPL interaction:

````
(require contract-repl)
````

