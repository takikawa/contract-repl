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
                                   #'values
                                   #'with-continuation-mark #'#%plain-app #'#%top
                                   #'#%variable-reference #'#%expression)])
                   (free-identifier=? k #'kw))
          #'(let ([vals (call-with-values (lambda () form) list)])
              (define n (length vals))
              (for ([val vals]
                    [i (in-naturals 1)])
                (cond [(has-contract? val)
                       (display-val-contract val i n)
                       val]
                      [else val]))
              (apply values vals))]
         [form #'form]))
     (transform expanded-stx))))

(define (display-val-contract val index val-count)
  (define contract (pretty-format (contract-name (value-contract val))))
  (define prefix (format "~a : " (if (> val-count 1) index "-")))
  (for ([line (string-split contract "\n")]
        [line-index (in-naturals)])
    (displayln
     (string-append (if (= line-index 0)
                        prefix
                        (make-string (string-length prefix) #\space))
                    ;; Remove quote from first line and maintain indentation in
                    ;; other lines
                    (substring line 1)))))
