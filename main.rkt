#lang racket

;; Proof of concept for contract REPL

(require (for-syntax syntax/parse))
(provide (rename-out [-#%top-interaction #%top-interaction]))

(define-syntax (-#%top-interaction stx)
  (syntax-parse stx
    ([_ . form]
     (define expanded-stx (local-expand #'form 'top-level #f))
     (define (transform stx)
       (syntax-parse stx
         [((~literal begin) e:expr ... e1:expr)
          #`(begin e ... #,(transform #'e1))]
         [id:identifier (transform #'(#%expression id))]
         [(~and form (kw:identifier e:expr ...))
          #:when (for/or ([k (list #'#%plain-lambda #'case-lambda #'if #'begin #'begin0
                                   #'let-values #'letrec-values #'set! #'quote #'quote-syntax
                                   #'with-continuation-mark #'#%plain-app #'#%top
                                   #'#%variable-reference #'#%expression)])
                   (free-identifier=? k #'kw))
          #'(let ([val form])
              (cond [(has-contract? val)
                     (define ctc-msg
                       (format "- : ~a" (contract-name (value-contract val))))
                     (displayln ctc-msg)
                     val]
                    [else val])
              val)]
         [form #'form]))
     (transform expanded-stx))))
