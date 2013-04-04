#lang racket

;; Proof of concept for contract REPL

(module reader syntax/module-reader
  contract-repl/main
  #:read read
  #:read-syntax read-syntax)

(require (for-syntax syntax/parse)
         (except-in racket #%top-interaction))
(provide (except-out (all-from-out racket) #%top-interaction)
         (rename-out [-#%top-interaction #%top-interaction]))

(define-syntax (-#%top-interaction stx)
  (syntax-parse stx
    ([_ . form]
     (define expanded-stx (local-expand #'form 'top-level #f))
     (syntax-parse expanded-stx
       [(~and form (kw:identifier e:expr ...))
        #:when (for/or ([k (list #'#%plain-lambda #'case-lambda #'if #'begin #'begin0
                                 #'let-values #'letrec-values #'set! #'quote #'quote-syntax
                                 #'with-continuation-mark #'#%plain-app #'#%top
                                 #'#%variable-reference #'#%expression)])
                 (free-identifier=? k #'kw))
        #'(let ([val form])
            (if (has-contract? val)
                (contract-name (value-contract val))
                val))]
       [form #'form]))))