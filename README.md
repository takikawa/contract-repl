This is an experiment with printing contracts at the REPL.

Here's an example use:

````
$ git clone git@github.com:takikawa/contract-repl.git
$ raco pkg install contract-repl/
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

---

Copyright 2013 Asumu Takikawa

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/.

